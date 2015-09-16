
module PryIb
  module Command
    module Stat
      def self.build(commands)
        commands.create_command "stat" do
          description "Get Real Time Stats"
          banner <<-BANNER
            Get Real Time Stats
            Usage: stat [--num <num quotes>] [ --atr <period> ] [ --bs <bar size> ] <symbol_format>
                    #  Types:  :s - stock, :f - future, :o - option
                    #  Expiry:  YYYYMM
                symbol format:  <string>   # default as stock ticker
                symbol format:  :type:ticker
                symbol format:  :type:ticker:expriy
            Example: 
              stat AAPL
              stat --atr 14 --num 500 AAPL
              stat :f:es:201409 # E-mini with expiry 2014-09
          BANNER
          group 'pry-ib'
          def options(opt)
            opt.on :atr=, 'Get ATR with period', as: Array, delimiter: ','
            opt.on :mfi=, 'Get MFI with period', as: Array, delimiter: ','
            opt.on :num=, 'Number of quotes. (Default: 200)'
            opt.on :bs=,  'Bar size  (Default: 5)'
            opt.on :min,  'Bar size  60 seconds'
            opt.on :v,:verbose, 'Verbose display'
          end

          def setup
            @parms = {}
            @num_quotes = 200
            @bar_size = 5
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            verbose = (opts.verbose?) ? true : false

            @bar_size = 60  if opts.min?
            @bar_size = opts[:bs].to_i if opts.bs?
            @num_quotes = opts[:num].to_i if opts.num?
            @parms[:atr] = opts[:atr].map!(&:to_i) if opts.atr?
            @parms[:mfi] = opts[:mfi].map!(&:to_i) if opts.mfi?
            @parms[:bar_size] = @bar_size

            ib = PryIb::Connection::current
            output.puts "Quote: #{symbol} Parms:#{@parms.inspect}"
            stat = PryIb::RealTimeStat.new(ib,:verbose => verbose)
            stat.quote(symbol,@num_quotes,@parms)
          end
        end
      end
    end
  end
end
