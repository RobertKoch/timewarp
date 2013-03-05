class Crawler
  def initialize(site)
    @site = site
    @site_dir = Settings.crawler.sites_folder_path+"/#{@site.token}"
  end

  def crawl_site
  end

  def get_site_title
  end

  def create_folders
    #create public/sites if not existing
    sites_dir = Settings.crawler.sites_folder_path
    Dir.mkdir(sites_dir) unless File.exists?(sites_dir)

    if Dir.mkdir(@site_dir)
      Settings.crawler.years.each do |foldername|
        Dir.mkdir(@site_dir+"/#{foldername}")
      end
    end
  end
end
