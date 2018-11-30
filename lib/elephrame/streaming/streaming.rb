module Elephrame
  module Streaming
    attr :streamer

    ##
    # Creates the stream client
    
    def setup_streaming
      @streamer = Mastodon::Streaming::Client.new(base_url: ENV['INSTANCE'],
                                                  bearer_token: ENV['TOKEN'])
    end

  end

  
  module Reply
    attr :on_reply, :mention_data

    ##
    # Sets on_reply equal to +block+
    
    def on_reply &block
      @on_reply = block
    end

    ##
    # Replies to the last mention the bot recieved using the mention's
    # visibility and spoiler with +text+
    #
    # *DOES NOT AUTOMATICALLY INCLUDE @'S*
    #
    # @param text [String] text to post as a reply
    
    def reply(text)

      # maybe also @ everyone from the mention? idk that seems like a bad idea tbh
      post(text, @mention_data[:vis], @mention_data[:spoiler],
           @mention_data[:id], @mention_data[:sensitive])
    end

    ##
    # Stores select data about a post into a hash for later use
    #
    # @param mention [Mastodon::Status] the most recent mention the bot received

    def store_mention_data(mention)
      @mention_data = {
        id: mention.id,
        vis: mention.visibility,
        spoiler: mention.spoiler_text,
        mentions: mention.mentions,
        sensitive: mention.sensitive?
      }
    end

    ##
    # Starts a loop that checks for mentions from the authenticated user account
    # running a supplied block or, if a block is not provided, on_reply
    
    def run_reply
      @streamer.user do |update|
        next unless update.kind_of? Mastodon::Notification and update.type == 'mention'

        # this makes it so .content calls strip instead 
        update.status.class.module_eval { alias_method :content, :strip } if @strip_html

        store_mention_data update.status
        
        if block_given?
          yield(self, update.status)
        else
          @on_reply.call(self, update.status)
        end
      end
    end

    alias_method :run, :run_reply
  end
  

  module AllInteractions
    include Elephrame::Reply
    attr :on_fave, :on_boost, :on_follow

    ##
    # Sets on_fave equal to +block+
    
    def on_fave &block
      @on_fave = block
    end

    ##
    # Sets on_boost to +block+
    
    def on_boost &block
      @on_boost = block
    end

    ##
    # Sets on_follow to +block+
    
    def on_follow &block
      @on_follow = block
    end

    ##
    # Starts a loop that checks for any notifications for the authenticated
    # user, running the appropriate stored proc when needed
    
    def run_interact
      @streamer.user do |update|
        if update.kind_of? Mastodon::Notification
          
          case update.type
              
          when 'mention'

            # this makes it so .content calls strip instead 
            update.status.class.module_eval { alias_method :content, :strip } if @strip_html
            store_mention_data update.status
            @on_reply.call(self, update.status) unless @on_reply.nil?
            
          when 'reblog'
            @on_boost.call(self, update) unless @on_boost.nil?
            
          when 'favourite'
            @on_fave.call(self, update) unless @on_fave.nil?
            
          when 'follow'
            @on_follow.call(self, update) unless @on_follow.nil?
            
          end
        end
      end
    end

    
    alias_method :run, :run_interact
  end
end
