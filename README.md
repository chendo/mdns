# mDNS

[![Gem Version](https://badge.fury.io/rb/mdns.png)](https://rubygems.org/gems/mdns) [![Build Status](https://travis-ci.org/chendo/mdns.png)](https://travis-ci.org/chendo/mdns)

Ever wanted to create your own custom `.local` hostnames on your network? Now you can!

This gem implements a super naive mDNS server that listens for queries matching entries you add, and responds to them.

This gem was created by observing existing mDNS queries and responses. I did not read the RFC, so it might not follow the spec properly.

Tested on OS X Mavericks, Ruby 2.0+. Should work with older versions of Ruby and other *nix OSes.

Should work with any client that implements mDNS resolver.

## Installation

Add this line to your application's Gemfile:

    gem 'mdns'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mdns

## Usage

```ruby
require "mdns"
MDNS.add_record("leet.local", 60, "10.0.13.37") # Add a record for leet.local to resolve to 10.0.13.37 with a TTL of 60 seconds
MDNS.start                                                       # Start listening
```

## Caveats

* Does not "unpublish" a record when stopping.
* Only supports A records

## Contributing

Contributions greatly appreciated! Fork and send a pull request.

## License

The MIT License (MIT)

Copyright (c) 2014 Jack "chendo" Chen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.