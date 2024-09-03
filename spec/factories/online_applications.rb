FactoryBot.define do
  factory :online_application do

    transient do
      convert_to_application { false }
    end

    married { false }
    min_threshold_exceeded { false }
    max_threshold_exceeded { nil }
    over_66 { false }
    amount { nil }
    benefits { true }
    children { 0 }
    refund { false }
    probate { false }
    ni_number { 'AB123456C' }
    date_of_birth { Time.zone.parse('10/03/1976') }
    first_name { 'Peter' }
    last_name { 'Smith' }
    address { '102 Petty France, London' }
    postcode { 'SW1H 9AJ' }
    email_contact { false }
    phone_contact { false }
    post_contact { false }
    feedback_opt_in { true }

    factory :online_application_with_all_details do
      children { 2 }
      refund { true }
      date_fee_paid { 2.months.ago }
      probate { true }
      deceased_name { 'Some Deceased' }
      date_of_death { 3.months.ago }
      case_number { '234567' }
      form_type { 'Other' }
      claim_type { nil }
      form_name { 'FGDH122' }
      email_contact { true }
      email_address { 'peter.smith@example.com' }
      phone_contact { true }
      phone { '2345678' }
      post_contact { true }
      applying_on_behalf { true }
      legal_representative_first_name { 'John' }
      legal_representative_last_name { 'Lawmen' }
      legal_representative_organisation_name { 'Law and Co' }
      legal_representative_position { 'assistant lawyer' }
      over_16 { true }
      statement_signed_by { 'applicant' }
      income_period { 'average' }
      children_age_band { { 'one' => '1', 'two' => '1' } }
    end

    trait :childandincome6065 do
      fee { 100 }
      jurisdiction
      date_received { Time.zone.today }
      form_name { 'AXEE122' }
      children { 4 }
      benefits { false }
      income_min_threshold_exceeded { true }
      income_max_threshold_exceeded { true }
    end

    trait :with_reference do
      sequence(:reference) { |n| "HWF-#{n.to_s.rjust(3, '0')}-#{SecureRandom.hex(3).upcase[0...3].chars.join}" }
      # reference "HWF-#{SecureRandom.hex(3).upcase.scan(/.{1,3}/).join('-')}"
    end

    trait :emergency_completed do
      fee { 450 }
      jurisdiction
      date_received { Time.zone.today }
      emergency_reason { 'EMERGENCY' }
    end

    trait :completed do
      fee { 450 }
      jurisdiction
      date_received { Time.zone.today }
      form_type { 'Other' }
      form_name { 'ABC123' }
    end

    trait :big_saving do
      fee { 100 }
      jurisdiction
      date_received { Time.zone.today }
      form_name { 'AXEE122' }
      min_threshold_exceeded { true }
      max_threshold_exceeded { true }
    end

    trait :threshold_exceeded do
      min_threshold_exceeded { true }
      amount { 3500 }
    end

    trait :benefits do
      benefits { true }
    end

    trait :income do
      benefits { false }
      income { 450 }
    end

    trait :income1000 do
      benefits { false }
      income { 1000 }
      fee { 6000 }
      jurisdiction
      date_received { Time.zone.today }
      form_name { 'ABC123' }
    end

    trait :income_6065 do
      benefits { false }
      income { 6065 }
    end

    trait :et do
      form_name { 'ET1' }
      case_number { 'ET16/12345' }
    end

    trait :invalid_income do
      benefits { false }
      income { nil }
      income_min_threshold_exceeded { nil }
      income_max_threshold_exceeded { nil }
    end

    trait :with_email do
      email_address { 'foo@bar.com' }
    end

    trait :with_refund do
      refund { true }
      date_fee_paid { 2.months.ago }
    end

    trait :confirm_online do
      refund { false }
      applying_method { 'online' }
    end

    trait :confirm_paper do
      refund { false }
      applying_method { 'paper' }
    end

    trait :with_fee_manager_approval do
      fee { 14_000 }
      fee_manager_firstname { 'Jane' }
      fee_manager_lastname { 'Doe' }
    end

    after(:create) do |online_application, evaluator|
      if evaluator.convert_to_application
        create(:application,
               :processed_state,
               :with_office,
               online_application: online_application,
               reference: online_application.reference)
      end
    end
  end
end
