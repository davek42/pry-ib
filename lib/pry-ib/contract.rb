# Contract routines
#
require 'ib-ruby'

module PryIb
  class Contract

    def initialize( ib,symbol )
      @ib = ib
      @symbol = symbol
      @request_id = PryIb::next_request_id
    end

    def to_stock
      @contract =  Security.make_stock_contract(@symbol)
    end
    def to_future
      # try to lookup
      sym = @symbol.to_sym

      @contract = IB::Symbols::Futures.contracts.fetch(sym,nil)
      if @contract.nil?
        log "WARNING. Conract not created for symbol:#{@symbol}"
      end

    end


    def detail
      @contract = PryIb::Security.get_contract( @symbol ) if @contract.nil?

      # Subscribe to TWS alerts/errors and contract data end marker
      @ib.subscribe(:Alert, :ContractDataEnd) { |msg| log msg.to_human }

      # Now, subscribe to ContractData incoming events.  The code passed in the block
      # will be executed when a message of that type is received, with the received
      # message as its argument. In this case, we just print out the data.
      @ib.subscribe(:ContractData, :BondContractData) { |msg| log(msg.contract.inspect + "\n")}

      log "\nRequesting contract data #{@request_id}: #{@contract.description}"

      # Request Contract details for the symbols we're interested in. TWS will
      # respond with ContractData messages, which will be processed by the code above.
      @ib.send_message :RequestContractData, :id => @request_id, :contract => @contract

      # Wait for IB to respond to our request
      @ib.wait_for :ContractDataEnd, 5 #sec
      @ib.clear_received :ContractDataEnd

    end
  end

  class StockContract < Contract
    def initialize( ib,symbol )
      super ib, symbol
      to_stock
    end
  end
  class FutureContract < Contract
    def initialize( ib,symbol )
      super ib, symbol
      to_future
    end
  end
end
