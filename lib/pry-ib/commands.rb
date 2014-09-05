# Pry-ib commands

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

        create_command "scan" do
          description "Run scanneer"
          group 'pry-ib'
          def options(opt)
            opt.on :num=, 'Number of rows (Default 20)'
            opt.on :above=, 'Price above (Default 10)'
            opt.on :vol=, 'Volume above (Default 10000)'
          end

          def process
            ib = PryIb::Connection::current

            num_rows = (opts.num?) ? opts[:num].to_i : 20
            above = (opts.above?) ? opts[:above].to_f  : 10.0
            volume = (opts.vol?) ? opts[:volume].to_i  : 10000
            parms = { 
              num_rows: num_rows, 
              scan_code: 'TOP_PERC_GAIN', 
              above_price: above, 
              location_code: 'STK.US.MAJOR', 
              above_volume: volume, 
            }
            scanner = PryIb::Scanner.new(ib)
            scanner.scan(parms)
          end
        end

        create_command "order" do
          description "Get order status"
          group 'pry-ib'
          def options(opt)
            opt.on :x,:cancel, 'cancel ALL orders'
            opt.on :s, :show, 'show open orders (default)'
            opt.on :sym=, 'Only show for symbol'
          end

          def process
            ib = PryIb::Connection::current
            order = PryIb::Order.new(ib)
            if opts.cancel?
              order.cancel_orders
              return
            end
            if opts.sym?

            end
            sym = (opts.sym?) ? opts[:sym].upcase : nil
            order.list_orders(sym)
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

        create_command "database" do
          description "database -- manage database connection"
          group 'pry-ib'
          def setup
            @service = nil
          end

          def options(opt)
#            opt.on :service=,  'set Service name'
            opt.on :s, :show,  'show service and uri'
            opt.on :c, :close, 'close current connection'
            opt.on :l, :live,  'use Live Service'
            opt.on :t, :test,  'use Test Service'
            opt.on :g,:gateway, 'use Gateway Service'
            opt.on :u,:uri,    'show mongo db uri'
            opt.on :p,:ping,   'ping mongo db'
            opt.on :c,:collections, 'show collections'
          end

          def process

            PryIb::Mongo::connect(:ib_live) if opts.live?
            PryIb::Mongo::connect(:ib_test) if opts.test?
            PryIb::Mongo::connect(:ib_gateway) if opts.gateway?

            if opts.show?
              serv = PryIb::Mongo::service
              log "DB service: #{serv} "
              log "  URI: #{PryIb::Mongo::uri}" if serv
              return
            end
            if opts.ping?
              ping = PryIb::Mongo::ping
              log "Ping: #{ping.inspect}"
              return ping
            end
            if opts.collections?
              cc = PryIb::Mongo::collections
              log "Collections: #{cc.inspect}"
              return ping
            end

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

        create_command "contract" do
          description "Get Contract info"
          group 'pry-ib'
          def options(opt)
            opt.on :c,:currency, 'currency'
            opt.on :f,:future, 'future'
            opt.on :o,:option, 'option'
            opt.on :s,:stock, 'stock (Default)'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            type = :stock
            ib = PryIb::Connection::current
            if opts.stock?
              contract = PryIb::StockContract.new(ib,symbol)
            elsif opts.future?
              contract = PryIb::FutureContract.new(ib,symbol)
            else
              # FIME:  assume stock
              log "WARNING. FIXME.  Assume contract as Stock"
              contract = PryIb::StockContract.new(ib,symbol)
            end
            output.puts "Quote: #{symbol} Type:#{contract.class.name}"
            contract.detail
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
            opt.on :s,:sound, 'Use audio alert'
          end

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            sound = (opts.sound?) ? true : false
            name =  (opts.name?)  ? opts[:name] : nil

            if command_block
              @test = command_block
              log(">> test proc: #{@test.inspect}")
            end
            ib = PryIb::Connection::current
            alert = PryIb::Alert.new(ib, :sound => sound, :name => name)
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
            opt.on :p, :persist, 'persist to db'
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

            if opts.persist?
              bars = @quote_hist.first.last
              bars.each do |bar|
                #puts ">> #{bar.inspect} "
                PryIb::Mongo::Quote.new.save_bar(symbol,bar)
              end
            end

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


            @bracket = PryIb::BracketOrder.new(ib,:symbol => symbol, :account => @account)
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
              output.puts "Current Service:#{ PryIb::Connection::service} "
              output.puts "Current connection client_id: #{PryIb::Connection::current.client_id}"
              PryIb::Connection::SERVICE_PORTS.each do |key, val|
                current = (key == PryIb::Connection::service) ? "(Active)" : ""
                output.puts "Service: #{key} Port:#{val}  #{current}"
              end
              return
            end
            if opts.host?
              output.puts "--->"
              output.puts "Host: #{PryIb::Connection::host}"
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
              @service = :ib_live
              set_prompt "LIVE"
            elsif opts.test? || opts.test?
              @service = :ib_test
              set_prompt "TEST"
            elsif opts.gateway?
              @service = :ib_gateway
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
