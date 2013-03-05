class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  store_in collection: 'sites'

  token :length => 6, :contains => :alphanumeric

  field :url, type: String
  field :title, type: String

  field :likes, type: Integer, default: 0
  field :dislikes, type: Integer, default: 0
  field :visits, type: Integer, default: 0

  attr_accessible :url, :title
end
