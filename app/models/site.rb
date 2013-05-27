# -*- encoding : utf-8 -*-
require "RMagick"
require "net/http"

class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token
  include Mongoid::Taggable

  MAX_URL_REDIRECTS = 5
  URL_REGEX =  /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

  store_in collection: 'sites'

  has_many :comments, dependent: :delete

  after_initialize :add_http
  after_save :crawl_site_if_possible

  field :url , type: String
  field :title , type: String

  field :likes, type: Integer, default: 0
  field :dislikes, type: Integer, default: 0
  field :visits, type: Integer, default: 0
  field :site_crawled, type: Boolean, default: false
  field :published, type: Boolean, default: false

  token :length => 6, :contains => :alphanumeric
  
  attr_accessible :url, :title
  
  validate :url_valid_and_exists

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
        #crawling failed, do nothing, next step will check this
      else
        self.update_attribute :site_crawled, true
      end
    end
  end

  def url_valid_and_exists
    valid = true
    if self.url != '' && URL_REGEX.match(self.url)
      response = nil
      seen = Set.new
      uri = URI.parse(self.url)
      loop do
        break if seen.include? uri.to_s
        break if seen.size > MAX_URL_REDIRECTS
        seen.add(uri.to_s)
        request = Net::HTTP.new(uri.host, uri.port)
        begin
          path = uri.path.blank? ? '/' : uri.path
          response = request.request_head(path)
        rescue
          #cant connect to url 
          errors.add :url, "existiert nicht"
          valid = false
          break
        end
        if response.kind_of?(Net::HTTPRedirection)
          uri = URI.parse(response['location'])
        else
          break
        end
      end
      if response.kind_of?(Net::HTTPSuccess) && response.code == '200'
        self.url = uri.to_s
      else
        errors.add :url, "existiert nicht" if !errors.messages[:url].include? "existiert nicht"
        valid = false
      end
    else
      errors.add :url, "ist ungültig"
      valid = false
    end

    valid
  end
end

