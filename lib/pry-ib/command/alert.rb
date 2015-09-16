
module PryIb
  module Command
    module Alert
      def self.build(commands)
        commands.create_command "alert" do
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

      end
    end
  end
end
