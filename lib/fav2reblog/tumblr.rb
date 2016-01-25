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

    def post_photo(blog: config['blog'], data: nil, caption: nil, link: nil)
      client.photo blog, data: data, caption: caption, link: link
    end

    def post_video(blog: config['blog'], data: nil, caption: nil)
      client.video blog, data: data, caption: caption
    end

    private
    def config
      Fav2reblog.config['tumblr']
    end
  end
end
