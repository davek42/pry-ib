# Tick data routines
#
require 'ib-ruby'

module PryIb
  class Alert

    @@alerts = {}


    #def initialize( ib, name = nil )
    def initialize( ib, opts={} )
      @ib = ib
      @name = opts[:name] || PryIb::Alert.next_alert_name
      @sound = opts[:sound] || false
      @request_id = PryIb::next_request_id
      @min_bars = []
    end 

    def self.get_alerts
      @@alerts
    end

    def self.next_alert_name
      "Alert%0.02d" %  @@alerts.size
    end

    def say(msg)
      # Alex or Vicki are best voices
      system( 'say --voice=Vicki "' + msg + '"')
    end

    def get_symbol
      @contract.symbol
    end

    def check_alert(message,test)
      bar = message.bar
      id = message.request_id
      dt = Date.epoch_to_datetime( bar.time )
      symbol = get_symbol

      log ">>ID:#{id} - #{symbol} - Bar. #{bar.close} hour:#{dt.hour} min:#{dt.min} sec:#{dt.sec}"

      if test.call(bar)
        log "!!!!>> Alert #{symbol}  at #{bar.close}  <<!!!!"
        say "Alert #{symbol} at #{bar.close}"
      end

#      if dt.sec == 0
#        log ">> add min bar. min:#{dt.min} sec:#{dt.sec}"
#        @min_bars << bar
#      end
    end


    def alert(symbol,&test)
      log ">> Alert: #{symbol}"
      @contract =  Security.make_stock_contract(symbol)
      log ">> contract: #{@contract}"

      # Subscribe to TWS alerts/errors
      @ib.subscribe(:Alert) { |msg| log msg.to_human }

      # Subscribe to RealTimeBar incoming events. We have to use message request_id
      # to figure out what contract it's for.
      @ib.subscribe(IB::Messages::Incoming::RealTimeBar) do |msg|
        #log "#{symbol}: #{msg.to_human}"
        check_alert(msg,test)
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

