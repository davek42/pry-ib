
# scanner routines
#
#require 'ib-ruby'

module PryIb
class Scanner


  def initialize(ib )
    @ib = ib
    @request_id = PryIb::next_request_id
  end


  def scan(options)
    # Subscribe to TWS alerts/errors
    alert_id = @ib.subscribe(:Alert) { |msg| log msg.to_human }

    opt = { num_rows: 20, 
            scan_code: 'TOP_PERC_GAIN', 
            above_price: 4.0, 
            location_code: 'STK.US.MAJOR', 
            above_volume: 5000 
    }.merge(options)

    #
    # Result:
    #   keys: [:rank, :contract, :distance, :benchmark, :projection, :legs]
    scan_id = @ib.subscribe(IB::Messages::Incoming::ScannerData) do |msg|
      log "ID: #{msg.request_id} : #{msg.count} items:"

      msg.results.each do |entry|  
        con = entry[:contract]
        log " [#{entry[:rank]}] #{con.symbol}" 
      end
    end

    # Now we actually request scanner data for the type of scan we are interested.
    # Some scan types can be found here:  http://www.interactivebrokers.com/php/apiUsersGuide/apiguide/tables/available_market_scanners.htm
    #
    mess = IB::Messages::Outgoing::RequestScannerSubscription.new(
                        :request_id => @request_id,
                        :number_of_rows => opt[:num_rows],
                        :instrument => "STK",
                        :location_code => 'STK.US.MAJOR',
                        :scan_code  => 'TOP_PERC_GAIN',
                        :above_price => opt[:above_price],
                        :below_price => Float::MAX,
                        :above_volume => opt[:above_volume],
                        :market_cap_above => 100000000,
                        :market_cap_below =>  Float::MAX,
                        :moody_rating_above => "",
                        :moody_rating_below => "",
                        :sp_rating_above => "",
                        :sp_rating_below => "",
                        :maturity_date_above => "",
                        :maturity_date_below => "",
                        :coupon_rate_above => Float::MAX,
                        :coupon_rate_below => Float::MAX,
                        :exclude_convertible => "",
                        :average_option_volume_above => "", # ?
                        :scanner_setting_pairs => "Annual,true",
                        :stock_type_filter => "Stock"
                        )
                        
    @ib.send_message( mess )   

    # IB does not send any indication when all  data is done being delivered.
    # So we need to interrupt manually when our request is answered.
    log "\n******** Press <Enter> to exit... *********\n\n"
    STDIN.gets
    
    @ib.send_message :CancelScannerSubscription, :id => @request_id 
    @ib.unsubscribe alert_id
    @ib.unsubscribe scan_id

  end
end
end
