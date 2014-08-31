#$:.each { |path| puts ">> #{path}" }

require_relative '../lib/pry-ib.rb'
require 'pry/test/helper'



puts( %{
  -------------------------------------------------
  Ruby: #{RUBY_VERSION};
  Ruby Engine: #{defined?(RUBY_ENGINE) ? RUBY_ENGINE : 'ruby'}
  PryIb : #{PryIb::VERSION}
  -------------------------------------------------
}
)
