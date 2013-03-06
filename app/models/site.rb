class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  store_in collection: 'sites'

  validates :url, :presence => true, :format => {:with => /(http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:\/~\+#]*[\w\-\@?^=%&amp;\/~\+#])?}/}

  after_initialize :add_http

  token :length => 6, :contains => :alphanumeric

  field :url, type: String
  field :title, type: String

  field :likes, type: Integer, default: 0
  field :dislikes, type: Integer, default: 0
  field :visits, type: Integer, default: 0

  attr_accessible :url, :title

private
  def add_http
    self.url = "http://" + self.url if (self.url && self.url.match(/^https?\:\/\/.+$/).nil?)
  end
end
