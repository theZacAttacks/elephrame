require 'net/http'
require 'digest'
require 'time'

module Elephrame  
  module Bots

    ##
    # a superclass for other bots
    # holds common methods and variables
    
    class BaseBot
      attr_reader :client, :username, :failed
      attr_accessor :strip_html, :max_retries

      NoBotRegex = /#?NoBot/i
      FNGabLink  = 'https://fediverse.network/mastodon?build=gab'

      ##
      # Sets up our REST +client+, gets and saves our +username+, sets default
      # value for +strip_html+ (true), and +max_retries+ (5), +failed+
      #
      # @return [Elephrame::Bots::BaseBot]
      
      def initialize

        raise "Fuck off Gabber" if Net::HTTP.get(URI.parse(FNGabLink)).include? URI.parse(ENV['INSTANCE']).host
        
        @client = Mastodon::REST::Client.new(base_url: ENV['INSTANCE'],
                                             bearer_token: ENV['TOKEN'])
        @username = @client.verify_credentials().acct
        @strip_html = true
        @max_retries = 5
        @failed = { media: false, post: false }
      end

      ##
      # Creates a post, uploading media if need be
      #
      # @param text [String] text to post
      # @param visibility [String] visibility level
      # @param spoiler [String] text to use as content warning
      # @param reply_id [String] id of post to reply to
      # @param hide_media [Bool] should we hide media?
      # @param media [Array<String>] array of file paths
      
      def post(text, visibility: 'unlisted', spoiler: '',
               reply_id: '', hide_media: false, media: [])
        
        uploaded_ids = []
        unless media.size.zero?
          @failed[:media] = retry_if_needed {
            uploaded_ids = media.collect {|m|
              @client.upload_media(m).id
            }
          }
        end
        
        options = {
          visibility: visibility,
          spoiler_text: spoiler,
          in_reply_to_id: reply_id,
          media_ids: @failed[:media] ? [] : uploaded_ids,
          sensitive: hide_media
        }

        # create a unique key for the status
        #  this key prevents a status from being posted more than once
        #  SHOULD be unique enough, by smooshing time and content together
        idempotency = Digest::SHA256.hexdigest("#{Time.now}#{text}")
        
        @failed[:post] = retry_if_needed {
          options[:headers] = { "Idempotency-Key" => idempotency }
          @client.create_status text, options
        }
      end

      
      ##
      # Finds most recent post by bot in the ancestors of a provided post
      #
      # @param id [String] post to base search off of
      # @param depth [Integer] max number of posts to search
      # @param stop_at [Integer] defines which ancestor to stop at
      #
      # @return [Mastodon::Status]
      
      def find_ancestor(id, depth = 10, stop_at = 1)
        depth.times {
          post = @client.status(id) unless id.nil?
          id = post.in_reply_to_id

          stop_at -= 1 if post.account.acct == @username

          return post if stop_at.zero?
        }

        return nil
      end

      ##
      # Checks to see if a user has some form of "#NoBot" in their bio or in
      # their profile fields (so we can make making friendly bots easier!)
      #
      # @param account_id [String] id of account to check bio
      #
      # @return [Bool]

      def no_bot? account_id
        acct = @client.account(account_id)
        acct.note =~ NoBotRegex ||
          acct.fields.any? {|f| f.name =~ NoBotRegex || f.value =~ NoBotRegex}
      end

      ##
      # Gets the ID of a list given the name
      #
      # @param name [String] name of the list
      #
      # @return [Integer]
      
      def fetch_list_id(name)
        lists = {}
        @client.lists.collect do |l|
          lists[l.title] = l.id
        end
        lists[name]
      end

      ##
      # Gets the ID of an account given the user's handle or username
      #
      # @param account_name [String] either the user's full handle or
      #    their username. E.g., zac@computerfox.xyz, zac
      # @return [String] ID of account
      
      def fetch_account_id(account_name)
        name = account_name.reverse.chomp('@').reverse
        search = @client.search("@#{name}")

        accounts = {}
        search.accounts.each do |acct|
          accounts[acct.acct] = acct.id
          accounts[acct.username] = acct.id
        end

        accounts[name]
      end

      ##
      # A helper method that is a wrapper around alias_method
      # (just to make some code easier to read)
      #
      # @param method [Symbol] symbol with the name of a method
      # @param new_name [Symbol] symbol with the new name for the method
        
      def self.backup_method(method, new_name)
        alias_method new_name, method
      end
      
      private

      ##
      # An internal function that ensures our HTTP requests go through
      #
      # @param block [Proc] accepts a block, ensures all code inside
      #   that block gets executed even if there was an HTTP error.
      #
      # @return [Bool] true on hitting the retry limit, false on success
      
      def retry_if_needed &block
        @max_retries.times do |i|
          begin
            block.call
            return false
          rescue HTTP::TimeoutError
            puts "caught HTTP Timeout error; retrying #{@max_retries-i} more times"
            sleep 5
          end
        end
        return true
      end
    end
  end
end

