
module PryIb
  module Command
    module Bracket
      def self.build(commands)
        commands.create_command "bracket" do
          description 'Execute Bracket order'
          banner <<-BANNER
            Usage: bracket [ --quantiy <amount> ] [ --price <entry price> ] [ --stop <stop price> ][ --profit <profit price> ] [ --type <order type>] [--tif <tif code>] [ -l | -s ] [ --account <code> ] <symbol>
            Example: 
              bracket --quantity 200 --price 42.10 --stop 40.00 --profit 44.00 -l -type LMT AAPL
              bracket  --price 100.36 --stop 100.05 --profit 100.50 --account U96711   AAPL
          BANNER
          group 'pry-ib'
          command_options(
            :keep_retval => true
          )

          def setup
            @quantity = 100
            @order_price = nil
            @stop_price = nil
            @profit_price = nil
            @order_type = 'LMT'
            @direction = :long
            @tif = 'DAY'

          end

          def options(opt)
            opt.on :quantity=,'set quantity (default: 100)'
            opt.on :price=,   'set order limit price'
            opt.on :stop=,    'set stop price'
            opt.on :profit=,  'set profit target price'
            opt.on :type=,    'set order type  (MKT, LMT, STP) default LMT'
            opt.on :account=, 'set account'
            opt.on :tif=,     'set time in force (DAY,GAT,GTD,GTC,IOC)'
            opt.on :s,:short, 'use short direction'
            opt.on :l,:long,  'use long direction'
            opt.on :c,:create,  'Create bracket order but do not execute'
            opt.on :list,  'list bracket orders'
            opt.on :last,     'last bracket orders'
          end

          def process
            if opts.list?
              PryIb::BracketOrder.list
              return PryIb::BracketOrder.last
            end
            if opts.last?
              return PryIb::BracketOrder.last
            end

            #
            raise Pry::CommandError, "Need a least one symbol" if opts.to_hash.size == 0 && args.size == 0
            symbol = args.first
            ib = PryIb::Connection::current
            output.puts "Bracket: #{symbol}"


            if opts.quantity?
              @quantity = opts[:quantity].to_i
              output.puts "Set quantity: #{@quantity}"
            end
            if opts.price?
              @order_price = opts[:price].to_f
              output.puts "Set order_price: #{@order_price}"
            end
            if opts.stop?
              @stop_price = opts[:stop].to_f
              output.puts "Set stop_price: #{@stop_price}"
            end
            if opts.profit?
              @profit_price = opts[:profit].to_f
              output.puts "Set profit_price: #{@profit_price}"
            end
            if opts.type?
              @order_type = opts[:type]
              output.puts "Set order_type: #{@order_type}"
            end
            if opts.account?
              @account = opts[:account]
              output.puts "Set account: #{@account}"
            end
            if opts.tif?
              @tif = opts[:tif].upcase
              output.puts "Set tif: #{@tif}"
            end
            @direction = :long if opts.long?
            @direction = :short if opts.short?


            @bracket = PryIb::BracketOrder.new(ib,:symbol => symbol, :account => @account)
            @bracket.setup( @quantity, @order_price, @stop_price,
                             @profit_price, @order_type, @tif, @direction )

            @bracket.send_order unless opts.create?

            @bracket
          end
        end
      end
    end
  end
end
