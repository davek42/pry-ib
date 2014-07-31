# pry-ib plugin
require 'pry'
require 'pry-ib/version'
require 'pry-ib/commands'

puts "Loading pry-ib 5"
#Pry.config.prompt = proc { "IB> " }
Pry.config.prompt = proc { |obj, nest_level, _| "IB: #{obj}(#{nest_level})> " }
