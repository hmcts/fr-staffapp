require 'rails_helper'

RSpec.describe Forms::BenefitsEvidence do
  subject(:form) { described_class.new(benefit_override) }

  params_list = [:evidence, :correct, :incorrect_reason]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  let(:benefit_override) { build_stubbed(:benefit_override) }

  describe 'validations' do
    subject { form.valid? }

    before { form.update(params) }

    context 'for attribute "evidence"' do
      let(:params) { { evidence: evidence } }

      context 'when not set' do
        let(:evidence) { nil }

        it { is_expected.to be false }
      end

      context 'for false' do
        let(:evidence) { false }

        it { is_expected.to be true }
      end

      context 'for true' do
        let(:evidence) { true }

        it { is_expected.to be true }
      end

    end
  end

  describe '#save' do
    subject { form.save }

    let(:application) { create(:application, amount_to_pay: 1234) }
    let(:benefit_override) { build(:benefit_override, application: application) }
    let(:updated_application) { subject && application.reload }
    let(:updated_benefit_override) { subject && benefit_override.reload }

    before { form.update(params) }

    context 'for an invalid form' do
      let(:params) { { correct: nil } }

      it { is_expected.to be false }
    end

    context 'for a valid form' do
      context 'when evidence is not provided' do
        let(:params) { { evidence: false } }

        it { is_expected.to be true }

        it 'does set application attributes' do
          expect(updated_application.outcome).to eq 'none'
          expect(updated_application.amount_to_pay).to eq 1234
        end

        it 'does not persist the benefit_override' do
          expect(benefit_override).not_to be_persisted
        end
      end

      context 'when evidence is provided' do
        let(:params) { { evidence: true, correct: nil } }

        it { is_expected.to be true }

        it 'sets application attributes for full benefit' do
          expect(updated_application.outcome).to eql('full')
          expect(updated_application.amount_to_pay).to be_nil
        end

        describe 'does persists the benefit_override with correct values' do
          it { expect(updated_benefit_override).to be_persisted }
          it { expect(updated_benefit_override.correct).to be true }
        end
      end
    end
  end
end
