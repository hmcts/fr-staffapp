# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::RawDataExport do
  subject(:data) { described_class.new(start_date_params, end_date_params) }

  let(:office) { create(:office) }
  let(:decision_date) { Time.zone.now.freeze }
  let(:shared_parameters) { { office: office, business_entity: business_entity, decision_date: } }
  let(:business_entity) { create(:business_entity, sop_code: 135864) }
  let(:start_date) { Time.zone.today - 1.month }
  let(:start_date_params) {
    { day: start_date.day, month: start_date.month, year: start_date.year }
  }
  let(:end_date) { Time.zone.today + 1.month }
  let(:end_date_params) {
    { day: end_date.day, month: end_date.month, year: end_date.year }
  }

  describe 'when initialised with valid data' do
    it { is_expected.to be_a described_class }
  end

  describe '#to_csv' do
    before { create_list(:application_full_remission, 7, :processed_state, shared_parameters) }

    subject { data.to_csv }

    it { is_expected.to be_a String }
  end

  describe 'data returned should only include processed applications' do
    subject { data.total_count }

    let(:alternative_parameters) { { office: create(:office), business_entity: create(:business_entity), decision_date: } }
    let(:ignore_these_parameters) { { office: create(:office, name: 'Digital'), business_entity: business_entity, decision_date: } }
    before do
      # include these
      create_list(:application_full_remission, 1, :processed_state, shared_parameters)
      create(:application_full_remission, :processed_state, alternative_parameters)
      create(:application_part_remission, :processed_state, shared_parameters)
      create(:application_no_remission, :processed_state, shared_parameters)
      # and exclude the following
      create(:application_full_remission, :processed_state, business_entity: business_entity, decision_date: 2.months.ago.freeze)
      create(:application_full_remission, :processed_state, ignore_these_parameters)
      create(:application_full_remission, :waiting_for_evidence_state, shared_parameters)
      create(:application_full_remission, :waiting_for_part_payment_state, shared_parameters)
      create(:application_full_remission, :deleted_state, shared_parameters)
    end

    it { is_expected.to eq 4 }
  end

  describe 'cost estimations' do
    let(:evidence_check_part) { create(:evidence_check_part_outcome, amount_to_pay: 100, application: part_ec, income: 1005) }
    let(:evidence_check_full) { create(:evidence_check_full_outcome, amount_to_pay: 0, application: full_ec, income: 222) }
    let(:evidence_check_none) { create(:evidence_check_incorrect, amount_to_pay: 300.34, application: none_ec, income: 5555) }
    let(:part_payment_none) { create(:part_payment_none_outcome) }
    let(:part_payment_return) { create(:part_payment_return_outcome) }
    let(:part_payment_part) { create(:part_payment_part_outcome) }

    let(:applicant1) { none_no_ec.applicant }
    let(:applicant2) { none_ec.applicant }
    let(:applicant3) { full_no_ec.applicant }
    let(:dob) { 30.years.ago }
    let(:over_66) { false }
    let(:date_received) { Time.zone.today }
    let(:date_online_received) { Time.zone.today }
    let(:partner_over_66) { nil }
    let(:online_application) { create(:online_application, created_at: date_online_received) }

    before {
      evidence_check_part
      evidence_check_full
      evidence_check_none
      applicant1.update(married: true, ho_number: 'L123456', ni_number: nil)
      applicant2.update(married: true, ni_number: 'SN123456C', ho_number: nil, date_of_birth: dob, partner_ni_number: '')
      applicant3.update(married: true, ni_number: nil, ho_number: nil, partner_ni_number: 'SN896325A')
    }
    let(:full_no_ec) {
      create(:application_full_remission, :processed_state, :applicant_full,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 0, decision_cost: 300.24, income_min_threshold_exceeded: true,
             detail: full_no_ec_detail, children_age_band: { one: 1, two: 0 }, income_period: 'last_month')
    }
    let(:full_no_ec_detail) { create(:complete_detail, :litigation_friend, case_number: 'JK123455B', fee: 300.24, jurisdiction: business_entity.jurisdiction, calculation_scheme: 'post_ucd') }

    let(:part_no_ec) {
      create(:application_part_remission, :processed_state,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 50, decision_cost: 250, part_payment: part_payment_part, detail: part_no_ec_detail, income_period: 'average')
    }
    let(:part_no_ec_detail) { create(:complete_detail, :legal_representative, case_number: 'JK123456C', fee: 300, jurisdiction: business_entity.jurisdiction, calculation_scheme: 'pre_ucd') }

    let(:part_no_ec_return_pp) {
      create(:application_part_remission, :processed_state,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 50.6, decision_cost: 0, part_payment: part_payment_return, detail: part_no_ec_return_pp_detail)
    }

    let(:part_no_ec_return_pp_detail) { create(:complete_detail, :applicant, case_number: 'JK123456F', fee: 300.45, jurisdiction: business_entity.jurisdiction) }

    let(:part_no_ec_none_pp) {
      create(:application_part_remission, :processed_state, decision_date:, office: office, business_entity: business_entity,
                                                            amount_to_pay: 50.6, decision_cost: 0, fee: 300.45, part_payment: part_payment_none)
    }

    let(:full_ec) {
      create(:application_full_remission, :processed_state, decision_date:, office: office, business_entity: business_entity,
                                                            amount_to_pay: 0, decision_cost: 300, fee: 300)
    }

    let(:part_ec) {
      create(:application_part_remission, :processed_state, decision_date:, office: office, business_entity: business_entity,
                                                            amount_to_pay: 50, decision_cost: 200, fee: 300, children_age_band: { one: 1, two: 2 })
    }

    let(:none_no_ec) {
      create(:application_no_remission, :processed_state, :applicant_full,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 300.34, decision_cost: 0, fee: 300.34, children: 3, income: 2000, children_age_band: { one: 1, two: 2 })
    }

    let(:none_ec) {
      create(:application_no_remission, :processed_state, :applicant_full,
             decision_date:, office: office, business_entity: business_entity,
             amount_to_pay: 0, decision_cost: 0, children: 3,
             income: 2000, income_max_threshold_exceeded: true, detail: none_ec_detail,
             online_application: online_application, children_age_band: { one: 1, two: 2 }, saving: none_ec_saving)
    }
    let(:none_ec_detail) { create(:complete_detail, :applicant, case_number: 'JK123555F', fee: 300.34, date_received: date_received, jurisdiction: business_entity.jurisdiction) }
    let(:none_ec_saving) { create(:saving, over_66: over_66) }

    let(:none_under_100) { create(:application_no_remission, :processed_state, :applicant_full, decision_date:, office:, income: 100, business_entity: business_entity) }
    let(:none_benefits) { create(:application_no_remission, :processed_state, :applicant_full, decision_date:, office:, income: nil, business_entity: business_entity) }

    context 'no_remission under 100' do
      it do
        id = none_under_100.id
        reference = none_under_100.reference
        export = data.to_csv.split("\n")
        row = "#{id},#{office.name},#{reference}"
        matching_row = export.find { |line| line.include?(row) }
        expect(matching_row).to include('Medium,3500.0,,true,JK123456A')
      end
    end

    context 'no_remission benfits no income' do
      it do
        id = none_benefits.id
        reference = none_benefits.reference
        export = data.to_csv.split("\n")
        row = "#{id},#{office.name},#{reference}"
        matching_row = export.find { |line| line.include?(row) }
        expect(matching_row).to include('Medium,3500.0,,false,JK123456A')
      end
    end

    context 'full_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        full_no_ec
        export = data.to_csv
        jurisdiction = full_no_ec.detail.jurisdiction.name
        office = full_no_ec.office.name
        dob = full_no_ec.applicant.date_of_birth.to_fs
        date_received = full_no_ec.detail.date_received.to_fs
        row = "#{jurisdiction},135864,300.24,0.0,300.24,income,ABC123,,false,false,10,,under,last_month,None,1,1,0,true,No,full,0.0,300.24,paper,false"

        expect(export).to include(row)
        expect(export).to include("#{office},#{full_no_ec.reference}")
        expect(export).to include("JK123455B,,#{dob},#{date_received},#{decision_date.to_fs},,,litigation_friend,true,false,post_ucd")
      end
    end

    context 'part_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        part_no_ec
        export = data.to_csv
        jurisdiction = part_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,50.0,250.0,income,ABC123,,false,false,2000,,,average,NI number,3,1,2,true,No,part,50.0,250.0,paper"
        dob = part_no_ec.applicant.date_of_birth.to_fs
        date_received = part_no_ec.detail.date_received.to_fs

        expect(export).to include(row)
        expect(export).to include("true,false,JK123456C,,#{dob},#{date_received},#{decision_date.to_fs},,,legal_representative,true,true,pre_ucd")
      end

      it 'part payment outcome is "return"' do
        part_no_ec_return_pp
        export = data.to_csv
        jurisdiction = part_no_ec_return_pp.detail.jurisdiction.name
        date_received = part_no_ec_return_pp.detail.date_received.to_fs
        row = "#{jurisdiction},135864,300.45,50.6,249.85,income,ABC123,,false,false,2000,,,,NI number,3,1,2,true,No,part,300.45,0.0,paper"
        dob = part_no_ec_return_pp.applicant.date_of_birth.to_fs

        expect(export).to include(row)
        expect(export).to include("return,false,JK123456F,,#{dob},#{date_received},#{decision_date.to_fs},,,applicant")
      end

      it 'part payment outcome is "none"' do
        part_no_ec_none_pp
        export = data.to_csv
        jurisdiction = part_no_ec_none_pp.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.45,50.6,249.85,income,ABC123,,false,false,2000,,,,NI number,3,1,2,true,No,part,300.45,0.0,paper"
        dob = part_no_ec_none_pp.applicant.date_of_birth.to_fs

        expect(export).to include(row)
        expect(export).to include("false,JK123456A,,#{dob}")
      end
    end

    context 'no_remission' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        none_no_ec
        export = data.to_csv
        jurisdiction = none_no_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.34,300.34,0.0,income,ABC123,,false,false,2000,,,,Home Office number,3,1,2,true,No,none,300.34,0.0,paper"
        expect(export).to include(row)
      end
    end

    context 'no_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        none_ec
        export = data.to_csv
        jurisdiction = none_ec.detail.jurisdiction.name
        date_received = none_ec.detail.date_received.to_fs
        dob = none_ec.applicant.date_of_birth.to_fs
        postcode = none_ec.online_application.postcode
        online_date = none_ec.online_application.created_at.to_fs
        row = "#{jurisdiction},135864,300.34,0.0,300.34,income,ABC123,,false,false,2000,5555,over,,NI number,3,1,2,true,No,none,300.34,0.0,paper"

        expect(export).to include(row)
        expect(export).to include("JK123555F,#{postcode},#{dob},#{date_received},#{decision_date.to_fs},,#{online_date},applicant,false,false")

      end

      context 'over_66' do
        let(:over_66) { true }
        # it matters what they choose not dob filled
        let(:dob) { 60.years.ago }

        it 'fills in estimated_cost based on fee and amount_to_pay' do
          none_ec
          export = data.to_csv
          jurisdiction = none_ec.detail.jurisdiction.name
          row = "#{jurisdiction},135864,300.34,0.0,300.34,income,ABC123,,false,false,2000,5555,over,,NI number,3,1,2,true,Yes,none,300.34,0.0,paper"
          expect(export).to include(row)
        end

        context 'date received' do
          let(:date_received) { 1.month.ago }
          let(:date_online_received) { 2.years.from_now }
          it 'fills in estimated_cost based on fee and amount_to_pay' do
            none_ec
            export = data.to_csv
            jurisdiction = none_ec.detail.jurisdiction.name
            row = "#{jurisdiction},135864,300.34,0.0,300.34,income,ABC123,,false,false,2000,5555,over,,NI number,3,1,2,true,Yes,none,300.34,0.0,paper"
            expect(export).to include(row)
          end
        end
      end
    end

    context 'full_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        full_ec
        export = data.to_csv
        jurisdiction = full_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,0.0,300.0,income,ABC123,,false,false,10,222,,,NI number,1,,,true,No,full,0.0,300.0,paper"
        expect(export).to include(row)
      end
    end

    context 'part_remission with evidence check' do
      it 'fills in estimated_cost based on fee and amount_to_pay' do
        part_ec
        export = data.to_csv
        jurisdiction = part_ec.detail.jurisdiction.name
        row = "#{jurisdiction},135864,300.0,50.0,250.0,income,ABC123,,false,false,2000,1005,,,NI number,3,1,2,true,No,part,100.0,200.0,paper"
        expect(export).to include(row)
      end
    end
  end

  describe 'savings values' do
    let(:date_fee_paid) { '' }
    subject { data.total_count }
    let(:application_no_remission) {
      create(:application_no_remission, :processed_state, :applicant_full, decision_date:, office: office, business_entity: business_entity,
                                                                           amount_to_pay: 300.34, decision_cost: 0, fee: 300.34, children: 3, income: 2000,
                                                                           date_received: date_received, date_fee_paid: date_fee_paid)
    }
    let(:applicant1) {
      application_no_remission.applicant
    }
    let(:savings_under_3_no_max) {
      create(:saving_blank, application: application_no_remission,
                            min_threshold_exceeded: min_threshold, max_threshold_exceeded: max_threshold)
    }

    before do
      savings_under_3_no_max
      applicant1.update(married: true, ho_number: 'L123456', ni_number: nil, date_of_birth: '25/11/2000')
    end

    context 'more then 16 - High (post-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:date_fee_paid) { '10/10/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { true }

      it 'true max true min threshold' do
        export = data.to_csv
        row = "paper,false,false,High,,,false,JK123456A,,25/11/2000,10/11/2020,#{decision_date.to_fs}"
        expect(export).to include(row)
      end
    end

    context 'between 3 and 16 - Medium (post-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { false }

      it 'false max true min threshold' do
        export = data.to_csv
        row = "paper,false,false,Medium,,,false,JK123456A,,25/11/2000,10/11/2020,#{decision_date.to_fs},"
        expect(export).to include(row)
      end
    end

    context '3000 or more - High (pre-UCD)' do
      let(:date_received) { '12/11/2020' }
      let(:min_threshold) { true }
      let(:max_threshold) { nil }

      it 'nil max true min threshold' do
        export = data.to_csv
        row = "paper,false,false,High,,,false,JK123456A,,25/11/2000,12/11/2020"
        expect(export).to include(row)
      end
    end

    context 'under 3000 - Low (pre-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { false }
      let(:max_threshold) { nil }

      it 'false min and nil max threshold' do
        export = data.to_csv
        row = "paper,false,false,Low,,,false,JK123456A,,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end
    end

    context 'under 3000 max_threshold false - Low (post-UCD)' do
      let(:date_received) { '10/11/2020' }
      let(:min_threshold) { false }
      let(:max_threshold) { false }

      it 'false min and false max threshold' do
        export = data.to_csv
        row = "paper,false,false,Low,,,false,JK123456A,,25/11/2000,10/11/2020"
        expect(export).to include(row)
      end
    end

  end

end
