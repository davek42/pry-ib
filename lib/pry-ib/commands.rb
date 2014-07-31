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
    end
end 
