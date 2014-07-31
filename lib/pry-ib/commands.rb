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
          description "connection -- create IB client connection"

          def process
            output.puts "--->"
            output.puts "Host: #{PryIb::Util::TWS_HOST}"
          end
        end

    end
end 
