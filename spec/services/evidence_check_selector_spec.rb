require 'rails_helper'

describe EvidenceCheckSelector do
  subject(:evidence_check_selector) { described_class.new(application, expires_in_days) }

  let(:current_time) { Time.zone.now }
  let(:expires_in_days) { 2 }
  let(:applicant) { create :applicant_with_all_details, application: application }
  describe '#decide!' do
    subject(:decision) do
      Timecop.freeze(current_time) do
        evidence_check_selector.decide!
      end
    end

    context 'for a benefit application' do
      let(:application) { create :application, :income_type, refund: true, benefits: false }

      before do
        # create :application, :income_type, refund: true, benefits: false, applicant: applicant
      end

      it 'never selects the application for evidence_check' do
        binding.pry
        expect(decision).to be nil
      end
    end

    context 'for an application without remission' do
      let(:application) { create :application_no_remission, :no_benefits }

      before do
        create_list :application_no_remission, 9, :no_benefits
      end

      it 'never selects the application for evidence_check' do
        is_expected.to be nil
      end
    end

    describe 'should skip EV check' do
      let(:application) { instance_spy 'Application', outcome: 'full', application_type: 'income', applicant: applicant }
      let(:detail) { build_stubbed :detail }

      before do
        allow(evidence_check_selector).to receive(:evidence_check_type).and_return 'test'
        allow(application).to receive(:detail).and_return detail
      end

      it "creates EV check" do
        evidence_check_selector.decide!
        expect(application).to have_received(:create_evidence_check)
      end

      context 'if it is emergency' do
        let(:detail) { build_stubbed :detail, emergency_reason: 'test' }

        it do
          evidence_check_selector.decide!
          expect(application).not_to have_received(:create_evidence_check)
        end
      end

      context 'if it is benefit application' do
        let(:detail) { build_stubbed :detail, :out_of_time_refund, discretion_applied: false }

        it do
          evidence_check_selector.decide!
          expect(application).not_to have_received(:create_evidence_check)
        end
      end

      context 'if no remissions is granted' do
        let(:application) { instance_spy 'Application', outcome: 'none', application_type: 'income' }

        it do
          evidence_check_selector.decide!
          expect(application).not_to have_received(:create_evidence_check)
        end
      end

      context 'if it is benefit application' do
        let(:application) { instance_spy 'Application', outcome: 'full', application_type: 'benefit' }

        it do
          evidence_check_selector.decide!
          expect(application).not_to have_received(:create_evidence_check)
        end
      end

      context 'if applicant is under 15' do
        let(:application) { instance_spy 'Application', outcome: 'full', application_type: 'income', applicant: applicant }
        let(:applicant) { build :applicant_with_all_details, date_of_birth: dob }

        context '15 years' do
          let(:dob) { 15.years.ago }
          it do
            evidence_check_selector.decide!
            expect(application).not_to have_received(:create_evidence_check)
          end
        end
        context '16 years' do
          let(:dob) { 16.years.ago }
          it do
            evidence_check_selector.decide!
            expect(application).to have_received(:create_evidence_check)
          end
        end
        context '14 years' do
          let(:dob) { 14.years.ago }
          it do
            evidence_check_selector.decide!
            expect(application).not_to have_received(:create_evidence_check)
          end
        end
      end
    end

    context 'for a non-benefit remission application' do
      context 'for a non-refund application' do
        let(:application) { create :application_full_remission, reference: 'XY55-22-3' }

        context 'when the application is the 10th (10% gets checked)' do
          before do
            create_list :application_full_remission, 9
            create_list :application, 5
          end

          it 'creates evidence_check record for the application' do
            is_expected.to be_a(EvidenceCheck)
          end

          it { expect(decision.check_type).to eql 'random' }

          it 'sets expiration on the evidence_check' do
            expect(decision.expires_at).to eql(current_time + expires_in_days.days)
          end

          it 'does not saves the ccmcc check type' do
            expect(decision.checks_annotation).to be nil
          end
        end

        context 'when the application is not the 10th' do
          before do
            create_list :application_full_remission, 4
            create_list :application, 5
          end

          it 'does not create evidence_check record for the application' do
            is_expected.to be nil
          end
        end
      end

      context 'for a refund application' do
        let(:application) { create :application_full_remission, :refund }

        context 'when the application is the 2nd (50% gets checked)' do
          before do
            create_list :application_full_remission, 3, :refund
            create_list :application, 5
          end

          it 'creates evidence_check record for the application' do
            is_expected.to be_a(EvidenceCheck)
          end

          it 'sets expiration on the evidence_check' do
            expect(decision.expires_at).to eql(current_time + expires_in_days.days)
          end
        end

        context 'when the application is not the 2nd' do
          before do
            create_list :application_full_remission, 2, :refund
            create_list :application, 3
          end

          it 'does not create evidence_check record for the application' do
            is_expected.to be nil
          end
        end
      end

      context 'when the application is flagged for failed evidence check' do
        describe 'with ni_number' do
          let(:applicant) { create :applicant_with_all_details }
          let(:application) { create :application_full_remission, reference: 'XY55-22-3', applicant: applicant }
          before { create :evidence_check_flag, reg_number: applicant.ni_number }

          it { is_expected.to be_a(EvidenceCheck) }

          it 'sets the type to "flag"' do
            expect(decision.check_type).to eql 'flag'
          end
        end

        describe 'with ho_number' do
          let(:applicant) { create :applicant_with_all_details, ni_number: '', ho_number: 'L123456' }
          let(:application) { create :application_full_remission, reference: 'L123456', applicant: applicant }
          before { create :evidence_check_flag, reg_number: applicant.ho_number }

          it { is_expected.to be_a(EvidenceCheck) }

          it 'sets the type to "flag"' do
            expect(decision.check_type).to eql 'flag'
          end
        end
      end

      context 'for a application with existing check and same ni_number' do
        let(:evidence_check) { create(:evidence_check, application: application_old) }
        let(:application_old) do
          create(:application, :income_type,
                 state: 1,
                 applicant: applicant_old)
        end
        let(:applicant_old) { create(:applicant, ni_number: 'SN123456D') }

        let(:application) { create(:application, :income_type, applicant: applicant) }
        let(:applicant) { create(:applicant, ni_number: 'SN123456D', date_of_birth: 20.years.ago) }

        before do
          evidence_check
        end

        it 'selects the application for evidence_check' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context 'for a application with existing check and same ni_number with inactive flag' do
        let(:evidence_check) { create(:evidence_check, application: application_old) }
        let(:application_old) do
          create(:application, :income_type,
                 state: 1,
                 applicant: applicant_old)
        end
        let(:applicant_old) { create(:applicant, ni_number: 'SN123456D') }

        let(:application) { create(:application, :income_type, applicant: applicant) }
        let(:applicant) { create(:applicant, ni_number: 'SN123456D', date_of_birth: 20.years.ago) }

        before do
          create :evidence_check_flag, reg_number: applicant.ni_number, active: false
          evidence_check
        end

        it 'selects the application for evidence_check' do
          is_expected.not_to be_a(EvidenceCheck)
        end
      end

      context 'for a application with existing check and same ho_number' do
        let(:evidence_check) { create(:evidence_check, application: application_old) }
        let(:application_old) do
          create(:application, :income_type,
                 state: 1,
                 applicant: applicant_old)
        end
        let(:applicant_old) { create(:applicant, ho_number: 'L123456', ni_number: '') }

        let(:application) { create(:application, :income_type, applicant: applicant) }
        let(:applicant) { create(:applicant, ho_number: 'L123456', ni_number: '', date_of_birth: 20.years.ago) }

        before do
          evidence_check
        end

        it 'selects the application for evidence_check' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context "when applicant's ni number is empty" do
        it 'skips the ni_exist evidence check' do
          applicant = create(:applicant, ni_number: '')
          application = applicant.application

          application_old = create(:application, :income_type, :waiting_for_evidence_state, applicant: applicant)
          create(:evidence_check, application: application_old)

          decision = described_class.new(application, expires_in_days).decide!

          expect(decision).not_to be_a(EvidenceCheck)
        end
      end
    end

    context 'CCMCC application frequency applies' do
      let(:application) { create :application_full_remission, office: ccmcc_office }
      let(:query_type) { nil }
      let(:frequency) { 1 }
      let(:ccmcc_office) { create :office, entity_code: 'DH403' }
      let(:digital_office) { create :office, entity_code: 'dig' }

      before do
        @ccmcc = instance_double(CCMCCEvidenceCheckRules, clean_annotation_data: true)
        allow(CCMCCEvidenceCheckRules).to receive(:new).and_return @ccmcc
        allow(@ccmcc).to receive(:rule_applies?).and_return true
        allow(@ccmcc).to receive(:frequency).and_return frequency
        allow(@ccmcc).to receive(:check_type).and_return '5k rule'
        allow(@ccmcc).to receive(:query_type).and_return query_type
        allow(@ccmcc).to receive(:office_id).and_return ccmcc_office.id
      end

      context 'frequency is calculated against the ccmcc office only' do
        let(:frequency) { 2 }
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }

        context 'digital_office' do
          context 'just refund' do
            let(:application) { create :application_full_remission, :refund, office: ccmcc_office }

            before do
              create :application_full_remission, :refund, office: digital_office
              create :application_full_remission, office: digital_office
            end

            let(:query_type) { CCMCCEvidenceCheckRules::QUERY_REFUND }

            it 'creates evidence_check record for the application' do
              is_expected.not_to be_a(EvidenceCheck)
            end
          end

          context 'just normal' do
            before do
              create :application_full_remission, :refund, office: digital_office
              create :application_full_remission, office: digital_office
            end

            let(:query_type) { nil }

            it 'creates evidence_check record for the application' do
              is_expected.not_to be_a(EvidenceCheck)
            end
          end

          context 'all' do
            let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }
            before do
              create_list :application_full_remission, 2, :refund, office: digital_office
              create :application_full_remission, office: digital_office
            end

            it 'creates evidence_check record for the application' do
              is_expected.not_to be_a(EvidenceCheck)
            end
          end
        end
      end

      context 'query all' do
        let(:frequency) { 2 }
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }

        before do
          create :application_full_remission, :refund, office: ccmcc_office
          create :application, office: ccmcc_office
          create :application, office: digital_office
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context 'query all with singe existing application' do
        let(:frequency) { 1 }
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_ALL }

        before do
          create :application, office: ccmcc_office
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end
      end

      context 'query only non refund applications' do
        before do
          create_list :application_full_remission, 4, office: ccmcc_office
          create_list :application, 5, office: ccmcc_office
          create :application, office: digital_office
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end

        it 'saves the ccmcc check type' do
          expect(decision.checks_annotation).to eq('5k rule')
        end
      end

      context 'query only refund applications' do
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_REFUND }
        before do
          create_list :application_full_remission, 4, :refund, office: ccmcc_office
          create_list :application, 5, office: ccmcc_office
          create :application, :refund, office: digital_office
        end

        it 'creates evidence_check record for the application' do
          is_expected.to be_a(EvidenceCheck)
        end

        it 'saves the ccmcc check type' do
          expect(decision.checks_annotation).to eq('5k rule')
        end

        it "don't clean annotaiton data" do
          decision
          expect(@ccmcc).not_to have_received(:clean_annotation_data)
        end
      end

      context 'the frequency does not match' do
        let(:query_type) { CCMCCEvidenceCheckRules::QUERY_REFUND }
        let(:frequency) { 3 }

        before do
          create_list :application_full_remission, 4, :refund, office: ccmcc_office
          create_list :application, 5, office: ccmcc_office
        end

        it 'cleans the ccmcc annotation data' do
          decision
          expect(@ccmcc).to have_received(:clean_annotation_data)
        end
      end
    end

    context 'HMRC check applies' do
      let(:application) { create :application_full_remission, office: office, applicant: applicant, medium: 'digital' }
      before do
        ev_stub = instance_double(EvidenceCheckFlag, active?: true)
        allow(EvidenceCheckFlag).to receive(:where).and_return [ev_stub]
        Settings.evidence_check.hmrc.office_entity_code = 'dig'
      end

      context 'single applicant' do
        let(:applicant) { create :applicant_with_all_details, married: false }

        context 'office match' do
          let(:office) { create :office, entity_code: 'dig' }

          it 'is hmrc checked' do
            expect(decision.income_check_type).to eql 'hmrc'
          end

          context 'is not digital applicaiton' do
            let(:application) { create :application_full_remission, office: office, applicant: applicant, medium: 'paper' }
            it { expect(decision.income_check_type).not_to eql 'hmrc' }
          end
        end

        context 'office does not match' do
          let(:office) { create :office, entity_code: 'dig01' }

          it 'is paper checked' do
            expect(decision.income_check_type).to eql 'paper'
          end
        end

        context 'setting does not match' do
          let(:office) { create :office, entity_code: 'dig' }
          before { Settings.evidence_check.hmrc.office_entity_code = 'dug' }

          it 'is paper checked' do
            expect(decision.income_check_type).to eql 'paper'
          end
        end
      end

      context 'married applicant' do
        let(:applicant) { create :applicant_with_all_details, married: true }

        context 'office match' do
          let(:office) { create :office, entity_code: 'dig' }

          it 'is paper checked' do
            expect(decision.income_check_type).to eql 'paper'
          end
        end

        context 'office does not match' do
          let(:office) { create :office, entity_code: 'dig01' }

          it 'is paper checked' do
            expect(decision.income_check_type).to eql 'paper'
          end
        end
      end
    end

  end
end
