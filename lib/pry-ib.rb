# pry-ib plugin
require 'pry'
require 'pry-ib/version'
require 'pry-ib/alert'
require 'pry-ib/account'
require 'pry-ib/commands'
require 'pry-ib/connection'
require 'pry-ib/contract'
require 'pry-ib/tick'
require 'pry-ib/security'
require 'pry-ib/history'
require 'pry-ib/chart'
require 'pry-ib/order'
require 'pry-ib/bracket'
require 'pry-ib/real_time_quote'
require 'pry-ib/scanner'
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
Pry.config.commands.alias_command "live", "connection -l"
Pry.config.commands.alias_command "test", "connection -t"
Pry.config.commands.alias_command "alias", "help Aliases"
Pry.config.commands.alias_command "ibhelp", "help pry-ib"
Pry.config.commands.alias_command "h3",   "hist -T 3"
Pry.config.commands.alias_command "h5",   "hist -T 5"
Pry.config.commands.alias_command "h10",  "hist -T 10"
Pry.config.commands.alias_command "h20",  "hist -T 20"
Pry.config.commands.alias_command "h50",  "hist -T 50"

