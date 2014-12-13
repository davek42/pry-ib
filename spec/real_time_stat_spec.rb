#
#
require 'spec_helper'

describe PryIb::RealTimeStat do

  describe 'calc_atr' do
    before do
      @stat = PryIb::RealTimeStat.new(nil, {})
    end
    it 'return zero by default' do
      atr = @stat.calc_atr(14)
      expect(atr).to   eq(0)
    end

    it 'return atr' do
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

  describe 'calc_mfi' do
    let(:stat) { PryIb::RealTimeStat.new(nil, {}) }
    let(:b1) {make_bar(60,20,40,100)}
    let(:b2) {make_bar(64,36,40,200)}
    let(:b3) {make_bar(50,20,30,300)}
    let(:b4) {make_bar(30,10,20,400)}

    it 'return zero by default' do
      mfi = stat.calc_mfi([],14)
      expect(mfi).to   eq(0)
    end

    it 'return mfi' do
      quotes = [b1]
      mfi = stat.calc_mfi(quotes, 3)
      expect(mfi).to   eq(0)

      mfi_rec = stat.mfis[3].first
      expect(mfi_rec[:tp]).to  eq(40)
      expect(mfi_rec[:direction]).to  eq(1)
      expect(mfi_rec[:volume]).to  eq(100)
      expect(mfi_rec[:raw]).to  eq(40 * 100)
      expect(mfi_rec[:pos_money]).to  eq(40 * 100)
      expect(mfi_rec[:neg_money]).to  eq(0)
      expect(mfi_rec[:ratio]).to  eq(0)

      quotes << b2;
      mfi = stat.calc_mfi(quotes, 3)
      expect(stat.mfis[3].size).to eq(2)
      expect(mfi).to   eq(0)

      quotes << b3
      mfi = stat.calc_mfi(quotes, 3)
      expect(stat.mfis[3].size).to eq(3)
      expect(mfi).to   eq(0)

      quotes << b4
      mfi = stat.calc_mfi(quotes, 3)
      expect(stat.mfis[3].size).to eq(4)
      expect(mfi).to   eq(34)
      
    end
  end

  describe 'sum_money' do
    let(:stat) { PryIb::RealTimeStat.new(nil, {}) }
    let(:rows)  { [{pos_money: 42, neg_money:30},{pos_money: 50, neg_money:-50}] }

    it 'sum pos_money' do
      sum = stat.sum_money(rows, :pos_money, 2)
      expect(sum).to eq(42 + 50)
    end
    it 'sum neg_money' do
      sum = stat.sum_money(rows, :neg_money, 2)
      expect(sum).to eq(30 + (-50))
    end
  end

  describe 'bar_direction' do
    let(:b1) {make_bar(60,20,40,100)}
    let(:b2) {make_bar(64,36,50,200)}
    let(:b3) {make_bar(64,36,30,200)}
    let(:b4) {make_bar(64,36,30,200)}
    it 'positive' do
      direction = PryIb::RealTimeStat.bar_direction(b2,b1)
      expect(direction).to eq(1)
    end
    it 'negative' do
      expect(PryIb::RealTimeStat.bar_direction(b3,b2)).to eq(-1)
    end
    it 'should be positive when no change' do
      expect(PryIb::RealTimeStat.bar_direction(b4,b3)).to eq(1)
    end
  end

  def make_bar(high,low,close,volume)
    bar = IB::Bar.new; bar.high = high; bar.low = low; bar.close = close; bar.volume = volume;
    bar
  end

  describe 'build_bar' do
    before do
      @stat = PryIb::RealTimeStat.new(nil, {})

      @b1 = make_bar(42,30,40,50)
      @b2 = make_bar(48,40,44,50)
    end

    it 'return new bar when no current' do
      result = @stat.build_bar(nil, @b1)
      expect(result).to eq(@b1)
    end

    it 'return new bar when no current' do
      result = @stat.build_bar(@b1, @b2)
      expect(result.high).to eq(@b2.high)
      expect(result.low).to eq(@b1.low)
      expect(result.close).to eq( 44 )
      expect(result.volume).to eq( 100 )
      expect(result.time).to eq(@b2.time)
    end


  end

end

