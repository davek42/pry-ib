# Brack order routines
#
require 'ib-ruby'

module PryIb
class BracketOrder
  attr_accessor :id, :ib, :order_price,:stop_price, :profit_price, :contract, :name
  attr_accessor :parent_order, :stop_order, :profit_order

  @@brackets = []

  #def initialize(ib, symbol, account=nil )
  def initialize(ib, opts={} )
    log "init opts:#{opts.inspect}"
    @id = PryIb::next_request_id
    @ib = ib
    @symbol = opts[:symbol]
    @contract =  Security.get_contract(@symbol)
    @account = opts[:account]
    @name = bracket_name
    log "Symbol: #{@symbol}  Contract: #{@contract.inspect}"
  end

  def bracket_name
    "#{@symbol}_#{DateTime::now.to_name}"
  end

  def save
    @@brackets << self
  end
  def self.last
    @@brackets.last
  end

  def self.list
    log "Nil brackets"  if @@brackets.nil?
    log "No brackets"   if @@brackets.empty?
    @@brackets.each do |bb|
      log(">>  #{bb.name} at #{bb.order_price}")
    end
  end

  def setup( quantity, order_price, stop_price, profit_price, parent_order_type, direction = :long )
    raise "No symbol" if @symbol.nil? || @symbol.empty?
    raise "got bad order quanity" if quantity.nil? or quantity <= 0
    raise "Got bad order price"  if order_price.nil? or order_price <= 0
    raise "Bad order type: #{parent_order_type}"  unless ['LMT','STP','MKT'].include?(parent_order_type)
    

    @order_price = order_price
    @stop_price = stop_price
    @profit_price = profit_price
    @ib.subscribe(:Alert, :OpenOrder, :OrderStatus) { |msg| log "---> #{msg.to_human}" }

    case direction
    when :long 
      parent_action = "BUY"
      child_action  = "SELL"
    when :short
      parent_action = "SELL"
      child_action  = "BUY"
    else
      log "Bad direction: #{direction}"
      raise "Got Bad order direction: #{direction}"
    end

    
    log "Bracket. dir:#{direction} quantity:#{quantity} order_price:#{order_price}  order_type:#{parent_order_type}"
    log "  stop:#{stop_price} target:#{profit_price}  account:#{@account}"
    log "  Symbol: #{@contract.symbol}  Contract: #{@contract.inspect}"

    #-- Parent Order --
    case parent_order_type
    when "LMT","MKT"
    
    @parent_order = IB::Order.new :total_quantity => quantity,
                              :local_id => @id,
                              :limit_price => order_price,
                              :action => parent_action,
                              :order_type => parent_order_type, # LMT, STP, MKT
                              :algo_strategy => '',
                              :account => @account,
                              :transmit => false
    when "STP"
      @parent_order = IB::Order.new :total_quantity => quantity,
                              :local_id => @id,
                              :limit_price => 0,
                              :aux_price => order_price,
                              :action => parent_action,
                              :order_type => parent_order_type, # LMT, STP, MKT
                              :algo_strategy => '',
                              :account => @account,
                              :transmit => false
     else
       log "Unknown order type: #{parent_order_type}"
     end
    @ib.wait_for :NextValidId

    #-- Child STOP --
    if @stop_price
      @stop_order = IB::Order.new :total_quantity => quantity,
                              :limit_price => 0,
                              :aux_price => stop_price,
                              :action => child_action,
                              :order_type => 'STP',
                              :parent_id => @parent_order.local_id,
                              :account => @account,
                              :transmit => true
    end
    #-- Profit LMT
    if @profit_price
      if @profit_price > 0
        @profit_order = IB::Order.new :total_quantity => quantity,
                                :limit_price => profit_price,
                                :action => child_action,
                                :order_type => 'LMT',
                                :parent_id => @parent_order.local_id,
                                :account => @account,
                                :transmit => true
      elsif @profit_price == 0
        # Market on Close order
        @profit_order = IB::Order.new :total_quantity => quantity,
                                :limit_price => 0,
                                :action => child_action,
                                :order_type => 'MOC',
                                :parent_id => @parent_order.local_id,
                                :account => @account,
                                :transmit => true
      else
        log "ERROR: got junk profit price: #{@profit_price}"
      end
    end


  end

  def send_order
    begin
      # place parent order
      @ib.place_order( @parent_order, @contract )

      # place child orders
      if @stop_order
        @stop_order.parent_id = @parent_order.local_id
        @ib.place_order( @stop_order, @contract )   
      end

      if @profit_order
        @profit_order.parent_id = @parent_order.local_id 
        @ib.place_order( @profit_order, @contract )
      end


      log "------------------------"
      log "-- SEND Orders    ------"
      log "-- parent local_id: #{@parent_order.local_id} client_id:#{@parent_order.client_id}"
      log "------------------------"
      @ib.send_message :RequestOpenOrders

      save # store this bracket
    rescue => ex
      log "ERROR: Failed while placing bracket orders"
      log "Parent: #{@parent_order.inspect}"
      log "ERROR: #{ex.class.name}"
      raise ex
    end
  end


  def update_stop(new_price)
    if @stop_order.nil?
      log "No stop order. No change"
      return
    end
    begin
    if new_price.nil?
      new_price += 0.01
      log "Bump price to :#{new_price}"
    end
    @stop_order.aux_price = new_price
    @stop_order.transmit = true

    @ib.modify_order @stop_order, @contract
    @ib.send_message :RequestOpenOrders
    log ">>Update sent"

    rescue => ex
      log "ERROR: Failed while updating bracket stop orders"
      log "Parent: #{@parent_order.inspect}"
      log "Stop: #{@stop_order.inspect}"
      log "ERROR: #{ex.class.name}"
      raise ex
    end
  end

  # bump the stop price by increment
  def sbump(stop_increment)
    new_price = @stop_order.aux_price + stop_increment
    update_stop(new_price)
  end

  def update_target(new_price)
    if @profit_order.nil?
      log "No profit target order. No change"
      return
    end
    begin
    if new_price.nil?
      new_price += 0.01
      log "Bump price to :#{new_price}"
    end
    @profit_order.aux_price = new_price
    @profit_order.transmit = true

    @ib.modify_order @profit_order, @contract
    @ib.send_message :RequestOpenOrders
    log ">>Update sent"

    rescue => ex
      log "ERROR: Failed while updating bracket profit target orders"
      log "Parent: #{@parent_order.inspect}"
      log "Stop: #{@profit_order.inspect}"
      log "ERROR: #{ex.class.name}"
      raise ex
    end
  end

end

end

