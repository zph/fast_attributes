class Book
  extend FastAttributes

  attribute :title, :name, String
  attribute :pages,        Integer
  attribute :authors,      Array
  attribute :published,    Date
  attribute :sold,         Time
  attribute :finished,     DateTime
end
