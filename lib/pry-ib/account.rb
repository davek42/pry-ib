# Account routines
#
require 'ib-ruby'

module PryIb
  class Account

    def initialize( ib )
      @ib = ib
    end


    def info( account_code='' )

      # Subscribe to TWS alerts/errors and account-related messages
      # that TWS sends in response to account data request
      @ib.subscribe(:Alert, :AccountValue,
                   :PortfolioValue, :AccountUpdateTime) { |msg| log msg.to_human }

      @ib.send_message :RequestAccountData, :subscribe => true, :account_code => account_code

      log "\nSubscribing to IB account data"
      log "\n******** Press <Enter> to cancel... *********\n\n"
      STDIN.gets
      log "Cancelling account data subscription.."

      @ib.send_message :RequestAccountData, :subscribe => false
      sleep 2
      
    end
  end
end

