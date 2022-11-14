require 'rails_helper'

RSpec.describe IncomeCalculationRunner do
  subject(:runner) { described_class.new(application) }

  let(:application) { create(:application, application_type: nil, outcome: nil) }

  describe '#run' do
    let(:calculation) { instance_double(IncomeCalculation, calculate: result) }

    before do
      allow(IncomeCalculation).to receive(:new).with(application).and_return(calculation)

      runner.run

      application.reload
    end

    context 'when result is not nil' do
      let(:result) { { outcome: 'part', amount_to_pay: 100, min_threshold: 1000, max_threshold: 5000, income_max_threshold_exceeded: true } }

      it 'sets application type to income' do
        expect(application.application_type).to eql('income')
      end

      it 'sets application outcome as per result' do
        expect(application.outcome).to eql('part')
      end

      it 'sets amount_to_pay as per result' do
        expect(application.amount_to_pay).to eq(100)
      end

      it 'sets min_threshold as per result' do
        expect(application.income_min_threshold).to eq(1000)
      end

      it 'sets max_threshold as per result' do
        expect(application.income_max_threshold).to eq(5000)
      end

      it 'sets income_max_threshold_exceeded as per result' do
        expect(application.income_max_threshold_exceeded).to be true
      end
    end

    context 'when result is nil' do
      let(:result) { nil }

      it 'does not set application type' do
        expect(application.application_type).to be_nil
      end

      it 'does not set application outcome' do
        expect(application.outcome).to be_nil
      end
    end

  end
end
