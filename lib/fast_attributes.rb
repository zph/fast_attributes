require 'date'
require 'time'

module FastAttributes
  class << self
    def type_casting
      @type_casting ||= {
        String   => 'String(%s)',
        Integer  => 'Integer(%s)',
        Array    => 'Array(%s)',
        Date     => 'Date.parse(%s)',
        Time     => 'Time.parse(%s)',
        DateTime => 'DateTime.parse(%s)'
      }
    end

    def get_type_casting(klass)
      @type_casting[klass]
    end

    def set_type_casting(klass, casting)
      type_casting[klass] = casting
    end

    def remove_type_casting(klass)
      type_casting.delete(klass)
    end

    def type_exists?(klass)
      type_casting.has_key?(klass)
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
end

require 'fast_attributes/version'
require 'fast_attributes/builder'
