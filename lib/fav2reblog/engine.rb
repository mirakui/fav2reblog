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
      case tweet.media.first
      when ::Twitter::Media::AnimatedGif
        reblog_video tweet, dry_run: dry_run
      when ::Twitter::Media::Video
        reblog_video tweet, dry_run: dry_run
      when ::Twitter::Media::Photo
        reblog_photo tweet, dry_run: dry_run
      end
    end

    def reblog_photo(tweet, dry_run: false)
      media_uris = tweet.media.map {|m| "#{m.media_uri}:orig" }
      image_files = media_uris.map {|uri| open(uri) }
      data = image_files.map {|f| f.path }
      caption = caption_of tweet
      link = tweet.uri
      logger.info("reblog: id=#{tweet.id}, media=#{media_uris}, caption=#{caption}, link=#{link}")
      unless dry_run
        @tumblr.post_photo data: data, caption: caption, link: link unless dry_run
        update_reblogged_tweet tweet
      end
    end

    def reblog_video(tweet, dry_run: false)
      caption = caption_of tweet
      link = tweet.uri
      logger.info("ignored video: media=#{tweet.media.first.class}, id=#{tweet.id}, caption=#{caption}, link=#{link}")
    end

    def reblog_video_(tweet, dry_run: false)
      media_uris = tweet.media.map do |media|
        media.video_info.attrs[:variants].
          select {|v| v[:content_type] == 'video/mp4' }.
          sort_by {|v| v[:bitrate] }.
          last[:url]
      end

      image_files = media_uris.map {|uri| open(uri) }
      data = image_files.map {|f| f.path }
      caption = caption_of tweet
      link = tweet.uri
      logger.info("reblog: id=#{tweet.id}, media=#{media_uris}, caption=#{caption}, link=#{link}")
      unless dry_run
        @tumblr.post_video data: data, caption: caption unless dry_run
        update_reblogged_tweet tweet
      end
    end

    def caption_of(tweet)
      %Q(Twitter / #{tweet.user.screen_name}: #{tweet.full_text})
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
