# combo order routines
#
require 'ib-ruby'

module PryIb
class ComboOrder

  def initialize(ib, opts={} )
    log "init opts:#{opts.inspect}"
    @id = PryIb::next_request_id
    @ib = ib
    @symbol = opts[:symbol]
#    @contract =  Security.make_stock_contract(@symbol)
    @account = opts[:account]
#    @name = bracket_name
    log "Symbol: #{@symbol}  "
  end


  # Utility method that helps us build multi-legged (BAG) Orders
  def make_butterfly symbol, expiry, right, *strikes
    raise 'No Connection!' unless @ib && @ib.connected?

    legs = strikes.zip([1, -2, 1]).map do |strike, weight|
      # Create contract
      contract = IB::Option.new :symbol => symbol,
                                :expiry => expiry,
                                :right => right,
                                :strike => strike
      # Find out contract's con_id
      @ib.clear_received :ContractData, :ContractDataEnd
      @ib.send_message :RequestContractData, :id => strike, :contract => contract
      @ib.wait_for :ContractDataEnd, 3
      con_id = @ib.received[:ContractData].last.contract.con_id

      # Create Comboleg from con_id and weight
      IB::ComboLeg.new :con_id => con_id, :weight => weight
    end

    # Create new Combo contract
    IB::Bag.new :symbol => symbol,
                :currency => "USD", # Only US options in combo Contracts
                :exchange => "SMART",
                :legs => legs
  end


  def place_butterfly( expiry,  right, num_conracts, *strikes )
    # Subscribe to TWS alerts/errors and order-related messages
    @ib.subscribe(:Alert, :OpenOrder, :OrderStatus) { |msg| log msg.to_human }
    @ib.wait_for :NextValidId

    # Create multi-legged option Combo using utility method above
  #  combo = butterfly 'GOOG', '201301', 'CALL', 500, 510, 520
    combo = make_butterfly @symbol, expiry, right, strikes

    # Create Order stub
    order = IB::Order.new :total_quantity => num_contracts, # 10 butterflies
                          :limit_price => 0.01, # at 0.01 x 100 USD per contract
                          :action => 'BUY',
                          :order_type => 'LMT'

    @ib.place_order order, combo

    @ib.wait_for [:OpenOrder, 3], [:OrderStatus, 2]

  end
end
end
