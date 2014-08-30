require 'spec_helper'

describe PryIb::Commands do
  before do
    puts "-- Start tests --"
  end

  describe "ibhelp" do
    it "outputs help" do
      result = pry_eval('ibhelp')
      expect(result).to   match(/Pry-ib/)
    end
  end


end
