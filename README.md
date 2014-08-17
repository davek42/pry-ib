# Pry::Ib

This gem is a Pry plugin which provides a CLI for interacting with the Interactive Brokers
API.  It is esstially a mashup of Pry and the excellent ib-ruby gem
which does the direct communication with Ineractive Brokers API.

## Installation

Add this line to your application's Gemfile:

    gem 'pry-ib'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pry-ib
    
## Configuration
In the ~/.pryc the the port host can be set TWS or Gateway being used.
For security reasons, Interactive browser makes multiple TWS and
Gateways reside on the same host. Currently, up to 3 separate are
supported known as "live", "test", "gateway". However, they can be
either TWS or Gateway are just arbitray names given to the ports

```ruby
# File: ~/.pryrc

Pry.config.ib_host = '127.0.0.1'
Pry.config.ib_live_port = 7442
Pry.config.ib_test_port = 7496
Pry.config.ib_gateway_port = 4001
```

## Usage

```
> bundle exec pry
Service Ports: {:tws_live=>7442, :tws_test=>7496, :tws_gateway=>4001}
IB: main(0)> help pry-ib
pry-ib
  alerts             Enable IB alerts
  bracket            Execute Bracket order
  connection         connection -- manage IB client connection
  order              Get order status
  quote              Get quote history
  real               Get Real Time quote
  tick               Get Tick quote
IB: main(0)>
```

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
5. 

## See Also

[IB API](https://www.interactivebrokers.com/en/index.php?f=5041)

[ib-ruby project](https://github.com/ib-ruby/ib-ruby)


