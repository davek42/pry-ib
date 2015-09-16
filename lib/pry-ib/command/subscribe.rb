
module PryIb
  module Command
    module Subscribe
      def self.build(commands)
        commands.create_command "subs" do
          description "Enable IB alerts"
          group 'pry-ib'

          def process
            ib = PryIb::Connection::current
            ib.subscribe(:Alert) { |msg| output.puts "Alert> #{msg.to_human}" }
            output.puts "Alert Subcribe enabled"
          end
        end
      end
    end
  end
end

