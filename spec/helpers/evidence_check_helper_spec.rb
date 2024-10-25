require 'rails_helper'

RSpec.describe EvidenceCheckHelper do
  let(:application) { build(:application, :waiting_for_evidence_state, evidence_check: evidence, income: income1) }
  let(:evidence) { build(:evidence_check, income: income2) }
  let(:income1) { nil }
  let(:income2) { nil }

  describe '#income_increase?' do
    context 'income is nil' do
      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end

    context 'original income is higher then new one' do
      let(:income1) { 2000 }
      let(:income2) { 1999 }

      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end

    context 'original income is lower then new one' do
      let(:income1) { 2000 }
      let(:income2) { 2001 }

      it 'returns false' do
        expect(income_increase?(application)).to be_truthy
      end
    end

    context 'original income is same as the new one' do
      let(:income1) { 2000 }
      let(:income2) { 2000 }

      it 'returns false' do
        expect(income_increase?(application)).to be_falsey
      end
    end
  end

  describe 'display_evidence_section?' do
    let(:application) { build(:application, income_kind: income_kind) }
    let(:income_kind) { {} }

    context 'No match for income kind' do
      let(:income_kind) { { applicant: ['Wage'] } }
      it { expect(display_evidence_section?(application, 'wages')).to be false }
    end

    context 'No match for section name' do
      let(:income_kind) { { applicant: ['Wages'] } }
      it { expect(display_evidence_section?(application, 'wage')).to be false }
    end

    [:wage, :net_profit, :pensions].each do |income_kind_value|
      context 'Wages' do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'wages')).to be true }

        context 'partner' do
          let(:income_kind) { { applicant: [:none_of_the_above], partner: [income_kind_value] } }
          it { expect(display_evidence_section?(application, 'wages')).to be true }
        end
      end
    end

    context 'Maintenance payments' do
      let(:income_kind) { { applicant: [:maintenance_payments] } }
      it { expect(display_evidence_section?(application, 'child_maintenance')).to be true }
    end

    [:working_credit, :child_credit, :jsa, :esa, :universal_credit, :working_credit,
     :pensions].each do |income_kind_value|
      context income_kind_value.to_s do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'benefits_and_credits')).to be true }
      end
    end

    [:rent_from_cohabit, :rent_from_properties].each do |income_kind_value|
      context income_kind_value.to_s do
        let(:income_kind) { { applicant: [income_kind_value] } }
        it { expect(display_evidence_section?(application, 'rental')).to be true }
      end
    end

    context 'Other Income' do
      let(:income_kind) { { applicant: [:other_income] } }
      it { expect(display_evidence_section?(application, 'goods_selling')).to be true }
    end
  end
end
