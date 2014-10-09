#
#
require 'spec_helper'

describe PryIb::RealTimeStat do
  before do
    puts "-- Start Real Time Stat tests --"
  end

 

  describe "calc_atr" do
    before do
      @stat = PryIb::RealTimeStat.new(nil, {})
    end
    it "return zero by default" do
      atr = @stat.calc_atr(14)
      expect(atr).to   eq(0)
    end

    it "return atr" do
      b1 = IB::Bar.new; b1.high = 42; b1.low = 30; b1.close = 40
      @stat.quotes << b1
      atr = @stat.calc_atr(3)
      expect(atr).to   eq(0)
      atr_rec = @stat.atrs[3].first
      expect(atr_rec[:hl]).to  eq(12)
      expect(atr_rec[:hc]).to  eq(0)
      expect(atr_rec[:lc]).to  eq(0)
      expect(atr_rec[:tr]).to  eq(12)

      b2 = IB::Bar.new; b2.high = 44; b2.low = 36; b2.close = 42
      @stat.quotes << b2
      atr = @stat.calc_atr(3)
      expect(atr).to   eq(0)

      atr_rec = @stat.atrs[3].last
      expect(atr_rec[:hl]).to  eq(8)
      expect(atr_rec[:hc]).to  eq(4)
      expect(atr_rec[:lc]).to  eq(4)
      expect(atr_rec[:tr]).to  eq(8)

      b3 = IB::Bar.new; b3.high = 48; b3.low = 38; b3.close = 44
      @stat.quotes << b3
      atr = @stat.calc_atr(3)
      expect(atr).to   eq(10)

      b4 = IB::Bar.new; b4.high = 52; b4.low = 38; b4.close = 48
      @stat.quotes << b4
      atr = @stat.calc_atr(3)
      expect(atr).to   eq(32/3.0)
    end
  end

  describe "build_bar" do
    before do
      @stat = PryIb::RealTimeStat.new(nil, {})
      @b1 = IB::Bar.new; @b1.high = 42; @b1.low = 30; @b1.close = 40; @b1.volume = 50; 
      @b2 = IB::Bar.new; @b2.high = 48; @b2.low = 40; @b2.close = 44; @b2.volume = 50; 
    end

    it "return new bar when no current" do
      result = @stat.build_bar(nil, @b1)
      expect(result).to eq(@b1)
    end

    it "return new bar when no current" do
      result = @stat.build_bar(@b1, @b2)
      expect(result.high).to eq(@b2.high)
      expect(result.low).to eq(@b1.low)
      expect(result.close).to eq( 44 )
      expect(result.volume).to eq( 100 )
      expect(result.time).to eq(@b2.time)
    end


  end

end

