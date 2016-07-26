# Ruby KNX

Constructs [KNX standard](https://en.wikipedia.org/wiki/KNX_(standard)) datagrams that make it easy to communicate with devices on KNX networks.
It does not implement the transport layer so you can use it with naitive ruby, eventmachine, celluloid or the like.

[![Build Status](https://travis-ci.org/cotag/ruby-knx.svg?branch=master)](https://travis-ci.org/cotag/ruby-knx)

You'll need a gateway. I recommend one that supports TCP/IP such as [MDT Interfaces](http://www.mdt.de/EN_Interfaces.html) however you can use multicast groups if your network is configured to allow this.


## Install the gem

Install it with [RubyGems](https://rubygems.org/)

    gem install knx

or add this to your Gemfile if you use [Bundler](http://gembundler.com/):

    gem 'knx'



## Usage

```ruby
require 'knx'

knx = KNX.new
datagram = knx.read(byte_string)

datagram.source_address.to_s
# => '2.3.4'

datagram.destination_address.to_s
# => '3/4/5'

datagram.data # Returns a byte array
# => [1]

# ...

request = knx.action('1/2/0', true)
byte_string = request.to_binary_s

request = knx.action('1/2/3', 150)
byte_string = request.to_binary_s

# Send byte_string to KNX network to execute the request
# Supports multicast, unicast and TCP/IP tunneling (when supported)

```

We also support [KNX BAOS devices](http://www.weinzierl.de/index.php/en/all-knx/knx-devices-en) devices:


```ruby
require 'knx/object_server'

os = KNX::ObjectServer.new
datagram = os.read(byte_string)

# Can return multiple values
datagram.data.length #=> 1

# Get the item index we are reading
datagram.data[0].id
# => 12

datagram.data[0].value # Returns a binary string
# => "\x01"

# ...

request = os.action(1, true)
byte_string = request.to_binary_s

# Send byte_string to KNX BAOS server to execute the request
# This protocol was designed to be sent over TCP/IP

```


## License and copyright

MIT
