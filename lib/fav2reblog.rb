require 'fav2reblog/version'
require 'fav2reblog/config'
require 'logger'

module Fav2reblog
  module_function
  def config
    @config || load_config
  end

  def load_config(path=nil)
    path ||= File.expand_path('../../config/config.yml', __FILE__)
    @config = Fav2reblog::Config.new(path)
  end

  def logger
    @logger ||= begin
                  l = Logger.new(Fav2reblog.config['log_file'] || $stdout)
                  l.level = Logger::INFO
                  l
                end
  end
end
