require "factory_girl"

FactoryGirl.define do
  factory :site do
    title "A test page"
    url "http://timewarp.mediacube.at"
    tags "test,tag,system"
    site_crawled false
    published true
  end
end

FactoryGirl.define do
  factory :crawled_site, :class => Site do
    title "A test page"
    url "http://timewarp.mediacube.at"
    tags "test,tag,system"
    site_crawled true
    published true
  end
end