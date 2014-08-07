#require "pry/ib/version"

module PryIb
    # Your code goes here...
    def self.hello
      puts "Hello from pry-ib"
    end

    Commands = Pry::CommandSet.new do
        create_command "echo" do
          description "DK - Echo the input: echo [ARGS]"

          def process
            output.puts "--->"
            output.puts "ARGS: #{args.join(' ')}"
          end
        end


        # connection
        create_command "connection" do
          description "connection -- manage IB client connection"
          def setup
            @service = :tws_demo
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
            output.puts "service: #{@service}"
            PryIb::Connection::connection( @service )
          end
        end

    end
end 
