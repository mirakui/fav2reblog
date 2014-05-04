require 'yaml'

module Fav2reblog
  class Config
    def initialize(path)
      @config = YAML.load File.read(path)
    end

    def [](key)
      @config[key]
    end
  end
end
