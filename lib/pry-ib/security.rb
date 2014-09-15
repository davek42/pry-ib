# Util routines to create contracts from symbols
#

# Stock contracts definitions
#
# Note that the :description field is particular to ib-ruby, and is NOT part of the
# standard TWS API. It is never transmitted to IB. It's purely used clientside, and
# you can store any arbitrary string that you may find useful there.

module PryIb
  module Security

    def self.get_contract(symbol)
      type, symbol, expiry = parse_symbol symbol
      log "parsed: #{type} : #{symbol} : #{expiry}"
      case type
      when :stock
        make_stock_contract(symbol)
      when :future
        make_future_contract(symbol,expiry)
      else
        nil
      end
    end

    def self.make_stock_contract(symbol)
      contract = IB::Contract.new(:symbol => symbol.to_s.upcase,
                        :currency => "USD",
                        :sec_type => :stock,
                        :description => "#{symbol}")

      contract = Stocks[:gldd] if symbol == "GLDD"
      contract
    end

    def self.make_future_contract(symbol,expiry)
      symbol = symbol.downcase.to_sym
      contract = IB::Symbols::Futures.contracts[symbol]
      contract.expiry = expiry if expiry
      contract
    end

    # Parse symbol
    # defautl is stock
    # Format:  :type:symbol
    # Format:  :type:symbol:expiry
    def self.parse_symbol(symbol)
      if symbol[0] != ':'
        [:stock, symbol]   # assume it is stock 
      elsif symbol =~ /:f:(\S+)/
        sym = $1
        if sym =~ /(\S+):(\S+)/
          [:future,$1,$2]
        else
          [:future,sym]
        end
      elsif symbol =~ /:o:(\S+)/
        [:option,$1]
      elsif symbol =~ /:c:(\S+)/
        [:currency,$1]
      else
        log "Error. Symbol unknown: #{symbol}"
        [nil,nil]
      end
    end

    Stocks = {
      :aapl => IB::Contract.new(:symbol => "AAPL",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Apple Inc."),    
      :bac => IB::Contract.new(:symbol => "BAC",
                                     :exchange => "NYSE",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Bank of America"),     
      :coh => IB::Contract.new(:symbol => "COH",
                                     #:exchange => "NYSE",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Coach"),     
      :cray => IB::Contract.new(:symbol => "CRAY",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Cray Inc."),    
      :f => IB::Contract.new(:symbol => "F",
                                     :exchange => "NYSE",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Ford"),     
      :fb => IB::Contract.new(:symbol => "FB",
                                     :exchange => "NASDAQ",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Facebook"),     
      :goog => IB::Contract.new(:symbol => "GOOG",
                                     #:exchange => "NASDAQ",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Google"),     
      :gsvc => IB::Contract.new(:symbol => "GSVC",
                                     :exchange => "NASDAQ",
                                   :currency => "USD",
                                   :sec_type => :stock,
                                   :description => "Global Silicon Venture Capital"),
      :gldd => IB::Contract.new(:symbol => "GLDD",
                              :currency => "USD",
                               :exchange => "SMART",
                              :primary_exchange => "NASDAQ",
                              :sec_type => :stock,
                              :description => "Great Lakes Dredge"),    
      :len => IB::Contract.new( :symbol => "LEN",
                                      #:exchange => "NYSE",
                                      :currency => "USD",
                                      :sec_type => :stock,
                                      :description => "Lennar"),
      :lnkd => IB::Contract.new( :symbol => "LNKD",
                                      :exchange => "NYSE",
                                      :currency => "USD",
                                      :sec_type => :stock,
                                      :description => "LinkedIn"),
      :msft => IB::Contract.new(:symbol => "MSFT",
                                     :exchange => "NASDAQ",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Microsoft"),     
      :pcln => IB::Contract.new(:symbol => "PCLN",
                                    #:exchange => "NASDAQ",
                                    :currency => "USD",
                                    :sec_type => :stock,
                                    :description => "Priceline"),
      :p => IB::Contract.new(:symbol => "P",
                                    #:exchange => "NASDAQ",
                                    :currency => "USD",
                                    :sec_type => :stock,
                                    :description => "Pandora"),
      :qqq => IB::Contract.new(:symbol => "QQQ",
                                     :exchange => "SMART",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "QQQ"),     
      :fire => IB::Contract.new(:symbol => "FIRE",
#                                     :exchange => "NYSE",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "FIRE"),     
      :rax => IB::Contract.new(:symbol => "RAX",
                                     :exchange => "NYSE",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Rackspace"),     
      :spy => IB::Contract.new(:symbol => "SPY",
                                     :exchange => "SMART",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "SPY"),     
      :vxx => IB::Contract.new(:symbol => "VXX",
                                  :exchange => "SMART",
                                  :currency => "USD",
                                  :sec_type => :stock,
                                  :description => "Yelp"),
      :yelp => IB::Contract.new(:symbol => "YELP",
#                                  :exchange => "NYSE",
                                  :currency => "USD",
                                  :sec_type => :stock,
                                  :description => "Yelp"),
      :z => IB::Contract.new(:symbol => "Z",
#                                     :exchange => "SMART",
                                     :currency => "USD",
                                     :sec_type => :stock,
                                     :description => "Zillow"),     

      :affy => IB::Contract.new(:symbol => "AFFY",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Affymax Inc."),    
      :bby => IB::Contract.new(:symbol => "BBY",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Best Buy Co. Inc."),    
      :keg => IB::Contract.new(:symbol => "KEG",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Key Energy Services Inc."),    
      :mnst => IB::Contract.new(:symbol => "MNST",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Monster Beverage Corp."),    
      :mstr => IB::Contract.new(:symbol => "MSTR",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "MicroStrategy Inc."),    
      :nfp => IB::Contract.new(:symbol => "NFP",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "National Financial Partners Corp."),    
      :pcyc => IB::Contract.new(:symbol => "PCYC",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Pharmacyclics Inc."),    
      :qlik => IB::Contract.new(:symbol => "QLIK",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "Qlik Technologies, Inc."),    
      :hum => IB::Contract.new(:symbol => "HUM",
                              :currency => "USD",
                              :sec_type => :stock,
                              :description => "HUM"),    
        }
        
        
        Options = {
             :aapl580_201207 => IB::Option.new(:symbol => "AAPL",
                                        :expiry => "20120720",
                                        :right => "CALL",
                                        :strike => 580,
                                        :multiplier => 100,
                                        :currency => "USD",
                                        :description => "Apple 580 Call 2012-07"),
             :aapl600_201301 => IB::Option.new(:symbol => "AAPL",
                                        :expiry => "201301",
                                        :right => "CALL",
                                        :strike => 600,
                                        :multiplier => 100,
                                        :currency => "USD",
                                        :description => "Apple 600 Call 2013-01"),
             :lnkd100 => IB::Option.new(:symbol => "LNKD",
                                    :expiry => "201206",
                                    :right => "CALL",
                                    :strike => 100.0,
                                    :currency => "USD",
                                    :description => " FTSE-100 index 50 Call 2012-06"),
             :spy75 => IB::Option.new(:symbol => 'SPY',
                                      :expiry => "20120615",
                                      :right => "P",
                                      :currency => "USD",
                                      :strike => 75.0,
                                      :description => "SPY 75.0 Put 2012-06-16"),
             :spy100 => IB::Option.new(:osi => 'SPY 121222P00100000'),
             #
#             :es1370_201207 => IB::Option.new(:symbol => "ES",
#                                        :expiry => "201206",
#                                        :right => "CALL",
#                                        :strike => 580,
#                                        :multiplier => 50,
#                                        :currency => "USD",
#                                        :description => "ES 1340 Call 2012-07"),

            }
    end

end

