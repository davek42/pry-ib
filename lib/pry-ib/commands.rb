

module PryIb
    def self.hello
      puts "Hello from pry-ib"
    end

    Commands = Pry::CommandSet.new do
        create_command "echo" do
          description "DK - Echo the input: echo [ARGS]"

          def process
            output.puts "ARGS: #{args.join(' ')}"
          end
        end

        create_command "alerts" do
          description "Enable IB alerts"

          def process
            ib = PryIb::Connection::current
            ib.subscribe(:Alert) { |msg| output.puts "Alert> #{msg.to_human}" }
            output.puts "Alert Subcribe enabled"
          end
        end

        create_command "tick" do
          description "Get Tick quote"

          def process
            raise Pry::CommandError, "Need a least one symbol" if args.size == 0
            symbol = args.first
            ib = PryIb::Connection::current
            output.puts "Tick: #{symbol}"
            tick = PryIb::Tick.new(ib)
            tick.tick(symbol)

          end
        end

        create_command "quote" do
          description "Get quote history"
          command_options(
            :keep_retval => true
          )

          def setup
            @duration = '1 D'
            @bar_size = '5 mins'
            @stats_only = false
            @quotes = {}
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
            @quotes = hist.quote(symbol,@duration,@bar_size,@stats_only)
            @quotes
          end
        end

        # connection
        create_command "connection" do
          description "connection -- manage IB client connection"
          def setup
            @service = nil
          end

          def options(opt)
            opt.on :s, :show, "show services"
            opt.on :o, :host, "host"
            opt.on :service=, 'set Service name'
            opt.on :l, :live, "use Live Service"
            opt.on :t, :test, :demo, "use Demo (Test) Service"
            opt.on :g,:gateway, "use Gateway Service"
          end

          def process
            if opts.show?
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

            # make new service connection
            if opts.service?
              @service = opts[:service].to_sym
              output.puts "Set service: #{@service}"
            elsif opts.live?
              output.puts "Live service "
              @service = :tws_live
            elsif opts.test? || opts.demo?
              @service = :tws_demo
            elsif opts.gateway?
              @service = :tws_gateway
            end

            if @service
              output.puts "Set service: #{@service}"
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
