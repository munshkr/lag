# Lug [![Build Status](https://travis-ci.org/munshkr/lug.svg?branch=master)](https://travis-ci.org/munshkr/lug)

A small Ruby logger for debugging libraries and applications.  Pretty much a
clone of [debug](https://github.com/visionmedia/debug) for Node.js

## Features

* Smaller and faster than Ruby's logger
* Colorized output for tty output devices (like stderr)
* Filter log messages by namespace
* Standard logger interface (responds to #debug, #warn, #error, etc.)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lug'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lug

## Usage

TODO: Write usage instructions here

## Benchmark

Performance comparison between Ruby's Logger class and Lug logger classes.
`TtyLogger` colorizes output and calculates elapsed time between lines.

```
                                             user     system      total        real
Logger#debug                             1.390000   0.190000   1.580000 (  1.573497)
Lug::Logger#log                          0.760000   0.030000   0.790000 (  0.791371)
Lug::Logger#log (w/ns)                   0.750000   0.030000   0.780000 (  0.780362)
Lug::TtyLogger#log                       0.770000   0.020000   0.790000 (  0.789664)
Lug::TtyLogger#log (w/ns)                0.740000   0.050000   0.790000 (  0.785129)
Lug::Logger#debug + Standard             0.850000   0.040000   0.890000 (  0.899924)
Lug::Logger#debug + Standard (w/ns)      0.870000   0.040000   0.910000 (  0.899636)
Lug::TtyLogger#debug + Standard          0.870000   0.040000   0.910000 (  0.909398)
Lug::TtyLogger#debug + Standard (w/ns)   0.860000   0.040000   0.900000 (  0.903818)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/munshkr/lug. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
