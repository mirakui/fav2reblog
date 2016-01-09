require 'fav2reblog'
require 'fav2reblog/twitter'
require 'fav2reblog/tumblr'
require 'fav2reblog/dynamodb'
require 'open-uri'
require 'logger'

module Fav2reblog
  class Engine
    def initialize
      @twitter = Fav2reblog::Twitter.new
      @tumblr = Fav2reblog::Tumblr.new
      @dynamodb = Fav2reblog::Dynamodb.new
    end

    def last_id
      id = nil
      path = Fav2reblog.config['position_file']
      if path && File.exist?(path)
        id = File.read(path).to_i
      end
      id
    end

    def update_reblogged_tweet(tweet)
      @dynamodb.put tweet.id, 'uri' => tweet.uri.to_s, 'reblogged_at' => Time.now.to_i
    end

    def reblogged?(status_id)
      item = @dynamodb.get status_id
      !!item
    end

    def execute(dry_run: false)
      @twitter.favorites_with_media.each do |tweet|
        next if reblogged? tweet.id
        reblog tweet, dry_run: dry_run
      end
    rescue
      logger.error "#{$!.class}: #{$!}\n  #{$@.join("\n  ")}"
    end

    def reblog(tweet, dry_run: false)
      image_files = tweet.media.map {|m| open(m.media_uri) }
      data = image_files.map {|f| f.path }
      caption = %Q(Twitter / #{tweet.user.screen_name}: #{tweet.full_text})
      link = tweet.uri
      logger.info("reblog: id=#{tweet.id}, data=#{data}, caption=#{caption}, link=#{link}")
      unless dry_run
        @tumblr.post_photo data: data, caption: caption, link: link unless dry_run
        update_reblogged_tweet tweet
      end
    end

    def logger
      @logger ||= begin
                    l = Logger.new(Fav2reblog.config['log_file'] || $stdout)
                    l.level = Logger::INFO
                    l
                  end
    end
  end
end
