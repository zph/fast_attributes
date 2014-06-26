# FastAttributes
[![Gem Version](http://img.shields.io/gem/v/fast_attributes.svg)](http://rubygems.org/gems/fast_attributes)
[![Build Status](http://img.shields.io/travis/applift/fast_attributes.svg)](https://travis-ci.org/applift/fast_attributes)
[![Coverage Status](http://img.shields.io/coveralls/applift/fast_attributes.svg)](https://coveralls.io/r/applift/fast_attributes?branch=master)
[![Code Climate](http://img.shields.io/codeclimate/github/applift/fast_attributes.svg)](https://codeclimate.com/github/applift/fast_attributes)
[![Dependency Status](http://img.shields.io/gemnasium/applift/fast_attributes.svg)](https://gemnasium.com/applift/fast_attributes)

## Motivation
There are already a lot of good and flexible gems which solve the similar problem, allow to define attributes with their types, for example: [virtus](https://github.com/solnic/virtus) or [attrio](https://github.com/jetrockets/attrio). But the disadvantage of existing gems is performance. So, the goal of `fast_attributes` is to make a simple solution which is fast, understandable and easy extendable.

This is [performance benchmark](https://github.com/applift/fast_attributes/blob/master/benchmarks/comparison.rb) of `fast_attributes` and other popular gems.

```
Calculating -------------------------------------
FastAttributes: without values                       
                         71131 i/100ms
FastAttributes: integer values for integer attributes
                          8410 i/100ms
FastAttributes: string values for integer attributes 
                          6869 i/100ms
Attrio: without values                               
                           700 i/100ms
Attrio: integer values for integer attributes        
                          1165 i/100ms
Attrio: string values for integer attributes         
                          1073 i/100ms
Virtus: without values                               
                           898 i/100ms
Virtus: integer values for integer attributes        
                          2123 i/100ms
Virtus: string values for integer attributes         
                           306 i/100ms
-------------------------------------------------
FastAttributes: without values                       
                      1528209.4 (±16.2%) i/s -    1564882 in   1.045527s
FastAttributes: integer values for integer attributes
                        88794.2 (±16.0%) i/s -      92510 in   1.078912s
FastAttributes: string values for integer attributes 
                        77673.3 (±4.7%) i/s -      82428 in   1.063921s
Attrio: without values                               
                         7164.3 (±2.6%) i/s -       7700 in   1.075560s
Attrio: integer values for integer attributes        
                        11932.2 (±2.1%) i/s -      12815 in   1.074474s
Attrio: string values for integer attributes         
                        11007.2 (±0.9%) i/s -      11803 in   1.072382s
Virtus: without values                               
                        10151.0 (±5.5%) i/s -      10776 in   1.065475s
Virtus: integer values for integer attributes        
                        21104.7 (±10.4%) i/s -      21230 in   1.019115s
Virtus: string values for integer attributes         
                         3195.6 (±1.7%) i/s -       3366 in   1.053637s

Comparison:
FastAttributes: without values                       :  1528209.4 i/s
FastAttributes: integer values for integer attributes:    88794.2 i/s - 17.21x slower
FastAttributes: string values for integer attributes :    77673.3 i/s - 19.67x slower
Virtus: integer values for integer attributes        :    21104.7 i/s - 72.41x slower
Attrio: integer values for integer attributes        :    11932.2 i/s - 128.07x slower
Attrio: string values for integer attributes         :    11007.2 i/s - 138.84x slower
Virtus: without values                               :    10151.0 i/s - 150.55x slower
Attrio: without values                               :     7164.3 i/s - 213.31x slower
Virtus: string values for integer attributes         :     3195.6 i/s - 478.22x slower
```

## Installation

Add this line to your application's Gemfile:

    gem 'fast_attributes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fast_attributes

## Usage

Define getter/setter methods:
```ruby
class Book
  extend FastAttributes

  attribute :title, :name, String
  attribute :pages,        Integer
  attribute :authors,      Array
  attribute :published,    Date
  attribute :sold,         Time
  attribute :finished,     DateTime
end

book = Book.new
book.title     = 'There and Back Again'
book.name      = 'The Hobbit'
book.pages     = '200'
book.authors   = 'Tolkien'
book.published = '1937-09-21'
book.sold      = '2014-06-25 13:45'
book.finished  = '1937-08-20 12:35'

#<Book:0x007f9a0110be20
 @authors=["Tolkien"],
 @finished=
  #<DateTime: 1937-08-20T12:35:00+00:00 ((2428766j,45300s,0n),+0s,2299161j)>,
 @name="The Hobbit",
 @pages=200,
 @published=#<Date: 1937-09-21 ((2428798j,0s,0n),+0s,2299161j)>,
 @sold=2014-06-25 13:45:00 +0200,
 @title="There and Back Again">
```

To generate `initialize` and `attributes` methods, attribute definition should be wrapped with `define_attributes`:
```ruby
class Book
  extend FastAttributes

  define_attributes initialize: true, attributes: true do
    attribute :title, :name, String
    attribute :pages,        Integer
    attribute :authors,      Array
    attribute :published,    Date
    attribute :sold,         Time
    attribute :finished,     DateTime
  end
end

book = Book.new(
  title:     'There and Back Again',
  name:      'The Hobbit',
  pages:     '200',
  authors:   'Tolkien',
  published: '1937-09-21',
  sold:      '2014-06-25 13:45',
  finished:  '1937-08-20 12:35'
)

book.attributes
{"title"=>"There and Back Again",
 "name"=>"The Hobbit",
 "pages"=>200,
 "authors"=>["Tolkien"],
 "published"=>#<Date: 1937-09-21 ((2428798j,0s,0n),+0s,2299161j)>,
 "sold"=>2014-06-25 13:45:00 +0200,
 "finished"=>
  #<DateTime: 1937-08-20T12:35:00+00:00 ((2428766j,45300s,0n),+0s,2299161j)>}
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/fast_attributes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
