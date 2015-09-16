
module PryIb
  module Command
    module Contract
      def self.build(commands)
        commands.create_command "contract" do
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
              contract = PryIb::Contract.new(ib,symbol)
            end
            output.puts "Quote: #{symbol} Type:#{contract.class.name}"
            contract.detail
          end
        end
      end
    end
  end
end
