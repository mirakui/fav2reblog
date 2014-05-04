require 'fav2reblog'
require 'twitter'

module Fav2reblog
  class Twitter
    def client
      return @client if @client
      c = Fav2reblog.config['twitter']
      @client = ::Twitter::REST::Client.new do |config|
        config.consumer_key = c['consumer_key']
        config.consumer_secret = c['consumer_secret']
        config.access_token = c['access_token']
        config.access_token_secret = c['access_secret']
      end
    end

    def favorites_with_media
      client.favorites.select(&:media?).sort {|a,b| a.id <=> b.id }
    end
  end
end
