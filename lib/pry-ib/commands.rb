# coding: utf-8

module PryIb

  Command = Class.new  # ?

#  module Command
  class Command::PryIb < Pry::ClassCommand
    include Pry::Helpers::BaseHelpers
    include Pry::Helpers::CommandHelpers

    match 'pry-ib'
    description 'pry-ib'

    banner <<-'BANNER'
      Usage: pry-ib [OPTIONS] [--help]
    BANNER

    def setup
    end

    def def_hellotest(cmd)
      cmd.command :hellotest do |opt|
        opt.description 'Show Hello information '

        opt.run do | opts, args |
          output.puts "helloworld"
        end
      end

    end

    def subcommands(cmd)
      [:def_hellotest, 
      ].each { |m| __send__(m, cmd) }

      cmd.add_callback(:empty) do
        stagger_output opts.help
      end
    end

    def process
    end

  end
#  end

  Pry::Commands.add_command(PryIb::Command::PryIb)
end
