class Book
  extend FastAttributes

  attribute :title, :name, String
  attribute :pages,        Integer
  attribute :price,        BigDecimal
  attribute :authors,      Array
  attribute :published,    Date
  attribute :sold,         Time
  attribute :finished,     DateTime
  attribute :rate,         Float
end

class Author
  extend FastAttributes

  define_attributes initialize: true do
    attribute :name, String
    attribute :age,  Integer
  end
end

class Publisher
  extend FastAttributes

  define_attributes attributes: true do
    attribute :name,  String
    attribute :books, Integer
  end
end

class Reader
  extend FastAttributes

  define_attributes initialize: true, attributes: true do
    attribute :name, String
    attribute :age,  Integer
  end
end

class Toy
  extend FastAttributes

  attribute :name,  String
  attribute :price, Float

  def name
    "#{super} toy!"
  end

  def price=(value)
    super((value.to_f + 2).to_s)
  end
end

class Window
  extend FastAttributes

  define_attributes initialize: true, attributes: true do
    attribute :height, Integer
    attribute :width,  Integer
  end

  def initialize(attributes = {})
    self.height = 200
    self.width  = 80

    super(attributes)
  end

  def attributes
    super.merge('color' => 'white')
  end
end

class Placeholder < String
end

FastAttributes.type_cast Placeholder do
  otherwise '"%s %%s %%%s %%%%s #{5%%%s}"'
end

class PlaceholderClass
  extend FastAttributes
  attribute :value, Placeholder
end
