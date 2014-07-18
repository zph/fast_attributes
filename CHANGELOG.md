**0.5.1 (July 16, 2014)**
* Fix `BigDecimal` type casting. It threw an exception when input value was `Integer` or `Float`  

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
