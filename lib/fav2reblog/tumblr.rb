require 'fav2reblog'
require 'tumblr_client'

module Fav2reblog
  class Tumblr
    def client
      return @client if @client
      c = config
      @client = ::Tumblr::Client.new(
        consumer_key: c['consumer_key'],
        consumer_secret: c['consumer_secret'],
        oauth_token: c['access_token'],
        oauth_token_secret: c['access_secret']
      )
    end

    def post_photo(blog: config['blog'], data:, caption:, link:)
      client.photo blog, data: data, caption: caption, link: link
    end

    private
    def config
      Fav2reblog.config['tumblr']
    end
  end
end
