require "factory_girl"

FactoryGirl.define do
  factory :admin do
    email "admin@timewarp.com"
    password "timewarp"
    password_confirmation "timewarp"
  end
end