
module PryIb
  module Command
    module Tick
      def self.build(commands)
        commands.create_command "tick" do
          description "Get Tick quote"
          group 'pry-ib'
          def options(opt)
            opt.on :num=, 'Number of ticks. (Default: 2)'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            num_ticks = 2
            if opts.num?
              num_ticks = opts[:num].to_i
            end
            ib = PryIb::Connection::current
            output.puts "Tick: #{symbol} Num Ticks:#{num_ticks}"
            tick = PryIb::Tick.new(ib)
            tick.tick(symbol,num_ticks)

          end
        end

      end
    end
  end
end
