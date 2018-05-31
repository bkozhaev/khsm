FactoryBot.define do
  factory :question do
    answer1 {"#{rand(2001)}"}

    sequence(:text) {|n| "В каком году была косм. одиссея #{n}"}

    sequence(:level) {|n| n % 15}
  end
end