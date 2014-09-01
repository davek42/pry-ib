# Order status routines
#
require 'mongo'

module PryIb
  module Mongo

    ### Standard URI format: mongodb://[dbuser:dbpassword@]host:port/dbname
    DEFAULT_URI =  "mongodb://127.0.0.1:27017/pryib"


    DB_NAME = 'pryib'
    @@conn = nil
    @@uri = DEFAULT_URI




    def self.connect(uri=nil)
      return @@conn if @@conn
      get_db_name
      @@uri ||= uri || DEFAUL_URI
      puts "---> do connection. #{@@uri}"
      @@conn = ::Mongo::MongoClient.from_uri(@@uri)
    end 

    def self.close
      @@conn.close if @conn
      @@conn = nil
    end

    def self.get_db(conn=nil)
      conn = self.connect if conn.nil?
      @@db = conn.db(@@db_name)
    end



    def self.uri 
      @@uri ||= Pry.config.mongo_uri || DEFAULT_URI
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
