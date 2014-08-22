

module PryIb
    def self.hello
      puts "Hello from pry-ib"
    end

    Commands = Pry::CommandSet.new do

        create_command "subs" do
          description "Enable IB alerts"
          group 'pry-ib'

          def process
            ib = PryIb::Connection::current
            ib.subscribe(:Alert) { |msg| output.puts "Alert> #{msg.to_human}" }
            output.puts "Alert Subcribe enabled"
          end
        end

        create_command "order" do
          description "Get order status"
          group 'pry-ib'
          def options(opt)
            opt.on :x,:cancel, 'cancel ALL orders'
            opt.on :s, :show, 'show open orders (default)'
          end

          def process
            ib = PryIb::Connection::current
            order = PryIb::Order.new(ib)
            if opts.cancel?
              order.cancel_orders
              return
            end
            order.list_orders
          end
        end

        create_command "chart" do
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
            ib = PryIb::Connection::current
            period = '5min'
            period = '1min' if opts.m1?
            period = '5min' if opts.m5?
            period = '1hour' if opts.h1?
            period = '2hour' if opts.h2?
            period = 'day' if opts.day?
            period = 'week' if opts.week?

            output.puts "Chart: #{symbol} period:#{period}"
            chart = PryIb::Chart.new(ib,symbol)
            chart.open(period)
          end
        end


        create_command "account" do
          description "Get account info"
          banner <<-BANNER
            Usage: account acct_code 
            Example: 
              account U964242 
          BANNER
          group 'pry-ib'

          def options(opt)
            opt.on :l,:list, 'list accounts'
          end

          def process
            ib = PryIb::Connection::current
            account = PryIb::Account.new(ib)

            if opts.list?
              account.list
              return
            end

            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            code = args.first || ''
            account.info(code)
          end
        end

        create_command "alert" do
          description "Setup an alert"
          banner <<-BANNER
            Usage: alert symbol | { |bar| bar.close > 42 }
            Example: 
              alert aapl | { |bar| bar.close > 42 }
          BANNER
          group 'pry-ib'
          command_options(
            :use_prefix => false,
            :takes_block => true,
          )

          def options(opt)
            opt.on :name=, 'set alert name'
            opt.on :l,:list, 'list alerts'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first

            if opts.name?
            end
            if opts.name?
              @name = opts[:name]
              output.puts "Set name: #{@name}"
            end

            if command_block
              @test = command_block
              log(">> test proc: #{@test.inspect}")
            end
            ib = PryIb::Connection::current
            alert = PryIb::Alert.new(ib)
            alert.alert(symbol, &command_block)
          end
        end

        create_command "tick" do
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

        create_command "real" do
          description "Get Real Time quote"
          group 'pry-ib'
          def options(opt)
            opt.on :num=, 'Number of quotes. (Default: 60)'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            num_quotes = 60
            if opts.num?
              num_quotes = opts[:num].to_i
            end
            ib = PryIb::Connection::current
            output.puts "Quote: #{symbol} Num Quotes:#{num_quotes}"
            real = PryIb::RealTimeQuote.new(ib)
            real.quote(symbol,num_quotes)
          end
        end

        create_command "quote" do
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


        create_command "bracket" do
          description 'Execute Bracket order'
          banner <<-BANNER
            Usage: bracket [ --quantiy <amount> ] [ --price <entry price> ] [ --stop <stop price> ][ --profit <profit price> ] [ --type <order type>] [ -l | -s ] [ --account <code> ] <symbol>
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

          end

          def options(opt)
            opt.on :quantity=,'set quantity (default: 100)'
            opt.on :price=,   'set order limit price'
            opt.on :stop=,    'set stop price'
            opt.on :profit=,  'set profit target price'
            opt.on :type=,    'set order type  (MKT, LMT, STP) default LMT'
            opt.on :account=, 'set account'
            opt.on :s,:short, 'use short direction'
            opt.on :l,:long,  'use long direction'
            opt.on :c,:create,  'Create bracket order but do not execute'
          end

          def process
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


            @bracket = PryIb::BracketOrder.new(ib,symbol,@account)
            @bracket.setup( @quantity, @order_price, @stop_price,
                             @profit_price, @order_type, @direction )

            @bracket.send_order unless opts.create?

            @bracket
          end
        end


        # connection
        create_command "connection" do
          description "connection -- manage IB client connection"
          group 'pry-ib'
          def setup
            @service = nil
          end

          def set_prompt(name="")
            #Pry.config.prompt = proc { |obj, nest_level, _| "IB(#{name}: #{obj}(#{nest_level})> " }
            _pry_.prompt = proc { |obj, nest_level, _| "IB(#{name}): #{obj}(#{nest_level})> " }
          end

          def options(opt)
            opt.on :s, :show, "show services"
            opt.on :c, :close, "close current connection"
            opt.on :o, :host, "host"
            opt.on :b, :subs, "subscribers"
            opt.on :u, :unsub=, "unsubscribe id"
            opt.on :service=, 'set Service name'
            opt.on :l, :live, "use Live Service"
            opt.on :t, :test,  "use Test Service"
            opt.on :g,:gateway, "use Gateway Service"
          end

          def process
            if opts.show?
              output.puts "Current Service:#{ PryIb::Connection::service}"
              PryIb::Connection::TWS_SERVICE_PORTS.each do |key, val|
                output.puts "Service: #{key} Port:#{val}"
              end
              return
            end
            if opts.host?
              output.puts "--->"
              output.puts "Host: #{PryIb::Connection::TWS_HOST}"
              return
            end
            if opts.close?
              output.puts "--->"
              output.puts "Close: #{PryIb::Connection::service}"
              set_prompt ""
              PryIb::Connection::close
              return
            end
            if opts.subs?
              output.puts "--->"
              PryIb::Connection::subscribers
              return
            end
            if opts.unsub?
              @unsub_id = opts[:unsub].to_i
              output.puts "Unsuscribe #{@unsub_id}"
              PryIb::Connection::unsubscribe @unsub_id
              return
            end

            # make new service connection
            if opts.service?
              @service = opts[:service].to_sym
              output.puts "Set service: #{@service}"
            elsif opts.live?
              output.puts "Live service "
              @service = :tws_live
              set_prompt "LIVE"
            elsif opts.test? || opts.test?
              @service = :tws_test
              set_prompt "TEST"
            elsif opts.gateway?
              @service = :tws_gateway
              set_prompt "GATE"
            end

            if @service
              #output.puts "Set service: #{@service}"
              return PryIb::Connection::connection( @service )
            end

            # return current connection
            ib = PryIb::Connection::current
            if ib
              output.puts "Use current connection"
            else
              output.puts "No current connection"
            end
            return ib 
          end
        end

    end
end 
