FactoryBot.define do
  factory :post do
    user
    body { "MyText" }
  end
end
