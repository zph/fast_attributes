module FastAttributes
  class UnsupportedTypeError < TypeError
  end

  class Builder
    def initialize(klass, options = {})
      @klass      = klass
      @options    = options
      @attributes = []
    end

    def attribute(*attributes, type)
      unless FastAttributes.type_exists?(type)
        raise UnsupportedTypeError, %(Unsupported attribute type "#{type.name}")
      end

      @attributes << [attributes, type]
    end

    def compile!
      compile_getter!
      compile_setter!

      if @options[:initialize]
        compile_initialize!
      end

      if @options[:attributes]
        compile_attributes!
      end
    end

    private

    def compile_getter!
      each_attribute do |attribute, _|
        @klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{attribute}  # def name
            @#{attribute}   #   @name
          end               # end
        EOS
      end
    end

    def compile_setter!
      each_attribute do |attribute, type|
        type_matching  = "when #{type.name} then value"
        type_casting   = FastAttributes.get_type_casting(type) % 'value'

        @klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{attribute}=(value)              # def name=(value)
            @#{attribute} = case value          #   @name = case value
                            when nil then nil   #           when nil    then nil
                              #{type_matching}  #           when String then value
                            else                #           else
                              #{type_casting}   #             String(value)
                            end                 #           end
          end
        EOS
      end
    end

    def compile_initialize!
      @klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
        def initialize(attributes = {})
          attributes.each do |name, value|
            public_send("\#{name}=", value)
          end
        end
      EOS
    end

    def compile_attributes!
      attributes = @attributes.flat_map(&:first)
      attributes = attributes.map do |attribute|
        "'#{attribute}' => @#{attribute}"
      end

      @klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
        def attributes                # def attributes
          {#{attributes.join(', ')}}  #   {'name' => @name, ...}
        end                           # end
      EOS
    end

    def each_attribute
      @attributes.each do |attributes, type|
        attributes.each do |attribute|
          yield attribute, type
        end
      end
    end
  end
end
