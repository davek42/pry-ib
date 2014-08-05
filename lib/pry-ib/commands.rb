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
          def options(opt)
            opt.on :s, :services, "list services"
            opt.on :o, :host, "host"
          end

          def process
            if opts.services?
              PryIb::Connection::TWS_SERVICE_PORTS.each do |key, val|
                output.puts "Service: #{key} Port:#{val}"
              end

            end
            if opts.host?
              output.puts "--->"
              output.puts "Host: #{PryIb::Connection::TWS_HOST}"
            end
          end
        end

    end
end 
