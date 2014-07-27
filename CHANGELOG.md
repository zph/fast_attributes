**0.7.0 (...)**
* Add support of lenient data types. It allows to define attribute which doesn't correspond to a specific ruby class
```ruby
FastAttributes.type_cast :lenient_attribute do
  from '"yes"', to: 'true'
  from '"no"',  to: 'false'
  otherwise 'nil'
end
    
class LenientAttributes
  extend FastAttributes
  attribute :terms_of_service, :lenient_attribute
end
    
lenient = LenientAttribute.new
lenient.terms_of_service = 'yes'
lenient.terms_of_service # true
```

* Allow to define default data types using class or symbol.
```ruby
class Book
  extend FastAttributes

  attribute :title      String
  attribute :pages,     Integer
  attribute :price,     BigDecimal
  attribute :authors,   Array
  attribute :published, Date
  attribute :sold,      Time
  attribute :finished,  DateTime
  attribute :rate,      Float
end

class LenientBook
  extend FastAttributes

  attribute :title,     :string
  attribute :pages,     :integer
  attribute :price,     :big_decimal
  attribute :authors,   :array
  attribute :published, :date
  attribute :sold,      :time
  attribute :finished,  :date_time
  attribute :rate,      :float
end
```

**0.6.0 (July 20, 2014)**
* Throw custom `FastAttributes::TypeCast::InvalidValueError` exception when value has invalid type.
How auto-generated method looks like:
```ruby
FastAttributes.set_type_casting(String, 'String(%s)')
# def name=(value)
#   @name = begin
#     case value
#     when nil    then nil
#     when String then value
#     else String(value)
#     end
#   rescue => e
#     raise FastAttributes::TypeCast::InvalidValueError, %(Invalid value "#{value}" for attribute "name" of type "String")
#   end
# end
```

* Add `on_error` method to override default rescue block:
```ruby
FastAttributes.type_cast String do
  from 'nil', 	 to: 'nil'
  from 'String', to: '%s'
  otherwise 'String(%s)'
  on_error 'ArgumentError', act: 'nil'
  on_error 'TypeError',     act: '""'
  on_error 'StandardError', act: 'e.message'
end

# def name=(value)
#   @name = begin
#     case value
#     when nil    then nil
#     when String then value
#     else String(value)
#     end
#   rescue ArgumentError => e
#     nil
#   rescue TypeError => e
#     ""
#   rescue StandardError => e
#     e.message
#   end
# end
```

**0.5.2 (July 18, 2014)**
* Throw proper exception when type casting function is not defined

**0.5.1 (July 16, 2014)**
* Fix `BigDecimal` type casting. It threw an exception when input value was `Float`  

**0.5.0 (July 16, 2014)**
* Allow to control any switch statements during typecasting using new DSL.

The default typecasting rule which `fast_attributes` generates for `String` is:
```ruby
   case value
   when nil    then nil
   when String then value
   else String(%s)
   end
```
Method `FastAttributes.set_type_casting` allows only to change `else` condition.
```ruby
FastAttributes.set_type_casting(String, 'String("#{%s}-suffix")')
```

Using `FastAttributes.type_cast` method it's possible to define custom `switch` condition
```ruby
FastAttributes.type_cast String do   # case value
  from 'nil', 	 to: 'nil'           # when nil    then nil
  from 'String', to: '%s'            # when String then value
  from Array,    to: 'raise "Error"' # when Array  then raise "Error"
  otherwise 'String(%s)'             # else String(value)
end                                  # end
```

* Add support to BigDecimal [Filipe Costa](https://github.com/applift/fast_attributes/pull/2)

**0.4.0 (July 5, 2014)**
* Allow to override generated methods

**0.3.0 (July 4, 2014)**
* Support `Float` data type

**0.2.2 (July 2, 2014)**
* Fix uninitialized `@type_casting` variable

**0.2.1 (June 27, 2014)**
* Set minimum ruby version to `1.9.2`

**0.2.0 (June 27, 2014)**
* Add `define_attributes` method which allows to generate `initialize` and `attributes`
* Raise `FastAttributes::UnsupportedTypeError` error when unknown attribute type is specified

**0.1.0 (June 26, 2014)**
* Support `Integer`, `String`, `Array`, `Date`, `Time` and `DateTime` attribute types

**0.0.1 (June 20, 2014)**
* Initial commit
