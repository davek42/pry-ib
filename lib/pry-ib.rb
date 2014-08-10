# pry-ib plugin
require 'pry'
require 'pry-ib/version'
require 'pry-ib/commands'
require 'pry-ib/connection'
require 'pry-ib/tick'
require 'pry-ib/security'
require 'pry-ib/history'
require 'pry-ib/util/time_util'



module PryIb
  def self.log(message)
    Pry.output.puts(">> #{ message}")
  end
end


puts "Loading pry-ib 7"
#Pry.config.prompt = proc { "IB> " }
Pry.config.prompt = proc { |obj, nest_level, _| "IB: #{obj}(#{nest_level})> " }
#Pry.config.color = true

Pry.config.commands.import PryIb::Commands

