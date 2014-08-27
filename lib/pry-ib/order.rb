
# Order status routines
#
require 'ib-ruby'

module PryIb
  class Order


    def initialize( ib )
      @ib = ib
    end

    def list_orders(match_symbol=nil)
      # Subscribe to TWS alerts/errors and order-related messages
      @counter = 0
      @open_orders = {}
      @order_status = {}

      alert_id = @ib.subscribe(:Alert )      { |msg| log "Alert. #{msg.to_human}" }
      end_id = @ib.subscribe(:OpenOrderEnd)  { |msg| } # bit bucket

      status_id = @ib.subscribe(:OrderStatus) do |msg| 
        data = msg.data
        state = data[:order_state]
        perm_id = state[:perm_id]
        @order_status[perm_id] = data
      end
      open_id = @ib.subscribe(:OpenOrder) do |msg|
        @counter += 1
        data = msg.data
        order = data[:order]
        perm_id = order[:perm_id]
        contract = data[:contract]
#        log "Open[#{@counter}]: #{contract[:symbol]} Action:#{order[:action]} Type:#{order[:order_type]}  Quant:#{order[:total_quantity]}  PermID:#{order[:perm_id]}"
        @open_orders[perm_id] =data
      end

      @ib.send_message :RequestAllOpenOrders

      # Wait for IB to respond to our request
      @ib.wait_for :OpenOrderEnd

      log "--------- Open -----"
      @open_orders.each do |perm_id,data|
        order      = data[:order]
        local_id   = order[:local_id]
        contract   = data[:contract]
        state_data = @order_status[perm_id]
        os         = state_data[:order_state]
        status     = os[:status]
        symbol     = contract[:symbol]
        if !match_symbol || match_symbol == symbol
        #  log "macth: #{match_symbol} symbol:#{symbol}"
          log "Open[#{perm_id}]/[#{local_id}]: #{symbol} Action:#{order[:action]} Type:#{order[:order_type]}  Quant:#{order[:total_quantity]}  Status:#{status} Account:#{order[:account]}"
        end
      end



      sleep 1 # Let printer do the job

      log "\n******** List OrdersDone  *********\n\n"
      @ib.unsubscribe alert_id
      @ib.unsubscribe status_id 
      @ib.unsubscribe end_id
      @ib.unsubscribe open_id
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
