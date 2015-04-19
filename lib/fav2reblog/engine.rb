require 'fav2reblog'
require 'fav2reblog/twitter'
require 'fav2reblog/tumblr'
require 'open-uri'
require 'logger'

module Fav2reblog
  class Engine
    def initialize
      @twitter = Fav2reblog::Twitter.new
      @tumblr = Fav2reblog::Tumblr.new
    end

    def last_id
      id = nil
      path = Fav2reblog.config['position_file']
      if path && File.exist?(path)
        id = File.read(path).to_i
      end
      id
    end

    def set_last_id(id, update_file: true)
      path = Fav2reblog.config['position_file']
      open(path, 'w') {|f| f.write id } if update_file
      id
    end

    def execute(dry_run: false, update_last_id: true)
      _last_id = last_id.to_i
      logger.debug("execute: last_id=#{_last_id}")
      @twitter.favorites_with_media.each do |tweet|
        next if _last_id >= tweet.id
        reblog tweet, dry_run: dry_run, update_last_id: update_last_id
      end
    rescue
      logger.error "#{$!.class}: #{$!}\n  #{$@.join("\n  ")}"
    end

    def reblog(tweet, dry_run: false, update_last_id: true)
      image_files = tweet.media.map {|m| open(m.media_uri) }
      data = image_files.map {|f| f.path }
      caption = %Q(Twitter / #{tweet.user.screen_name}: #{tweet.full_text})
      link = tweet.uri
      logger.info("reblog: id=#{tweet.id}, data=#{data}, caption=#{caption}, link=#{link}")
      @tumblr.post_photo data: data, caption: caption, link: link unless dry_run
      set_last_id tweet.id, update_file: update_last_id
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
