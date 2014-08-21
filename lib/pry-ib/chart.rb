# chart routines
#
require 'ib-ruby'

module PryIb
class Chart
  PERIODS = { 
    '1min' => '1',
    '5min' => '12', 
    '1hour' => '60',
    '2hour' => '120', 
    'day' => 'D', 
    'week' => 'W', 
  }

  def initialize(ib, symbol )
    @ib = ib
    @symbol = symbol.upcase
  end

  # open stock charts graph
  def open(period='5min')
   per = PERIODS.fetch(period, '5min')

   # http://stockcharts.com/h-sc/ui?s=AAPL&p=1&b=5&g=0&id=p69417306802
   # http://stockcharts.com/h-sc/ui?s=AAPL&p=5&b=5&g=0&id=p39087497645 
    url = "'http://stockcharts.com/h-sc/ui?s=#{@symbol}&p=#{per}&b=5&g=0&id=p78217079667'"
    cmd = "open #{url}"
    system cmd
  end

end
end
