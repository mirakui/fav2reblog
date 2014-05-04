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

    def last_id=(id)
      path = Fav2reblog.config['position_file']
      open(path, 'w') {|f| f.write id }
      id
    end

    def execute
      _last_id = last_id.to_i
      logger.debug("execute: last_id=#{_last_id}")
      @twitter.favorites_with_media.each do |tweet|
        next if _last_id >= tweet.id
        reblog tweet
      end
    rescue
      logger.error "#{$!.class}: #{$!}\n  #{$@.join("\n  ")}"
    end

    def reblog(tweet)
      image_files = tweet.media.map {|m| open(m.media_uri) }
      data = image_files.map {|f| f.path }
      caption = %Q(Twitter / #{tweet.user.screen_name}: #{tweet.full_text})
      tweet.media.each do |m|
        caption.gsub!(m.url, %Q(<a href="#{m.url}">#{m.display_url}</a>))
      end
      link = tweet.uri
      logger.info("reblog: id=#{tweet.id}, data=#{data}, caption=#{caption}, link=#{link}")
      @tumblr.post_photo data: data, caption: caption, link: link
      self.last_id = tweet.id
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
