
module PryIb
  module Command
    module Quote
      def self.build(commands)
        commands.create_command "quote" do
          description "Get quote history"
          group 'pry-ib'
          command_options(
            :keep_retval => true
          )

          def setup
            @duration = '1 D'
            @bar_size = '5 mins'
            @stats_only = false
            @quote_hist = {}
          end
          def options(opt)
            opt.on :i, :info, 'show bar options'
            opt.on :s, :stats, 'show stats only'
            opt.on :duration=, 'set duratin value'
            opt.on :bar=, 'set bar size value'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if opts.to_hash.size == 0 && args.size == 0

            if opts.info?
              bar_opts = %{
     :duration => String, time span the request will cover, and is specified
                using the format: <integer> <unit>, eg: '1 D', valid units are:
                      '1 S' (seconds, default if no unit is specified)
                      '1 D' (days)
                      '1 W' (weeks)
                      '1 M' (months)
                      '1 Y' (years, currently limited to one)
     :bar_size => String: Specifies the size of the bars that will be returned
               (within IB/TWS limits). Valid values include:
                     '1 sec'
                     '5 secs'
                     '15 secs'
                     '30 secs'
                     '1 min'
                     '2 mins'
                     '3 mins'
                     '5 mins'
                     '15 mins'
                     '30 min'
                     '1 hour'
                     '1 day'
              }
              output.puts " #{bar_opts}"
              return
            end

            if opts.duration?
              @duration = opts[:duration]
              output.puts "Set duration: #{@duration}"
            end
            if opts.bar?
              @bar_size = opts[:bar]
              output.puts "Set bar size: #{@bar_size}"
            end
            if opts.stats?
              @stats_only = true
            end


            symbol = args.first
            ib = PryIb::Connection::current
            output.puts "Quote: #{symbol}"
            hist = PryIb::History.new(ib)
            @quote_hist = hist.quote(symbol,@duration,@bar_size,@stats_only)
            (@stats_only) ? nil : @quote_hist
          end
        end
      end
    end
  end
end
