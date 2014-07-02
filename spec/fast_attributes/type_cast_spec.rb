require 'spec_helper'

describe FastAttributes::TypeCast do
  describe '#template' do
    let(:type_cast) { FastAttributes::TypeCast.new }

    describe 'without any conditions' do
      it 'return exception' do
        expect(type_cast.template.gsub(' ', '')).to eq <<-EOS.gsub(' ', '').chomp
          raise UnknownTypeCastingError, 'Type casting is not defined'
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
            raise UnknownTypeCastingError, 'Type casting is not defined'
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
            raise UnknownTypeCastingError, 'Type casting is not defined'
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
end
