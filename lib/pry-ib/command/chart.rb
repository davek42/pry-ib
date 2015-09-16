
module PryIb
  module Command
    module Chart
      def self.build(commands)
        commands.create_command "chart" do
          description "Get Chart from stock quotes"
          group 'pry-ib'

          def options(opt)
            opt.on :m1, 'use 1 min period'
            opt.on :m5, 'use 5 min period'
            opt.on :h1, 'use one hour period'
            opt.on :h2, 'use two hour period'
            opt.on :d,:day, 'use day period'
            opt.on :w,:week, 'use week period'
          end
          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            #ib = PryIb::Connection::current
            period = '5min'
            period = '1min' if opts.m1?
            period = '5min' if opts.m5?
            period = '1hour' if opts.h1?
            period = '2hour' if opts.h2?
            period = 'day' if opts.day?
            period = 'week' if opts.week?

            output.puts "Chart: #{symbol} period:#{period}"
            chart = PryIb::Chart.new(nil,symbol)
            chart.open(period)
          end
        end
      end
    end
  end
end
