require 'rails_helper'

RSpec.describe Forms::Application::IncomeKindApplicant do
  subject(:income_kind_form) { described_class.new(application) }
  let(:application) { build(:application) }

  params_list = [:income_kind, :income_kind_applicant]

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validation' do
    let(:income_kind_form) { described_class.new(application) }

    describe 'income' do
      let(:application) { build(:application) }

      it { is_expected.to validate_presence_of(:income_kind_applicant) }
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(application) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:application) { create(:application, income_kind: { applicant: ['test'], partner: ['test2'] }) }

    context 'when attributes are correct' do
      let(:params) { { income_kind_applicant: 'wages' } }

      it { is_expected.to be true }

      before do
        update_form
        application.reload
      end

      it 'saves the parameters in the detail' do
        expect(application.income_kind).to eq({ applicant: ['wages'], partner: ['test2'] })
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { income_kind_applicant: nil } }

      it { is_expected.to be false }
    end
  end

end