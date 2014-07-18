require 'bigdecimal'
require 'date'
require 'time'
require 'fast_attributes/version'
require 'fast_attributes/builder'
require 'fast_attributes/type_cast'

module FastAttributes
  class << self
    def type_casting
      @type_casting ||= {}
    end

    def get_type_casting(klass)
      type_casting[klass]
    end

    def set_type_casting(klass, casting)
      type_cast klass do
        from 'nil',      to: 'nil'
        from klass.name, to: '%s'
        otherwise casting
      end
    end

    def remove_type_casting(klass)
      type_casting.delete(klass)
    end

    def type_exists?(klass)
      type_casting.has_key?(klass)
    end

    def type_cast(klass, &block)
      type_cast = TypeCast.new(klass)
      type_cast.instance_eval(&block)
      type_casting[klass] = type_cast
    end
  end

  def define_attributes(options = {}, &block)
    builder = Builder.new(self, options)
    builder.instance_eval(&block)
    builder.compile!
  end

  def attribute(*attributes, type)
    builder = Builder.new(self)
    builder.attribute *attributes, type
    builder.compile!
  end

  set_type_casting String,     'String(%s)'
  set_type_casting Integer,    'Integer(%s)'
  set_type_casting Float,      'Float(%s)'
  set_type_casting Array,      'Array(%s)'
  set_type_casting Date,       'Date.parse(%s)'
  set_type_casting Time,       'Time.parse(%s)'
  set_type_casting DateTime,   'DateTime.parse(%s)'
  set_type_casting BigDecimal, 'Float(%s);BigDecimal(%s.to_s)'
end
