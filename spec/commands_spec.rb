require 'helper'

describe PryIb::Command::PryIb do
  before do
    #theme = PryTheme.create(:name => 'wholesome'){}
    #PryTheme::ThemeList.add_theme(theme)

  end

  describe "empty callback" do
    it "outputs help" do
      pry_eval('pry-ib').should =~ /Usage: pry-ib/
    end
  end
  describe "hellotest" do
    it "should say hello" do
      pry_eval('pry-ib hellotest').should == "helloworld\n"
      puts "do something"
    end
  end
end
