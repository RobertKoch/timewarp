class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  store_in collection: 'sites'

  validates :url, :presence => true, :format => {:with => /^(http(?:s)?\:\/\/[a-zA-Z0-9\-]+(?:\.[a-zA-Z0-9\-]+)*\.[a-zA-Z]{2,6}(?:\/?|(?:\/[\w\-]+)*)(?:\/?|\/\w+\.[a-zA-Z]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$/}

  after_initialize :add_http
  after_save :crawl_site_if_possible

  token :length => 6, :contains => :alphanumeric

  field :url, type: String
  field :title, type: String

  field :likes, type: Integer, default: 0
  field :dislikes, type: Integer, default: 0
  field :visits, type: Integer, default: 0

  attr_accessible :url, :title

  def self.latest(limit = 5)
    order_by('created_at DESC').limit(limit)
  end

  def self.most_viewed(limit = 5)
    order_by('visits DESC').limit(limit)
  end

  def self.top_rated(limit = 5)
    order_by('likes DESC').limit(limit)
  end

private
  def add_http
    self.url = "http://" + self.url if (self.url && self.url.match(/^https?\:\/\/.+$/).nil?)
  end

  def crawl_site_if_possible
    crawler = Crawler.new(self)
    unless crawler.crawl_site
      #todo: error handling for crawler
    end
  end
end

