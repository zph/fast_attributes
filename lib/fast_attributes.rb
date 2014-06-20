require 'fast_attributes/version'

module FastAttributes
  class << self
    def type_casting
      @type_casting ||= {
        'String'   => 'String(%s)',
        'Integer'  => 'Integer(%s)',
        'Array'    => 'Array(%s)',
        'Date'     => 'Date.parse(%s)',
        'Time'     => 'Time.parse(%s)',
        'DateTime' => 'DateTime.parse(%s)'
      }
    end

    def get_type_casting(klass)
      @type_casting[type_from_class(klass)]
    end

    def add_type_casting(klass, casting)
      type_casting[type_from_class(klass)] = casting
    end

    def remove_type_casting(klass)
      type_casting.delete(type_from_class(klass))
    end

    def type_exists?(klass)
      type_casting.has_key?(type_from_class(klass))
    end

    def type_from_class(klass)
      klass.name
    end
  end

  def attribute(*attributes, klass)
    unless FastAttributes.type_exists?(klass)
      raise %(Unsupported attribute type "#{FastAttributes.type_from_class(klass)}")
    end

    @fast_attributes ||= []
    attributes.each do |attribute|
      @fast_attributes << attribute

      type_matching  = "when #{FastAttributes.type_from_class(klass)} then value"
      type_casting   = FastAttributes.get_type_casting(klass) % 'value'
      all_attributes = @fast_attributes.map do |attr|
        "'#{attr}'=>@#{attr}"
      end

      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{attribute}                                             # def name
          @#{attribute}                                              #  @name
        end                                                          # end

        def #{attribute}=(value)                                     # def name=(value)
          @#{attribute} = case value                                 #   @name = case value
                          when nil then nil                          #           when nil    then nil
                          #{type_matching}                           #           when String then value
                          else                                       #           else
                            #{type_casting}                          #             String(value)
                          end                                        #           end
        end                                                          # end

        def attributes                                               # def attributes
          {#{all_attributes.join(',')}}                              #   {'name'=>@name}
        end                                                          # end
      EOS
    end
  end
end
