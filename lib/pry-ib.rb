# pry-ib plugin
require 'pry'
require_relative 'pry-ib/version'
require_relative'pry-ib/alert'
require_relative 'pry-ib/account'
require_relative 'pry-ib/commands'
require_relative 'pry-ib/connection'
require_relative 'pry-ib/contract'
require_relative 'pry-ib/tick'
require_relative 'pry-ib/security'
require_relative 'pry-ib/history'
require_relative 'pry-ib/chart'
require_relative 'pry-ib/order'
require_relative 'pry-ib/bracket'
require_relative 'pry-ib/real_time_quote'
require_relative 'pry-ib/scanner'
require_relative 'pry-ib/util/time_util'

require 'pry-ib/mongo/connection'
#require 'pry-ib/mongo/quote'



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


# mongo connectin
PryIb::Mongo::connect

# Startup sanity check
Pry.config.ib_test ||= false
puts "Loading pry-ib 8;  ib_test:#{Pry.config.ib_test}"


#Pry.config.prompt = proc { "IB> " }
Pry.config.prompt = proc { |obj, nest_level, _| "IB: #{obj}(#{nest_level})> " }
#Pry.config.color = true

Pry.config.commands.import PryIb::Commands
Pry.config.commands.alias_command "live", "connection -l"
Pry.config.commands.alias_command "test", "connection -t"
Pry.config.commands.alias_command "gate", "connection -g"
Pry.config.commands.alias_command "alias", "help Aliases"
Pry.config.commands.alias_command "ibhelp", "help pry-ib"
Pry.config.commands.alias_command "h3",   "hist -T 3"
Pry.config.commands.alias_command "h5",   "hist -T 5"
Pry.config.commands.alias_command "h10",  "hist -T 10"
Pry.config.commands.alias_command "h20",  "hist -T 20"
Pry.config.commands.alias_command "h50",  "hist -T 50"
Pry.config.commands.alias_command "bb", 'bracket #{@symbol}  --price #{@price} --stop #{@stop} --profit #{@profit} --quantity #{@quantity} --account #{@account}'

