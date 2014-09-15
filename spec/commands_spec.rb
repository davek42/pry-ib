require 'spec_helper'

describe PryIb::Commands do
  before do
    #puts "-- Start Commands tests --"
  end

  describe "ibhelp" do
    it "outputs help" do
      result = pry_eval('ibhelp')
      expect(result).to   match(/Pry-ib/)
      expect(result).to   match(/connection/)
      expect(result).to   match(/real/)
    end
  end

  describe "subs" do
    it "outputs help" do
      result = pry_eval('subs -h')
      expect(result).to   match(/Enable IB alerts/)
    end
  end

  describe "scan" do
    it "outputs help" do
      result = pry_eval('scan -h')
      expect(result).to   match(/Run scan/)
      expect(result).to   match(/--num/)
      expect(result).to   match(/--above/)
    end
  end

  describe "order" do
    it "outputs help" do
      result = pry_eval('order -h')
      expect(result).to   match(/Get order status/)
      expect(result).to   match(/--show/)
    end
  end
  describe "chart" do
    it "outputs help" do
      result = pry_eval('chart -h')
      expect(result).to   match(/Get Chart/)
      expect(result).to   match(/--day/)
    end
  end

  describe "account" do
    it "outputs help" do
      result = pry_eval('account -h')
      expect(result).to   match(/Usage: account acct_code/)
    end
  end

  describe "contract" do
    it "outputs help" do
      result = pry_eval('contract -h')
      expect(result).to   match(/Get Contract info/)
    end
  end

  describe "alert" do
    it "outputs help" do
      result = pry_eval('alert -h')
      expect(result).to   match(/Usage: alert symbol/)
    end
  end
  describe "tick" do
    it "outputs help" do
      result = pry_eval('tick -h')
      expect(result).to   match(/Get Tick quote/)
    end
  end
  describe "real" do
    it "outputs help" do
      result = pry_eval('real -h')
      expect(result).to   match(/Usage: real \[/)
    end
  end

  describe "quote" do
    it "outputs help" do
      result = pry_eval('quote -h')
      expect(result).to   match(/Get quote history/)
    end
  end

  describe "bracket" do
    it "outputs help" do
      result = pry_eval('bracket -h')
      expect(result).to   match(/Usage: bracket/)
    end
  end

  describe "connection" do
    it "outputs help" do
      result = pry_eval('connection -h')
      expect(result).to   match(/connection -- manage IB client connection/)
    end
  end

end
