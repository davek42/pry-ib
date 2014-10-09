# Real Time quote routines
#
require 'ib-ruby'

module PryIb
  class RealTimeStat
    MAX_QUOTES = 7 * 60 * (60/5)  # something like a days worth

    attr_accessor :quotes, :atrs

    def initialize( ib, opts={} )
      @ib = ib
      @request_id = PryIb::next_request_id
      @verbose = opts.fetch(opts[:verbose], false)
      @current_bar = nil
      @quote_count = 0
      @quotes = []
      @atrs= { 0 => [{hl: 0, hc: 0, lc: 0, tr:0, atr:0 }] }
      @mfis = { 0 => [] }
    end

    def calc_atr(period=14)
      rows = @atrs.fetch(period, [{hl: 0, hc: 0, lc: 0, tr:0, atr:0 }]  )

      high_low = 0
      high_close = 0
      low_close = 0

      bar = @quotes.last
      prev_bar = @quotes[ @quotes.size - 2 ]

      puts ">> Quote size:#{@quotes.size} bar:#{bar.inspect} last:#{@quotes.last}"

      if @quotes.size > 1
        high_low = bar.high - bar.low
        high_close = (bar.high - prev_bar.close).abs
        low_close  = (bar.low - prev_bar.close).abs
        tr = [high_low, high_close, low_close].max
        rows << {hl: high_low, hc: high_close, lc: low_close, tr:tr, atr:0 }
        #puts ">>> atrs: #{@atrs[period].inspect} "
        @atrs[period] = rows
        if @quotes.size >= period
#          trs = rows[(@quotes.size - period)..-1].collect{ |el|  el[:tr] }
#          tr_sum = trs.inject(0.0,:+) 
          tr_sum = rows[(@quotes.size - period)..-1].inject(0){|sum,elem| sum + elem[:tr]}
          #puts ">>> TR sum: #{tr_sum}  period:#{period}"
          @atrs[period].last[:atr] =  tr_sum / period.to_f
        end
      elsif @quotes.size == 1
        high_low = bar.high - bar.low
        rows.first[:hl] = high_low
        rows.first[:tr] = high_low
        @atrs[period] = rows
      else
        log( "calc_atr -- no quotes")
      end

      #puts ">>> ROWS: #{rows.inspect} "
      puts ">>> ATR[#{period}]: %.2f " % rows.last[:atr]
      rows.last[:atr]
    end

    def calc_mfi
      rows = @mfis.fetch(period, [{hl: 0, hc: 0, lc: 0, tr:0, atr:0 }]  )
      # TBD
    end

    def build_bar(current_bar, new_bar)
      if current_bar
        #current_bar.open   do nothing
        current_bar.high   = [ current_bar.high, new_bar.high ].max
        current_bar.low    = [ current_bar.low, new_bar.low ].min
        current_bar.close  =  new_bar.close
        current_bar.volume += new_bar.volume
        current_bar.time   =  new_bar.time
      else
        current_bar = new_bar
      end

      current_bar
    end



    def quote(symbol,num_quotes=MAX_QUOTES, opts={})
      log "\n******** Real Stat Start: #{symbol} *********\n\n"
      log "*** Opts:#{opts.inspect}"
      @contract =  Security.get_contract(symbol)

      bar_loop = opts.fetch(:bar_size, 5)  / 5

      # Subscribe to TWS alerts/errors
      alert_id = @ib.subscribe(:Alert) { |msg| log msg.to_human }

      # process real time bar messages
      real_id = @ib.subscribe(IB::Messages::Incoming::RealTimeBar) do |msg|
        @quote_count += 1
        bar = build_bar(bar,msg.bar)

        if @quote_count == bar_loop 
          @quotes << bar

          opts[:atr].each{ |per| calc_atr(per.to_i) } if opts[:atr]

          dt = Date.epoch_to_datetime( bar.time )
          log ">>ID:#{msg.request_id} - #{symbol} - Bar. #{bar.close} Vol:#{bar.volume} | hour:#{dt.hour} min:#{dt.min} sec:#{dt.sec}"

          @quote_count = 0
          bar = nil
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
