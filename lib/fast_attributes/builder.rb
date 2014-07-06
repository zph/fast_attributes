module FastAttributes
  class UnsupportedTypeError < TypeError
  end

  class Builder
    def initialize(klass, options = {})
      @klass      = klass
      @options    = options
      @attributes = []
      @methods    = Module.new
    end

    def attribute(*attributes, type)
      unless FastAttributes.type_exists?(type)
        raise UnsupportedTypeError, %(Unsupported attribute type "#{type.name}")
      end

      @attributes << [attributes, type]
    end

    def compile!
      compile_getter
      compile_setter

      if @options[:initialize]
        compile_initialize
      end

      if @options[:attributes]
        compile_attributes
      end

      include_methods
    end

    private

    def compile_getter
      each_attribute do |attribute, _|
        @methods.module_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{attribute}  # def name
            @#{attribute}   #   @name
          end               # end
        EOS
      end
    end

    def compile_setter
      each_attribute do |attribute, type|
        type_cast = FastAttributes.get_type_casting(type)
        template  = escape_template(type_cast.template, 'value')

        @methods.module_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{attribute}=(value)
            @#{attribute} = #{template}
          end
        EOS
      end
    end

    def compile_initialize
      @methods.module_eval <<-EOS, __FILE__, __LINE__ + 1
        def initialize(attributes = {})
          attributes.each do |name, value|
            public_send("\#{name}=", value)
          end
        end
      EOS
    end

    def compile_attributes
      attributes = @attributes.flat_map(&:first)
      attributes = attributes.map do |attribute|
        "'#{attribute}' => @#{attribute}"
      end

      @methods.module_eval <<-EOS, __FILE__, __LINE__ + 1
        def attributes                # def attributes
          {#{attributes.join(', ')}}  #   {'name' => @name, ...}
        end                           # end
      EOS
    end

    def include_methods
      @methods.instance_eval <<-EOS, __FILE__, __LINE__ + 1
        def inspect
          'FastAttributes(#{@attributes.flat_map(&:first).join(', ')})'
        end
      EOS
      @klass.send(:include, @methods)
    end

    def each_attribute
      @attributes.each do |attributes, type|
        attributes.each do |attribute|
          yield attribute, type
        end
      end
    end

    private

    def escape_template(template, argument_name)
      template.gsub(/%+s/) do |match|
        match.each_char.each_slice(2).map do |placeholder|
          case placeholder
          when %w[% s] then argument_name
          when %w[% %] then '%'
          else placeholder.join
          end
        end.join
      end
    end
  end
end
