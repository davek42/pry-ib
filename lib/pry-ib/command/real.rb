
module PryIb
  module Command
    module Real
      def self.build(commands)
        commands.create_command "real" do
          description "Get Real Time quote"
          banner <<-BANNER
            Usage: real [ --num <num quotes> ] <symbol_format>
                    #  Types:  :s - stock, :f - future, :o - option
                    #  Expiry:  YYYYMM
                symbol format:  <string>   # default as stock ticker
                symbol format:  :type:ticker
                symbol format:  :type:ticker:expriy
            Example: 
              real AAPL
              real --num 200 AAPL
              real :s:aapl      # AAPL stock
              real :f:es        # E-mini with default set to next expiry
              real :f:es:201409 # E-mini with expiry 2014-09
          BANNER
          group 'pry-ib'
          def options(opt)
            opt.on :num=, 'Number of quotes. (Default: 200)'
            opt.on :v,:verbose, 'Verbose display'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            verbose = (opts.verbose?) ? true : false
            num_quotes = 200
            if opts.num?
              num_quotes = opts[:num].to_i
            end
            ib = PryIb::Connection::current
            output.puts "Quote: #{symbol} Num Quotes:#{num_quotes}"
            real = PryIb::RealTimeQuote.new(ib,:verbose => verbose)
            real.quote(symbol,num_quotes)
          end
        end
      end
    end
  end
end
