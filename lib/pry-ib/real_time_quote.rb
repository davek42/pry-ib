# Real Time quote routines
#
require 'ib-ruby'

module PryIb
  class RealTimeQuote

    def initialize( ib )
      @ib = ib
      @request_id = PryIb::next_request_id
    end



    def quote(symbol,stats_only=false)
      log ">> Real Quote: #{symbol}"
      @contract =  Security.make_stock_contract(symbol)

      # Subscribe to TWS alerts/errors
      @ib.subscribe(:Alert) { |msg| log msg.to_human }

      # Subscribe to RealTimeBar incoming events. We have to use message request_id
      # to figure out what contract it's for.
      @ib.subscribe(IB::Messages::Incoming::RealTimeBar) do |msg|
        log "#{symbol}: #{msg.to_human}"
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
