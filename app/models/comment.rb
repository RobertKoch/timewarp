class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'comments'

  belongs_to :site

  field :email, type: String
  field :name, type: String
  field :text, type: String

  validates :email, :presence => true, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :text, :name, :presence => true

  attr_accessible :email, :name, :text
end
