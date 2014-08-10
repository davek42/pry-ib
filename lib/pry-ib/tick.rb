# Tick data routines
#
require 'ib-ruby'

module PryIb
  class Tick

    def initialize( ib )
      @ib = ib
    end

#    def log(message)
#      Pry::output.puts(message)
#   end

    def displayTickMessage( message )
      
      tick_type = case message.tick_type
      when 1 then "bid  "
      when 2 then "ask  "
      when 4 then "last "
      when 6 then "high "
      when 7 then "low  "
      when 9 then "close"
      else 
         message.tick_type.to_s
      end

      log "#{message.message_type}  T:#{tick_type}  Price: #{message.price} Size:#{message.size}"

    end



    def tick(symbol)
      log("Get tick for :#{symbol}")

      contract =  Security.make_stock_contract(symbol)
      log("Contract: #{contract.inspect}")

      @ib.subscribe(:Alert) { |msg| log "ALERT: #{msg.to_human}" }
      #ib.subscribe(:TickGeneric, :TickString, :TickPrice, :TickSize) { |msg| log msg.inspect }

      # Display these ticks
      @ib.subscribe( :TickPrice) { |msg| displayTickMessage(msg) }
      # send these tick messages to bit bucket
      @ib.subscribe(:TickGeneric, :TickString,  :TickSize) { |msg| }

      @ib.send_message :RequestMarketData, :id => 123, :contract => contract

      log "\nSubscribed to market data"
      log "\n******** Press <Enter> to cancel... *********\n\n"
      gets
      log "Cancelling market data subscription.."
    end

  end
end
