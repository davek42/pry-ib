# Tick data routines
#
require 'ib-ruby'

module PryIb
  class Alert

    def initialize( ib )
      @ib = ib
      @request_id = PryIb::next_request_id
      @min_bars = []
    end

    def get_symbol
      @contract.symbol
    end

    def check_alert(message)
      bar = message.bar
      id = message.request_id
      dt = Date.epoch_to_datetime( bar.time )
      symbol = get_symbol(id)

      log ">>ID:#{id} - #{symbol} - Bar. #{bar.close} hour:#{dt.hour} min:#{dt.min} sec:#{dt.sec}"

      if dt.sec == 0
        log ">> add min bar. min:#{dt.min} sec:#{dt.sec}"
        @min_bars << bar
      end
    end


    def alert(symbol)
      log ">> Alert: #{symbol}"
      @contract =  Security.make_stock_contract(symbol)

      # Subscribe to TWS alerts/errors
      @ib.subscribe(:Alert) { |msg| log msg.to_human }

      # Subscribe to RealTimeBar incoming events. We have to use message request_id
      # to figure out what contract it's for.
      @ib.subscribe(IB::Messages::Incoming::RealTimeBar) do |msg|
        #log "#{symbol}: #{msg.to_human}"
        check_alert(msg)
      end

      log "Request RealTime. Contract: #{@contract.inspect}"
      @ib.send_message IB::Messages::Outgoing::RequestRealTimeBars.new(
                            :request_id => @request_id,
                            :contract => @contract,
                            :bar_size => 5, # Only 5 secs bars available?
                            :data_type => :trades,
                            :use_rth => false)

      # So we need to interrupt manually when we do not want any more quotes.
      log "\n******** Press <Enter> to exit... *********\n\n"
      STDIN.gets
    end
  end

end

