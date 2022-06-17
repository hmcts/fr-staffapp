require 'rails_helper'

RSpec.describe Forms::Application::SavingsInvestment do
  subject(:savings_investment_form) { described_class.new(application) }

  params_list = [:min_threshold_exceeded, :over_61, :max_threshold_exceeded, :amount]

  let(:min_threshold) { Settings.savings_threshold.minimum_value }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    let(:application) { create :single_applicant_under_61 }

    before do
      savings_investment_form.update(hash)
    end

    describe 'min_threshold_exceeded' do
      describe 'when false' do
        let(:hash) { { min_threshold_exceeded: false } }

        it { is_expected.to be_valid }
      end

      describe 'when true' do
        let(:hash) { { min_threshold_exceeded: true, amount: min_threshold, over_61: false } }

        it { is_expected.to be_valid }
      end

      describe 'when true' do
        let(:hash) { { min_threshold_exceeded: true, amount: min_threshold - 1, over_61: false } }

        it { is_expected.not_to be_valid }
      end

      describe 'when something other than true of false' do
        let(:hash) { { min_threshold_exceeded: 'blah', over_61: false } }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'max_threshold_exceeded' do
      let(:hash) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: max_exceeded } }

      describe 'is true' do
        let(:max_exceeded) { true }

        it { is_expected.to be_valid }
      end

      describe 'is false' do
        let(:max_exceeded) { false }

        it { is_expected.to be_valid }
      end

      describe 'is nil' do
        let(:max_exceeded) { nil }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'when min_threshold_exceeded and over_61 not set' do
      let(:hash) { { min_threshold_exceeded: true, over_61: nil, amount: 100 } }

      it { is_expected.not_to be_valid }
    end

    describe 'when min_threshold_exceeded and neither party over 61' do
      let(:hash) { { min_threshold_exceeded: true, over_61: false, amount: amount } }

      describe 'amount' do
        describe 'is set above min_threshold' do
          let(:amount) { min_threshold + 1 }

          it { is_expected.to be_valid }
        end

        describe 'is set equal to min_threshold' do
          let(:amount) { min_threshold }

          it { is_expected.to be_valid }
        end

        describe 'is set under min_threshold' do
          let(:amount) { 345 }

          it { is_expected.not_to be_valid }
        end

        describe 'is missing' do
          let(:amount) { nil }

          it { is_expected.not_to be_valid }
        end

        describe 'is non-numeric' do
          let(:amount) { 'foo' }

          it { is_expected.not_to be_valid }
        end
      end
    end

    describe 'when min_threshold_exceeded and partner over 61' do
      let(:hash) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: max_threshold } }

      describe 'max_threshold' do
        describe 'is true' do
          let(:max_threshold) { true }

          it { is_expected.to be_valid }
        end

        describe 'is true' do
          let(:max_threshold) { false }

          it { is_expected.to be_valid }
        end

        describe 'is missing' do
          let(:max_threshold) { nil }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(saving) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:saving) { create :saving }

    context 'when attributes are correct' do
      let(:params) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: false, amount: 3456 } }

      it { is_expected.to be true }

      before do
        update_form
        saving.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(saving.send(key)).to eql(value)
        end
      end
    end

    context 'sets the thresholds from the settings file' do
      it { expect(saving.min_threshold).to eql Settings.savings_threshold.minimum_value }
      it { expect(saving.max_threshold).to eql Settings.savings_threshold.maximum_value }
    end

    context 'when attributes are incorrect' do
      let(:params) { { min_threshold_exceeded: nil } }

      it { is_expected.to be false }
    end

    describe 'amount is decimal number' do
      before do
        update_form
        saving.reload
      end

      context 'rounds down' do
        let(:params) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: false, amount: 10.23 } }

        it { expect(saving.amount.to_i).to be 10 }
      end

      context 'rounds up' do
        let(:params) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: false, amount: 10.55 } }

        it { expect(saving.amount.to_i).to be 11 }
      end

      context 'no rounding for nil value' do
        let(:params) { { min_threshold_exceeded: true, over_61: true, max_threshold_exceeded: false, amount: nil } }

        it { expect(saving.amount.to_i).to be 0 }
      end
    end
  end
end
