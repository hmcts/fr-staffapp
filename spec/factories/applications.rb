FactoryGirl.define do
  factory :application do
    title { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth Time.zone.today - 20.years
    ni_number "AB123456C"
    married false
    fee '310.00'
    association :jurisdiction
    date_received Time.zone.today

    factory :probate_application do
      probate true
      deceased_name 'John Smith'
      date_of_death Time.zone.yesterday
    end

    factory :refund_application do
      refund true
      date_fee_paid Time.zone.yesterday
    end
  end
end
