# -*- encoding : utf-8 -*-
require "RMagick"

class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token
  include Mongoid::Taggable

  store_in collection: 'sites'

  has_many :comments

  after_initialize :add_http
  after_save :crawl_site_if_possible

  field :url, type: String
  field :title, type: String

  field :likes, type: Integer, default: 0
  field :dislikes, type: Integer, default: 0
  field :visits, type: Integer, default: 0
  field :site_crawled, type: Boolean, default: false
  field :published, type: Boolean, default: false

  token :length => 6, :contains => :alphanumeric
  
  attr_accessible :url, :title
  
  validates_presence_of :url, :message => "muss angegeben werden" 
  validates :url, :format => {:with => /^(http(?:s)?\:\/\/[a-zA-Z0-9\-]+(?:\.[a-zA-Z0-9\-]+)*\.[a-zA-Z]{2,6}(?:\/?|(?:\/[\w\-]+)*)(?:\/?|\/\w+\.[a-zA-Z]{2,4}(?:\?[\w]+\=[\w\-]+)?)?(?:\&[\w]+\=[\w\-]+)*)$/, :message => "ist ungültig"}

  def take_snapshots
    pics_path = Rails.root.join("public/saved_sites/#{self.token}")

    #snapshots for all versions
    Settings.crawler.years.each do |year|
      kit = IMGKit.new(File.new(pics_path + "#{year}/index.html"), :quality => 85, :width => 1400)
      kit.to_file pics_path + "#{year}.jpg"

      #create small version of pic
      img = Magick::ImageList.new(pics_path + "#{year}.jpg")

      small_img = img.minify.crop 0, 0, 700, 400
      small_img.write(pics_path + "#{year}_preview.jpg"){self.quality = 100}

      if year == 'current'
        small_img_greyscale = small_img.quantize(256, Magick::GRAYColorspace)
        small_img_greyscale.write(pics_path + "#{year}_preview_grey.jpg"){self.quality = 100}
      end 
    end 
  end 

  def self.latest(limit = 5)
    published.order_by('created_at DESC').limit(limit)
  end

  def self.most_viewed(limit = 5)
    published.order_by('visits DESC').limit(limit)
  end

  def self.top_rated(limit = 5)
    published.order_by('likes DESC').limit(limit)
  end

  def self.published
    where(:published => true)
  end

private
  def add_http
    self.url = "http://" + self.url if (self.url && self.url.match(/^https?\:\/\/.+$/).nil?)
  end

  def crawl_site_if_possible
    unless self.site_crawled
      crawler = Crawler.new(self)
      unless crawler.crawl_site
        #todo: error handling for crawler
      else
        self.update_attribute :site_crawled, true
      end
    end
  end
end

