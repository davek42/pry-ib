#
#
require 'spec_helper'

describe PryIb::Security do
  before do
    puts "-- Start Security tests --"
  end

  describe "get_contract" do
    it "return stock by default" do
      contract = PryIb::Security.get_contract('AAPL')
      expect(contract.symbol).to   eq('AAPL')
      expect(contract.expiry).to   eq('')
      expect(contract.sec_type).to eq(:stock)
      expect(contract.currency).to eq('USD')
    end
  end

end

