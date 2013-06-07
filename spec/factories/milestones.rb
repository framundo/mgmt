# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :milestone do
  	sequence(:number) { |n| n }
    start_date "2013-05-10"
    due_date "2013-05-10"
    estimated_hours "9.99"
    client_estimated_hours "9.99"
  end
end
