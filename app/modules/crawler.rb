class Crawler
  def initialize(site)
    @site = site
    @site_dir = Rails.root.join(Settings.crawler.sites_folder_path).join(@site.token)
  end

  def crawl_site
    #create folders and save site to current
    create_folders
    wget = system("wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31' --convert-links --force-html --output-document=#{@site_dir}/current/index.html #{@site.url}")
    
    #this would crawl site with all assets
    #wget = system("wget -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.63 Safari/537.31' --page-requisites --convert-links --directory-prefix='#{@site_dir}/current/' --force-html --html-extension -e robots=off #{@site.url}")
    
    wget
  end

  def get_site_title
  end

  def create_folders
    # using FileUtils allows to create dirs progressively
    # so it is not necessary to check if dirs are existing already
    if FileUtils.mkdir_p @site_dir
      Settings.crawler.years.each do |foldername|
        Dir.mkdir(@site_dir.join(foldername))
      end
    end
  end
end
