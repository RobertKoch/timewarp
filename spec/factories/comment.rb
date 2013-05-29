require "factory_girl"

FactoryGirl.define do
  factory :comment do
    email "mymail@test.com"
    name "The Factory Girl"
    text "A simple text"
    site { FactoryGirl.build(:site) }
  end
end