FactoryBot.define do
  factory :detail do
    factory :complete_detail do
      jurisdiction
      fee { 310 }
      date_received { Time.zone.today }
      refund { false }
      probate { nil }
      case_number { 'JK123456A' }
      form_name { 'ABC123' }
      form_type { 'Other' }
      claim_type { nil }
      statement_signed_by { 'applicant' }
    end

    trait :probate do
      probate { true }
      deceased_name { 'John Smith' }
      date_of_death { Time.zone.yesterday }
    end

    trait :litigation_friend do
      statement_signed_by { 'litigation_friend' }
    end

    trait :legal_representative do
      statement_signed_by { 'legal_representative' }
    end

    trait :applicant do
      statement_signed_by { 'applicant' }
    end

    trait :refund do
      refund { true }
      date_fee_paid { Time.zone.yesterday }
    end

    trait :out_of_time_refund do
      refund { true }
      date_fee_paid { 3.months.ago }
      date_received { nil }
    end

    trait :emergency do
      emergency_reason { 'It can not wait' }
    end

    after(:build) do |detail|
      detail.application ||= build(:application, detail: detail)
    end

    after(:stub) do |detail|
      around_stub(detail) do
        detail.application ||= build_stubbed(:application, detail: detail)
      end
    end
  end
end
