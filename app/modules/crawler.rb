class Crawler
  def initialize(site)
    @site = site
    @site_dir = Rails.root.join(Settings.crawler.sites_folder_path).join(@site.token)
  end

  def crawl_site
    #create folders and save site to current
    create_folders
    wget = system("wget --page-requisites --convert-links --directory-prefix='#{@site_dir}/current/' --force-html --html-extension -e robots=off #{@site.url}")
    
    wget
    #check if wget was successful
    #todo: this does not work, find solution for exception handling for wget
    # if File.exists? "#{@site_dir}/current/index.html"
    #   true
    # else
    #   false
    # end
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
