
module PryIb
  module Command
    module Order
      def self.build(commands)
        commands.create_command "order" do
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
      end
    end
  end
end
