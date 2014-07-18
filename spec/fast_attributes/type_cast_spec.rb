require 'spec_helper'

describe FastAttributes::TypeCast do
  describe '.escape_template' do
    it 'replaces placeholder with proper values' do
      template = '% %s %%s %%%s %%%%s % %a %%a %%%a %%%%a'
      escaped  = FastAttributes::TypeCast.escape_template(template, 'price', 'arg')
      expect(escaped).to eq('% arg %s %arg %%s % price %a %price %%a')
    end
  end

  describe '#template' do
    let(:type_cast) { FastAttributes::TypeCast.new(String) }

    describe 'without any conditions' do
      it 'return exception' do
        expect(type_cast.template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          raise FastAttributes::TypeCast::UnknownTypeCastingError, 'Type casting is not defined'
        EOS
      end
    end

    describe 'when one rule is defined' do
      before do
        type_cast.from 'nil', to: 'nil'
      end

      it 'returns one when statement' do
        expect(type_cast.template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          case %s
          when nil
            nil
          else
            raise FastAttributes::TypeCast::UnknownTypeCastingError, 'Type casting is not defined'
          end
        EOS
      end
    end

    describe 'when three rules are defined' do
      before do
        type_cast.from 'String',  to: 'String(%s)'
        type_cast.from 'Array',   to: 'Array(%s)'
        type_cast.from 'Integer', to: 'Integer(%s)'
      end

      it 'returns three when statements' do
        expect(type_cast.template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          case %s
          when String
            String(%s)
          when Array
            Array(%s)
          when Integer
            Integer(%s)
          else
            raise FastAttributes::TypeCast::UnknownTypeCastingError, 'Type casting is not defined'
          end
        EOS
      end
    end

    describe 'when 2 rules and otherwise condition are defined' do
      before do
        type_cast.from 'Date', to: 'Date.parse(%s)'
        type_cast.from 'Time', to: 'Time.parse(%s)'
        type_cast.otherwise 'Float(%s)'
      end

      it 'returns 2 when statements and overrides default else condition' do
        expect(type_cast.template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          case %s
          when Date
            Date.parse(%s)
          when Time
            Time.parse(%s)
          else
            Float(%s)
          end
        EOS
      end
    end

    describe 'when only otherwise rule is defined' do
      before do
        type_cast.otherwise '42 * %s'
      end

      it 'returns otherwise statement only' do
        expect(type_cast.template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          42 * %s
        EOS
      end
    end
  end

  describe '#rescue_template' do
    let(:type_cast) { FastAttributes::TypeCast.new(Float) }

    describe 'when on_error is not defined' do
      it 'raises default error message' do
        expect(type_cast.rescue_template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          rescue => e
            raise FastAttributes::TypeCast::InvalidValueError, %(Invalid value "\#{%s}" for attribute "%a" of type "Float")
        EOS
      end
    end

    describe 'when on_error is defined' do
      before do
        type_cast.on_error 'ArgumentError', act: '"%s" + "%a"'
      end

      it 'overrides default action' do
        expect(type_cast.rescue_template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          rescue ArgumentError => e
            "%s" + "%a"
        EOS
      end
    end

    describe 'when several on_error methods is called' do
      before do
        type_cast.on_error 'ArgumentError', act: '0'
        type_cast.on_error 'StandardError', act: '1'
      end

      it 'generates several rescue conditions' do
        expect(type_cast.rescue_template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          rescue ArgumentError => e
            0
          rescue StandardError => e
            1
        EOS
      end
    end
  end

  describe '#compile_method_body' do
    let(:type_cast) { FastAttributes::TypeCast.new(Float) }

    before do
      type_cast.from 'nil',   to: 'nil'
      type_cast.from 'Float', to: '%s'
      type_cast.otherwise 'Float(%s)'
      type_cast.on_error 'ArgumentError', act: 'raise "a %s %a"'
      type_cast.on_error 'StandardError', act: 'raise "b %s %a"'
    end


    it 'generates type casting method' do
      expect(type_cast.compile_method_body('price', 'argument').gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
        begin
          case argument
          when nil
            nil
          when Float
            argument
          else
            Float(argument)
          end
        rescue ArgumentError => e
          raise "a argument price"
        rescue StandardError => e
          raise "b argument price"
        end
      EOS
    end
  end
end
