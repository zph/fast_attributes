module FastAttributes
  class TypeCast
    class UnknownTypeCastingError < StandardError
    end

    def initialize
      @if_conditions  = []
      @else_condition = %q(raise UnknownTypeCastingError, 'Type casting is not defined')
    end

    def from(condition, options = {})
      @if_conditions << [condition, options[:to]]
    end

    def otherwise(else_condition)
      @else_condition = else_condition
    end

    def template
      @template ||= begin
        if @if_conditions.any?
          conditions = @if_conditions.map do |from, to|
            "when #{from}\n" +
            "  #{to}\n"
          end

          "case %s\n" +
          conditions.join +
          "else\n" +
          "  #{@else_condition}\n" +
          "end"
        else
          @else_condition
        end
      end
    end
  end
end
