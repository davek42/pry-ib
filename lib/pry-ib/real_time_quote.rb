# Real Time quote routines
#
#require 'ib-ruby'

module PryIb
  class RealTimeQuote
    MAX_QUOTES = 7 * 60 * (60/5)  # something like a days worth

    def initialize( ib, opts={} )
      @ib = ib
      @request_id = PryIb::next_request_id
      @verbose = opts.fetch(opts[:verbose], false)
      @quote_count = 0
    end



    def quote(symbol,num_quotes=MAX_QUOTES)
      log "\n******** Real Quote Start: #{symbol} *********\n\n"
      @contract =  Security.make_stock_contract(symbol)

      # Subscribe to TWS alerts/errors
      alert_id = @ib.subscribe(:Alert) { |msg| log msg.to_human }

      # Subscribe to RealTimeBar incoming events. We have to use message request_id
      # to figure out what contract it's for.
      real_id = @ib.subscribe(IB::Messages::Incoming::RealTimeBar) do |msg|
        @quote_count += 1
        if @verbose
          cnt = "#{sprintf("%02d", @quote_count)}"
          log "[#{cnt}]#{symbol}: #{msg.to_human}"
        else
          bar = msg.bar
          id  = msg.request_id
          dt = Date.epoch_to_datetime( bar.time )

          log ">>ID:#{id} - #{symbol} - Bar. #{bar.close} hour:#{dt.hour} min:#{dt.min} sec:#{dt.sec}"
        end
      end

      log "Request RealTime. Contract: #{@contract.inspect}"
      @ib.send_message IB::Messages::Outgoing::RequestRealTimeBars.new(
                            :request_id => @request_id,
                            :contract => @contract,
                            :bar_size => 5, # Only 5 secs bars available?
                            :data_type => :trades,
                            :use_rth => false)

      while(@quote_count < num_quotes && @quote_count < MAX_QUOTES)
        sleep 1
      end
      log "\n******** Real Quote Done: #{symbol} *********\n\n"
      @ib.send_message :CancelRealTimeBars, :id => @request_id 
      @ib.unsubscribe alert_id
      @ib.unsubscribe real_id
    end
  end
end
