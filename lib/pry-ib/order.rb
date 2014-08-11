
# Order status routines
#
require 'ib-ruby'

module PryIb
  class Order


    def initialize( ib )
      @ib = ib
    end

    def list_orders
      # Subscribe to TWS alerts/errors and order-related messages
      @counter = 0

      @ib.subscribe(:Alert, :OrderStatus, :OpenOrderEnd) { |msg| log msg.to_human }

      @ib.subscribe(:OpenOrder) do |msg|
        @counter += 1
        log "#{@counter}: #{msg.to_human}"
      end

      @ib.send_message :RequestAllOpenOrders

      # Wait for IB to respond to our request
      @ib.wait_for :OpenOrderEnd
      sleep 1 # Let printer do the job
    end

    def cancel_orders(id=nil)
      # Subscribe to TWS alerts/errors and order-related messages
      @ib.subscribe(:Alert, :OpenOrder, :OrderStatus, :OpenOrderEnd) { |msg| log msg.to_human }

      if id.nil?
        log "Cancel ALL orders!"
        @ib.send_message :RequestGlobalCancel
      else
        # Will only work for Orders placed under the same :client_id
        @ib.cancel_order id
      end

      @ib.send_message :RequestAllOpenOrders

      sleep 3

    end

  end
end
