# Quote History routines
#
require 'ib-ruby'

module PryIb
  class History

    DURATIONS = { sec1: '1 S', 
                  day1: '1 D',
                  week1: '1 W',
                  month1: '1 M',
                  year1: '1 Y',
    }

    def initialize( ib )
      @ib = ib
      @quotes = {}
      @market = {}
      @request_id = 201
    end

    def avg(list)
      sum =0.0
      if list.size > 0
        list.each{|bar| sum += bar}
        average = sum / list.size
      end
      average
    end

  ###
    def quote(symbol,duration='1 D', bar_size='5 mins',stats_only=false)
      @contract =  Security.make_stock_contract(symbol)
      log("Quote for:#{@contract.inspect} duration:#{duration} bar_size=#{bar_size}, stats_only:#{stats_only}")
      @market = { @request_id => @contract }
      @market.each_key { |key| @quotes[key] = [] }

      # Ensure we get alerts
      @ib.subscribe(:Alert) { |msg| log "ALERT: #{msg.to_human}" }

      # Subscribe to historical quote data
      @ib.subscribe(IB::Messages::Incoming::HistoricalData) do |msg|
        log "ID: #{msg.request_id} " + @market[msg.request_id].description + ": #{msg.count} items:"
        msg.results.each do |entry| 
          #log "Request_id:#{msg.request_id}t
          @quotes[msg.request_id] << entry
        end
        @last_msg_time = Time.now.to_i
        #log "Quotes:#{@quotes.inspect}"
      end
      log "-- After subscribe"

      # HistoricalData docs: http://www.interactivebrokers.com/php/apiUsersGuide/apiguide/api/historical_data_limitations.htm#XREF_93621_Historical_Data
      target_date = Time.now.to_date
      target_trade_time = Date::recent_ib_trading_date
      log ">> Target Date: #{target_date.to_s} IB: #{ target_trade_time }"

      # Now we actually request historical data for the symbols we're interested in. TWS will
      # respond with a HistoricalData message, which will be processed by the code above.
      @market.each_pair do |id, contract|
        log ">> SEND request id:#{id}"
        mess = IB::Messages::Outgoing::RequestHistoricalData.new(
                            :request_id => id,
                            :contract => contract,
                            :end_date_time => target_trade_time,
                            :duration => duration, #'1 D', #    ?
                            :bar_size => bar_size,  #'5 mins', #  IB::BAR_SIZES.key(:hour)?
                            :what_to_show => :trades,
                            :use_rth => 1,
                            :format_date => 1)
        log ">> Send contract: #{contract.inspect}"
        log ">> mess:#{mess.inspect}"
        @ib.send_message( mess )
      end


      log "---- WAIT ....."
      # Wait for IB to respond to our request
      sleep 0.2 until @last_msg_time && @last_msg_time < Time.now.to_i + 4.7


      log "------------------"
      log "------------------"
      #log "QUOTES: #{@quotes.inspect}"


      max_high = 0
      max_low  = 999999
      avg_close = 0
      @quotes.each_pair do |id, bars|
        log ">>>--------------"
        log "ID: #{id} Desc: #{@market[id].description}"
        #log "Quotes: #{quotes.inspect}"
        bars.each do |bar|
          log ">> BAR: #{bar.to_s}" unless stats_only
          max_high = bar.high if bar.high > max_high
          max_low  = bar.low if bar.low < max_low   
        end
        avg_close = avg( bars.collect{|b| b[:low]} ) 
      end

      log "---------------------------"
      log "Max High: #{max_high}"
      log "Max Low : #{max_low}"
      log "Avg Close: #{"%6.2f" % avg_close}"
      @quotes
    end

  end


end
