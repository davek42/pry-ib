# Trading Date Utilities

require 'date'
require 'time'

class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

class Date 
  # See: http://www.chronos-st.org/NYSE_Observed_Holidays-1885-Present.html
  # See: http://www.money-zine.com/Investing/Stocks/Stock-Market-Holidays/
  # Months start from 0. January = 0; December = 11  

  
  #
  HOLIDAYS_2007 = [[2010, 1, 1], [2010, 1, 15], [2010, 2, 19], [2010, 4, 6],  [2010, 5, 28], [2010, 7, 4], [2010, 9, 3], [2010, 11, 22], [2010, 12, 25]]
  HOLIDAYS_2008 = [[2010, 1, 1], [2010, 1, 21], [2010, 2, 18], [2010, 3, 21], [2010, 5, 26], [2010, 7, 4], [2010, 9, 1], [2010, 11, 27], [2010, 12, 25]]
  HOLIDAYS_2009 = [[2010, 1, 1], [2010, 1, 19], [2010, 2, 16], [2010, 4, 10], [2010, 5, 25], [2010, 7, 3], [2010, 9, 7], [2010, 11, 26], [2010, 12, 25]]
  HOLIDAYS_2010 = [[2010, 1, 1], [2010, 1, 18], [2010, 2, 15], [2010, 4, 2],  [2010, 5, 31], [2010, 7, 5], [2010, 9, 6], [2010, 11, 25], [2010, 12, 24], [2010, 12, 25]]
  HOLIDAYS_2011 = [              [2011, 1, 17], [2011, 2, 21], [2011, 4, 22], [2011, 5, 30], [2011, 7, 4], [2011, 9, 5], [2011, 11, 24], [2011, 12, 25]]
  HOLIDAYS_2012 = [[2012, 1, 2], [2012, 1, 16], [2012, 2, 20], [2012, 4, 6],  [2012, 5, 28], [2012, 7, 4], [2012, 9, 3], [2012, 11, 22], [2012, 12, 25]]
  HOLIDAYS_2013 = [[2013, 1, 1], [2013, 1, 21], [2013, 2, 18], [2013, 3, 29],  [2013, 5, 27], [2013, 7, 4], [2013, 9, 2], [2013, 11, 28], [2013, 12, 25]]
  HOLIDAYS_2014 = [[2014, 1, 1], [2014, 1, 20], [2014, 2, 17], [2014, 4, 18],  [2014, 5, 26], [2014, 7, 4], [2014, 9, 1], [2014, 11, 27], [2014, 12, 25]]
  HOLIDAY_MAP = {2007 => HOLIDAYS_2007, 2008 => HOLIDAYS_2008, 2009 => HOLIDAYS_2009, 
                 2010 =>  HOLIDAYS_2010, 2011 =>  HOLIDAYS_2011, 2012 =>  HOLIDAYS_2012,
                 2013 =>  HOLIDAYS_2013, 2014 => HOLIDAYS_2014 }
  
  def weekday?
    (self.wday > 0 and self.wday < 6)   # Sunday is zero; Saturday is 6
  end
  
  def holiday?
    year = self.year
    if HOLIDAY_MAP[year].nil?
      puts("Invalid year: #{year} for day:#{self.inspect}")
      false
    else
      match = HOLIDAY_MAP[year].select do |hol|
         #puts ">> hol: #{hol.inspect}"
         d = Date.new(*hol)
         d == self.to_date 
      end
      (match.size == 1) ? true : false
    end
  end
  
  def trading_day?
    return false if not self.weekday?
    return false if self.holiday?
    true
  end
  
  def next_trading_day
    next_day = self
    begin
       next_day = next_day + 1
    end while( not next_day.trading_day? )
    next_day
  end

  def previous_trading_day
    next_day = self
    begin
       next_day = next_day - 1
    end while( not next_day.trading_day? )
    next_day 
  end
  
  def today_or_previous_trading_day
    return self if self.trading_day?
    self.previous_trading_day
  end

  def self.recent_trading_date( target_date=Time.now.to_date )
    trade_date = target_date.today_or_previous_trading_day
    dt = trade_date.to_datetime

    # set a fake hour and minte near end of day
    dt = DateTime.new( dt.year, dt.month, dt.day, 20, 55 )
  end

  # get the most recent trading date in IB format and with hours set to end of trading day
  def self.recent_ib_trading_date( target_date=Time.now.to_date )
#    trade_date = target_date.today_or_previous_trading_day
#    dt = trade_date.to_datetime

#    # set a fake hour and minte near end of day
#    dt = DateTime.new( dt.year, dt.month, dt.day, 20, 55 )
    
    dt = recent_trading_date(target_date)
    dt.to_ib
  end

  def self.ib_to_datetime(time)
    begin
      tt = time.strip + " -5"  # hack in timezone offset
      dt = DateTime.strptime(tt, '%Y%m%d %H:%M:%S %z')
    rescue => ex
      puts "ERROR: Failed to convert IB time: #{time.inspect}"
      raise ex
    end
  end

  def self.epoch_to_datetime(epoch_time)
    Time.at(epoch_time).to_datetime
  end

  # convert DateTime to ::Time.utc.   This is a Mongo friendly format
  def self.datetime_to_utc(datetime)
    utc = datetime.to_time.utc
    utc = ::Time.utc(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.second)
  end
  
  
  # Note: duplicated from ib-ruby Time
  # Render datetime in IB format (zero padded "yyyymmdd HH:mm:ss")
  def to_ib
    "#{year}#{sprintf("%02d", month)}#{sprintf("%02d", day)} " +
        "#{sprintf("%02d", hour)}:#{sprintf("%02d", min)}:#{sprintf("%02d", sec)}"
  end

  # DateTime in a simple name friendly format (no spaces)
  def to_name
    "#{sprintf("%02d", hour)}_#{sprintf("%02d", min)}_#{sprintf("%02d", sec)}"
  end
  # DateTime in a filesystem name friendly format (no spaces)
  def to_filename
    "#{year}#{sprintf("%02d", month)}#{sprintf("%02d", day)}-" +
        "#{sprintf("%02d", hour)}_#{sprintf("%02d", min)}_#{sprintf("%02d", sec)}"
  end
end 

