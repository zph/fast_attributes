class Book
  extend FastAttributes

  attribute :title, :name, String
  attribute :pages,        Integer
  attribute :authors,      Array
  attribute :published,    Date
  attribute :sold,         Time
  attribute :finished,     DateTime
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
