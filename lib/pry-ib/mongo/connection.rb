# Order status routines
#
require 'mongo'

module PryIb
  module Mongo

    ### Standard URI format: mongodb://[dbuser:dbpassword@]host:port/dbname
    DEFAULT_URI =  "mongodb://127.0.0.1:27017/pryib"

    @@service_uri = { ib_live:  DEFAULT_URI,
                      ib_test:  DEFAULT_URI,
                      ib_gateway: DEFAULT_URI }


    DB_NAME = 'pryib'
    @@conn = nil
    @@uri = DEFAULT_URI
    @@service = nil



    def self.setup
      @@service_uri[:ib_live] = Pry.config.mongo_live || DEFAULT_URI
      @@service_uri[:ib_test] = Pry.config.mongo_test || DEFAULT_URI
      @@service_uri[:ib_gateway] = Pry.config.mongo_gateway || DEFAULT_URI
    end

    def self.connect(service)
      close if @@conn
      @@service = service
      @@uri = @@service_uri[service]
      puts "---> do connection. #{@@uri}"
      @@conn = ::Mongo::MongoClient.from_uri(@@uri)
    end 

    def self.close
      @@conn.close if @conn
      @@conn = nil
    end

    def self.current
      return @@conn if @@conn
      connect(@@service)
    end 

    def self.currnet_db(conn=nil)
      conn = self.connect(@@service) if conn.nil?
      @@db = conn.db(@@db_name)
    end


    def self.service
      @@service
    end
    def self.service=(serv)
      @@service = serv
    end

    def self.current
      return @@conn unless @@conn.nil?
      connection(@@service)
    end


    def self.uri 
      @@uri = Pry.config.mongo_uri || DEFAULT_URI
    end

    ### Standard URI format: mongodb://[dbuser:dbpassword@]host:port/dbname
    def self.uri=(uri)
      @@uri = uri || DEFAULT_URI
    end

    def self.get_db_name
      @@db_name = @@uri.match(/mongodb:\S*\/(\S*)$/).captures
    end

    def self.ping
     @@conn.ping 
    end

    def self.db_names
      @@conn.database_names
    end

    def self.collections
      get_db.collection_names
    end


  end
end
