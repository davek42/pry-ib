require_relative 'account'
require_relative 'alert'
require_relative 'bracket'
require_relative 'chart'
require_relative 'connection'
require_relative 'contract'
require_relative 'order'
require_relative 'quote'
require_relative 'real'
require_relative 'scan'
require_relative 'stat'
require_relative 'subscribe'
require_relative 'tick'

module PryIb

    def self.hello
      puts "Hello from pry-ib"
    end

    Commands = Pry::CommandSet.new

    PryIb::Command::Account.build(Commands)
    PryIb::Command::Alert.build(Commands)
    PryIb::Command::Bracket.build(Commands)
    PryIb::Command::Chart.build(Commands)
    PryIb::Command::Connection.build(Commands)
    PryIb::Command::Contract.build(Commands)
    PryIb::Command::Order.build(Commands)
    PryIb::Command::Real.build(Commands)
    PryIb::Command::Quote.build(Commands)
    PryIb::Command::Subscribe.build(Commands)
    PryIb::Command::Scan.build(Commands)
    PryIb::Command::Stat.build(Commands)
    PryIb::Command::Tick.build(Commands)
end 
