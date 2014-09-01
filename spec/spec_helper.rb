#$:.each { |path| puts ">> #{path}" }

require_relative '../lib/pry-ib.rb'
require 'pry/test/helper'


#
PryIb::Mongo::settings =
    {"sessions"=>{
      "default"=>{"database"=>"pryib-test",
                  "hosts"=>["127.0.0.1:27017"],
    }}}
PryIb::Mongo::connect

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].start
  end

  config.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end
end


#
puts( %{
  -------------------------------------------------
  Ruby: #{RUBY_VERSION};
  Ruby Engine: #{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'}
  PryIb : #{PryIb::VERSION}
  -------------------------------------------------
}
)
