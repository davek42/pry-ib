# coding: utf-8

require 'pry'

module PryIb


  Commands = Pry::CommandSet.new do
    block_command 'hellopry', 'Hello Pry' do |steps|
       output.puts "Hello world. Hello pry."
    end
#    add_command( PryIb::Command::HelloPry )
  end

  class Command::HelloPry < Pry::ClassCommand
    description 'Say hello to prybreakout_navigation'
    match 'hellopry'
    banner <<-'BANNER'
      Say hello to pry for fun
    BANNER
    def process(command_set_name)
       output.puts "Hello world. Hello pry."
    end
      
  end

# Pry::Commands.add_command(PryIb::Command::PryIb)

#  Command = Class.new  # ?
#  module Command
#  class Command::PryIb < Pry::ClassCommand
#    include Pry::Helpers::BaseHelpers
#    include Pry::Helpers::CommandHelpers
#
#    match 'pry-ib'
#    description 'pry-ib'
#
#    banner <<-'BANNER'
#      Usage: pry-ib [OPTIONS] [--help]
#    BANNER
#
#    def setup
#    end
#
#    def def_hellotest(cmd)
#      cmd.command :hellotest do |opt|
#        opt.description 'Show Hello information '
#
#        opt.run do | opts, args |
#          output.puts "helloworld"
#        end
#      end
#
#    end
#
#    def def_connect(cmd)
#      
#    end
#
#    def subcommands(cmd)
#      [:def_hellotest, 
#      ].each { |m| __send__(m, cmd) }
#
#      cmd.add_callback(:empty) do
#        stagger_output opts.help
#      end
#    end
#
#    def process
#    end
#
#  end
#  end

#  Pry::Commands.add_command(PryIb::Command::PryIb)
end

Pry.commands.import PryIb::Commands
