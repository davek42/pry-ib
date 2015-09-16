
module PryIb
  module Command
    module Account
      def self.build(commands)
        commands.create_command "account" do
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
      end
    end
  end
end
