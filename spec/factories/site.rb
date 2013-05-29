require "factory_girl"

FactoryGirl.define do
  factory :site do
    title "A test page"
    url "http://timewarp.mediacube.at"
    tags "test,tag,system"
  end
end