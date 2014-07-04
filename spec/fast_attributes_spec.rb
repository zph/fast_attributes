require 'spec_helper'

describe FastAttributes do
  describe '.type_casting' do
    it 'returns predefined type casting rules' do
      expect(FastAttributes.type_casting).to eq({
        String   => 'String(%s)',
        Integer  => 'Integer(%s)',
        Float    => 'Float(%s)',
        Array    => 'Array(%s)',
        Date     => 'Date.parse(%s)',
        Time     => 'Time.parse(%s)',
        DateTime => 'DateTime.parse(%s)'
      })
    end
  end

  describe '.get_type_casting' do
    before { FastAttributes.send(:remove_instance_variable, :@type_casting) }

    it 'returns type casting function' do
      expect(FastAttributes.get_type_casting(String)).to eq('String(%s)')
      expect(FastAttributes.get_type_casting(Time)).to eq('Time.parse(%s)')
    end
  end

  describe '.set_type_casting' do
    after do
      FastAttributes.remove_type_casting(OpenStruct)
    end

    it 'adds type to supported type casting list' do
      FastAttributes.set_type_casting(OpenStruct, 'OpenStruct.new(a: %s)')
      expect(FastAttributes.get_type_casting(OpenStruct)).to eq('OpenStruct.new(a: %s)')
    end
  end

  describe '.remove_type_casting' do
    before do
      FastAttributes.set_type_casting(OpenStruct, 'OpenStruct.new(a: %s)')
    end

    it 'removes type casting function from supported list' do
      FastAttributes.remove_type_casting(OpenStruct)
      expect(FastAttributes.get_type_casting(OpenStruct)).to be(nil)
    end
  end

  describe '.type_exists?' do
    it 'checks if type is registered' do
      expect(FastAttributes.type_exists?(DateTime)).to be(true)
      expect(FastAttributes.type_exists?(OpenStruct)).to be(false)
    end
  end

  describe '#attribute' do
    it 'raises an exception when type is not supported' do
      type  = Class.new(Object) { def self.name; 'CustomType' end }
      klass = Class.new(Object) { extend FastAttributes }
      expect{klass.attribute(:name, type)}.to raise_error(FastAttributes::UnsupportedTypeError, 'Unsupported attribute type "CustomType"')
    end

    it 'generates getter methods' do
      book = Book.new
      expect(book.respond_to?(:title)).to be(true)
      expect(book.respond_to?(:name)).to be(true)
      expect(book.respond_to?(:pages)).to be(true)
      expect(book.respond_to?(:price)).to be(true)
      expect(book.respond_to?(:authors)).to be(true)
      expect(book.respond_to?(:published)).to be(true)
      expect(book.respond_to?(:sold)).to be(true)
      expect(book.respond_to?(:finished)).to be(true)
    end

    it 'generates setter methods' do
      book = Book.new
      expect(book.respond_to?(:title=)).to be(true)
      expect(book.respond_to?(:name=)).to be(true)
      expect(book.respond_to?(:pages=)).to be(true)
      expect(book.respond_to?(:price=)).to be(true)
      expect(book.respond_to?(:authors=)).to be(true)
      expect(book.respond_to?(:published=)).to be(true)
      expect(book.respond_to?(:sold=)).to be(true)
      expect(book.respond_to?(:finished=)).to be(true)
    end

    it 'setter methods convert values to correct datatype' do
      book = Book.new
      book.title     = 123
      book.name      = 456
      book.pages     = '250'
      book.price     = '2.55'
      book.authors   = 'Jobs'
      book.published = '2014-06-21'
      book.sold      = '2014-06-21 20:45:15'
      book.finished  = '2014-05-20 21:35:20'

      expect(book.title).to eq('123')
      expect(book.name).to eq('456')
      expect(book.pages).to be(250)
      expect(book.price).to eq(2.55)
      expect(book.authors).to eq(%w[Jobs])
      expect(book.published).to eq(Date.new(2014, 6, 21))
      expect(book.sold).to eq(Time.new(2014, 6, 21, 20, 45, 15))
      expect(book.finished).to eq(DateTime.new(2014, 5, 20, 21, 35, 20))
    end

    it 'setter methods accept values which are already in a proper type' do
      book = Book.new
      book.title     = title     = 'One'
      book.name      = name      = 'Two'
      book.pages     = pages     = 250
      book.price     = price     = 2.55
      book.authors   = authors   = %w[Jobs]
      book.published = published = Date.new(2014, 06, 21)
      book.sold      = sold      = Time.new(2014, 6, 21, 20, 45, 15)
      book.finished  = finished  = DateTime.new(2014, 05, 20, 21, 35, 20)

      expect(book.title).to be(title)
      expect(book.name).to be(name)
      expect(book.pages).to be(pages)
      expect(book.price).to eq(price)
      expect(book.authors).to be(authors)
      expect(book.published).to be(published)
      expect(book.sold).to be(sold)
      expect(book.finished).to be(finished)
    end

    it 'setter methods accept nil values' do
      book = Book.new
      book.title     = 'One'
      book.name      = 'Two'
      book.pages     = 250
      book.price     = 2.55
      book.authors   = %w[Jobs]
      book.published = Date.new(2014, 06, 21)
      book.sold      = Time.new(2014, 6, 21, 20, 45, 15)
      book.finished  = DateTime.new(2014, 05, 20, 21, 35, 20)

      book.title     = nil
      book.name      = nil
      book.pages     = nil
      book.price     = nil
      book.authors   = nil
      book.published = nil
      book.sold      = nil
      book.finished  = nil

      expect(book.title).to be(nil)
      expect(book.name).to be(nil)
      expect(book.pages).to be(nil)
      expect(book.price).to be(nil)
      expect(book.authors).to be(nil)
      expect(book.published).to be(nil)
      expect(book.sold).to be(nil)
      expect(book.finished).to be(nil)
    end

    it 'setter methods raise an exception when cannot parse values' do
      book = Book.new

      expect{ book.title = BasicObject.new }.to raise_error(TypeError)
      expect{ book.name = BasicObject.new }.to raise_error(TypeError)
      expect{ book.pages = 'number' }.to raise_error(ArgumentError)
      expect{ book.price = 'price' }.to raise_error(ArgumentError)
      expect{ book.published = 'date' }.to raise_error(ArgumentError)
      expect{ book.sold = 'time' }.to raise_error(ArgumentError)
      expect{ book.finished = 'datetime' }.to raise_error(ArgumentError)
    end
  end

  describe '#define_attributes' do
    describe 'option initialize: true' do
      it 'generates initialize method' do
        reader = Reader.new(name: 104, age: '23')
        expect(reader.name).to eq('104')
        expect(reader.age).to be(23)
      end
    end

    describe 'option attributes: true' do
      it 'generates attributes method' do
        publisher = Publisher.new
        expect(publisher.attributes).to eq({'name' => nil, 'books' => nil})

        reader = Reader.new
        expect(reader.attributes).to eq({'name' => nil, 'age' => nil})
      end

      it 'attributes method return all attributes with their values' do
        publisher = Publisher.new
        publisher.name  = 101
        publisher.books = '20'
        expect(publisher.attributes).to eq({'name' => '101', 'books' => 20})

        reader = Reader.new
        reader.name = 102
        reader.age  = '25'
        expect(reader.attributes).to eq({'name' => '102', 'age' => 25})
      end
    end
  end
end
