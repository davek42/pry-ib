
require 'mongoid'
require 'date'
require 'time'

module PryIb
  module Mongo

#   doc = {symbol: symbol, date: bar.time,
#              open: bar.open, high: bar.high, low: bar.low, close: bar.close,.
#              volume: bar.volume,.
#              trades: bar.trades,
#              year: dt.year, month: dt.month, day: dt.day,.
#              hour: dt.hour, min: dt.minute, sec: dt.second,
#              timestamp: utc,
#              WAP: bar.wap, hasGaps: bar.has_gaps, source: 'IB'}.
    class Quote
      include Mongoid::Document
      store_in collection: "quotes"

      field :bar_size, type: String # "1 min", "2 mins", "3 mins", "5 mins", "15 mins"
      field :symbol, type: String
      field :open,   type: Float
      field :high,   type: Float
      field :low,    type: Float
      field :close,  type: Float
      field :volume, type: Integer
      field :trades, type: Integer

      field :year,   type: Integer
      field :month,  type: Integer
      field :day,    type: Integer
      field :hour,   type: Integer
      field :min,    type: Integer
      field :sec,    type: Integer
      field :date,   type: DateTime
      field :timestamp,   type: DateTime
      field :source, type: String, default: 'IB'


      index({ symbol: 1 }, {  name: "symbol_index" })
      index({ date:   1 }, {  name: "date_index" })




    #  field :date, type: String
      #
      def bar_to_quote(symbol,bar)
        puts ">> Save bar: #{bar.inspect}"
        puts ">>> bar time: #{bar.time}"
        dt = Date.ib_to_datetime( bar.time )
        #dt = Date.epoch_to_datetime( bar.time )
        #utc = dt.to_time.utc
        utc = dt.utc
        puts "UTC: #{utc.inspect}"
        utc = ::Time.utc(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.second)

        self.symbol = symbol 
        self.date = bar.time,
        self.open = bar.open 
        self.high = bar.high 
        self.low = bar.low
        self.close = bar.close
        self.volume = bar.volume, 
        self.trades = bar.trades,
        self.year = dt.year 
        self.month = dt.month 
        self.day = dt.day
        self.hour = dt.hour
        self.min = dt.minute 
        self.sec = dt.second
        self.timestamp = utc
        self.source = 'IB'
        #WAP = bar.wap, hasGaps = bar.has_gaps, 
      end

      def save_bar(symbol, bar)
        bar_to_quote(symbol,bar)
        upsert
      end


    end



    class MinuteQuote < Quote
      include Mongoid::Document
      field :bar_size, type: String, default: '1 min'
    end

    class FiveMinuteQuote < Quote
      include Mongoid::Document
      field :bar_size, type: String, default: '5 mins'
    end

    class DayQuote < Quote
      include Mongoid::Document
      field :bar_size, type: String, default: '1 day'
    end

    class RealQuote < Quote
      include Mongoid::Document
    end

  end
end

