require 'fav2reblog/version'
require 'fav2reblog/config'

module Fav2reblog
  module_function
  def config
    @config || load_config
  end

  def load_config(path=nil)
    path ||= File.expand_path('../../config/config.yml', __FILE__)
    @config = Fav2reblog::Config.new(path)
  end
end
