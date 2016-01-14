[![Gem Version](https://badge.fury.io/rb/clli.svg)](https://badge.fury.io/rb/clli)
[![Build Status](https://travis-ci.org/steventwheeler/clli.svg)](https://travis-ci.org/steventwheeler/clli)

# CLLI

This gem can be used to parse [Common Language Location Identification (CLLI) codes](https://en.wikipedia.org/wiki/CLLI_code). Given a CLLI this gem tries to determine the City, State/Provice, and Country the CLLI represents.

The reference for this gem is [Bell System Practices Section 795-100-100](http://etler.com/docs/BSP/795/795-100-100_I5.pdf)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clli'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clli

## Usage

Parse a CLLI and determine the city, state, and country.
```ruby
clli = CLLI.new('MPLSMNMSDS1')
location = "#{clli.city_name}, #{clli.state_name}, #{clli.country_name}" # Minneapolis, Minnesota, United States
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/steventwheeler/clli.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
