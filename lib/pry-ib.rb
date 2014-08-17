# pry-ib plugin
require 'pry'
require 'pry-ib/version'
require 'pry-ib/commands'
require 'pry-ib/connection'
require 'pry-ib/tick'
require 'pry-ib/security'
require 'pry-ib/history'
require 'pry-ib/order'
require 'pry-ib/bracket'
require 'pry-ib/real_time_quote'
require 'pry-ib/util/time_util'



module PryIb
  @@request_id = 100
  def self.log(message)
    Pry.output.puts(">> #{ message}")
  end

  def self.request_id
    @@request_id
  end

  def self.next_request_id
    @@request_id += 1
  end

end

# configuration
PryIb::Connection::setup

# Startup sanity check
Pry.config.ib_test ||= false
puts "Loading pry-ib 8;  ib_test:#{Pry.config.ib_test}"


#Pry.config.prompt = proc { "IB> " }
Pry.config.prompt = proc { |obj, nest_level, _| "IB: #{obj}(#{nest_level})> " }
#Pry.config.color = true

Pry.config.commands.import PryIb::Commands

