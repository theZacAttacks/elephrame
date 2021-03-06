# Elephrame

[![Gem Version](https://badge.fury.io/rb/elephrame.svg)](https://badge.fury.io/rb/elephrame)
[RubyDoc](https://www.rubydoc.info/github/theZacAttacks/elephrame/)

Elephant-Framework -- by [zac@computerfox.xyz](https://social.computerfox.xyz/@zac)

A framework that helps simplify the creation of bots for mastodon/pleroma

Uses [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) in the backend

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'elephrame'
```

And then execute:

    bundle

Or install it yourself as:

    gem install elephrame

## Quickstart

bot that posts "trans right are human rights" every three hours:

```ruby
require 'elephrame'

my_bot = Elephrame::Bots::Periodic.new '3h'

my_bot.run do |bot|
  bot.post("trans rights are human rights")
end
```

	$ INSTANCE="https://mastodon.social" TOKEN="your_access_token" ruby bot.rb

Check the [examples](https://github.com/theZacAttacks/elephrame/tree/master/examples) directory for more example bots

If you're new to ruby development in general there is also a [getting started](https://github.com/theZacAttacks/elephrame/tree/master/examples/getting_started.org) document in the examples folder that I would recommend you to read. It takes a high level approach to getting started with ruby, some basic syntax, working with gems, basic project structure, and more!

### Bot Types

So far the framework support 6 bot types: Periodic, Interact, PeroidInteract, Reply, Command, Watcher

- `Periodic` supports posting on a set schedule
- `Interact` supports callbacks for each type of interaction (favorites, boosts, replies, follows)
- `PeriodInteract` supports both of the above (I know, this isn't a good name)
- `Reply` only supports replying to mentions
- `Command` supports running code when mentioned with commands it recognizes
- `Watcher` supports watching streaming timelines (including lists, hashtags, public timeline, local timeline, and user timeline)
- `TraceryBot` supports automatically loading tracery rules. Overloads post method to automatically expand any text passed through it. This bot type provides certain options that ease the use of tracery grammar rules, please see examples and/or documentation for more explanation.
- `EbooksBot` provides a very quick and easy way to create an ebooks bot. Please see the example in the examples folder for a detailed explanation. 
- `MarkovBot` provides a quick way to get started with making markov bots. Please see the example in the examples folder.

Both the Ebooks and Markov bots support a few commands out of the box. `!delete`, `!filter`, and `!help`. These commands will only work when sent from an account that the bot is following. The Ebooks bot supports `!update` as well.

Any time a 'time' string is needed it must be either a 'Duration' or 'Cron' string as parsable by [fugit](https://github.com/floraison/fugit)

## Usage

All the documentation is over at [RubyDoc](https://www.rubydoc.info/github/theZacAttacks/elephrame/)!

Every place that accepts a block provides access to the bot object. This allows for easy access to some provided helper methods, as well as the actual mastodon access object.

Exposed methods from bot object:

- `client` this is the underlying mastodon rest client we use in the backend. use this to make custom calls to the api for which we don't provide a helper
- `username` the name of the bot as fetched by verify_credentials
- `strip_html` (defaults to true) if set, the framework will automatically strip all html symbols from the post content
- `max_retries` (defaults to 5) the maximum amount of times the framework will retry a mastodon request
- `failed` a hash that represents the status of the last post or media upload. `failed[:post]` and `failed[:media]`; returns true if it failed, false if it succeeded 
- `post(content, visibility: 'unlisted', spoiler: '', reply_id: '', hide_media: false, media: [])` this provides an easy way to post statuses from inside code blocks
- `reply(content, *options)` a shorthand method to reply to the last mention (Note: only include the @ for the user who @ed the bot)
- `reply_with_mentions(content, *options)` similar to `reply` but includes all @s (respects #NoBot)
- `find_ancestor(id, depth = 10, stop_at = 1)` looks backwards through reply chains for the most recent post the bot made starting at post `id` until it hits `depth` number of posts, or finds `stop_at` number of it's own posts
- `no_bot?(account_id)` returns true if user with `account_id` has some form of "#NoBot" in their bio or their profile fields
- `fetch_list_id(name)` return the id of a list with given name `name`
- `fetch_account_id(account_name)` return the id of an account with given handle `account_name`

(See RubyDocs for source code documentation)

## In the Wild!

Here's a list of bots that are currently using this framework. If you are using it, add yourself to this list and submit a pull request!

- [GameBot](https://github.com/theZacAttacks/GameBot)
- [EnhanceBot](https://github.com/theZacAttacks/EnhanceBot)
- [RemindMe Bot](https://github.com/theZacAttacks/RemindMeBot)
- [InstanceEmoji Bot](https://github.com/theZacAttacks/InstanceEmojiBot)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/theZacAttacks/elephrame. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Elephrame project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/theZacAttacks/elephrame/blob/master/CODE_OF_CONDUCT.md).
