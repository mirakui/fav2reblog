require 'fav2reblog'
require 'aws-sdk-core'

module Fav2reblog
  class Dynamodb
    def config
      Fav2reblog.config['dynamodb']
    end

    def client
      args = {
        region: config['region'],
        access_key_id: config['access_key_id'],
        secret_access_key: config['secret_access_key'],
      }
      @client ||= Aws::DynamoDB::Client.new args
    end

    def table_name
      config['table_name']
    end

    def put(status_id, item=nil)
      item = (item || {}).merge 'status_id' => status_id.to_i
      client.put_item table_name: table_name, item: item
    end

    def get(status_id)
      res = client.get_item table_name: table_name, key: { 'status_id' => status_id }
      res.item
    end
  end
end
