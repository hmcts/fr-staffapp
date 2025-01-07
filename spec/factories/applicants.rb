FactoryBot.define do
  factory :applicant do
    factory :applicant_with_all_details do
      title { Faker::Name.prefix }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Time.zone.today - 20.years }
      ni_number { "AB123#{Random.rand(9)}#{Random.rand(9)}#{Random.rand(9)}C" }
      married { false }
    end

    trait :married do
      married { true }
      partner_first_name { 'john' }
      partner_last_name { 'marmite' }
      partner_ni_number { "AB123#{Random.rand(9)}#{Random.rand(9)}#{Random.rand(9)}D" }
      partner_date_of_birth { Time.zone.today - 22.years }
    end

    trait :ho_number do
      ho_number { 'L1234567/1' }
    end

    trait :under_66 do
      date_of_birth { Time.zone.today - 65.years }
    end

    trait :over_66 do
      date_of_birth { Time.zone.today - 70.years }
    end
  end
end
