# Order status routines
#
require 'mongoid'

module PryIb
  module Mongo

    # See http://mongoid.org/en/mongoid/docs/installation.html#configuration
    DEFAULT_SETTING = {"sessions"=>{
      "default"=>{"database"=>"pryib",
                  "hosts"=>["127.0.0.1:27017"],
    }}}


    def self.connect
      Mongoid.load_configuration(settings)
    end

    def self.settings 
      @@settings ||= Pry.config.mongo_settings || DEFAULT_SETTING
    end

    def self.settings=(settings)
      @@settings = settings || DEFAULT_SETTING
    end

    def self.ping
      Mongoid.default_session.command(ping: 1)
    end

    def self.collections
      Mongoid.default_session.collection_names
    end


  end
end
