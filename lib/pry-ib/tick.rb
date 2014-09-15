# Tick data routines
#
require 'ib-ruby'

module PryIb
  class Tick
    MAX_TICKS = 200

    def initialize( ib )
      @ib = ib
      @request_id = PryIb::next_request_id
      @tick_count = 0
      @tick_idle_count = 0
    end

#    def log(message)
#      Pry::output.puts(message)
#   end

    # See tick types: https://www.interactivebrokers.com/en/software/api/apiguide/tables/tick_types.htm
    def displayTickMessage( message )
      
      tick_type = case message.tick_type
      when 4 
        "last "
      when 1  then "bid  "
      when 2  then "ask  "
      when 6  then "high "
      when 7  then "low  "
      when 9  then "close"
      when 14 then "open "
      else 
         message.tick_type.to_s
      end

      log "[#{@tick_count}] #{message.message_type}  T:#{tick_type}  Price: #{message.price} Size:#{message.size}"
      if tick_type == 9
        @tick_count += 1 
        log "---- Bump tick count: #{@tick_count}  Num: #{num_ticks} ---"
      end
    end



    def tick(symbol, num_ticks=2)
      @tick_count = 0
      log "\n******** Tick Start: #{symbol} *********\n\n"

      contract =  Security.get_contract(symbol)
      #log("Contract: #{contract.inspect}")

      alert_id = @ib.subscribe(:Alert) { |msg| log "ALERT: #{msg.to_human}" }
      #ib.subscribe(:TickGeneric, :TickString, :TickPrice, :TickSize) { |msg| log msg.inspect }

      # Display these ticks
      price_id = @ib.subscribe( :TickPrice) { |msg| displayTickMessage(msg) }
      # send these tick messages to bit bucket
      other_id = @ib.subscribe(:TickGeneric, :TickString,  :TickSize) { |msg| }

      @ib.send_message :RequestMarketData, :id => @request_id, :contract => contract

#      log "\nSubscribed to tick data: #{symbol} tick_count:#{@tick_count} num:#{num_ticks} "
      while(@tick_count < num_ticks && @tick_count < MAX_TICKS && 
            @tick_idle_count  < (@tick_count + 3) )
        log "---- tick count: #{@tick_count}  Num: #{num_ticks} idle:#{@tick_idle_count} ---"
        sleep 1
        @tick_idle_count += 1
      end
      log "\n******** Tick Done: #{symbol} *********\n\n"
      @ib.send_message :CancelMarketData, :id => @request_id 
      @ib.unsubscribe alert_id
      @ib.unsubscribe price_id
      @ib.unsubscribe other_id
    end

  end
end
