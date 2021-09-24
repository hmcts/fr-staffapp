require 'rails_helper'

RSpec.describe Forms::Evidence::HmrcCheck do
  subject(:form) { described_class.new(HmrcCheck.new(evidence_check: evidence)) }
  let(:application) { create :application, created_at: '15.3.2021' }
  let(:evidence) { create :evidence_check, application: application }

  let(:params) {
    {
      "from_date_day" => from_date_day,
      "from_date_month" => from_date_month,
      "from_date_year" => from_date_year,
      "to_date_day" => to_date_day,
      "to_date_month" => to_date_month,
      "to_date_year" => to_date_year
    }
  }

  let(:from_date_day) { '1' }
  let(:from_date_month) { '2' }
  let(:from_date_year) { '2021' }
  let(:to_date_day) { '28' }
  let(:to_date_month) { '2' }
  let(:to_date_year) { '2021' }

  describe 'validation' do
    before do
      form.update_attributes(params)
    end

    subject { form.valid? }

    context 'when the from date and to date is valid' do
      it { is_expected.to be true }
    end

    describe 'month range' do
      context 'from_date' do
        context 'day' do
          let(:from_date_day) { '22' }
          it { is_expected.to be false }
        end
        context 'month' do
          let(:from_date_month) { '1' }
          it { is_expected.to be false }
        end
        context 'year' do
          let(:from_date_year) { '2020' }
          it { is_expected.to be false }

          it 'message with correct range' do
            form.valid?
            message = 'Enter a calendar month date range'
            expect(form.errors[:date_range]).to eq [message]
          end
        end
      end

      context 'to_date' do
        context 'day' do
          let(:to_date_day) { '22' }
          it { is_expected.to be false }
        end
        context 'month' do
          let(:to_date_month) { '3' }
          it { is_expected.to be false }
        end
        context 'year' do
          let(:to_date_year) { '2022' }
          it { is_expected.to be false }
        end
      end

      context 'last month' do
        let(:from_date_day) { '1' }
        let(:from_date_month) { '9' }
        let(:from_date_year) { '2021' }
        let(:to_date_day) { '30' }
        let(:to_date_month) { '9' }
        let(:to_date_year) { '2021' }

        it { is_expected.to be false }
        it 'message with correct range' do
          form.valid?
          message = 'Enter a calendar month date range prior to the application submission date: 01/02/2021 - 28/02/2021'
          expect(form.errors[:date_range]).to eq [message]
        end
      end
    end

    context 'from_date' do
      it "has correct format" do
        form.valid?
        expect(form.from_date).to eql('2021-02-01')
      end

      context 'year is not valid' do
        let(:from_date_year) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:from_date_month) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:from_date_month) { '22' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { '' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { nil }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:from_date_day) { 'dd' }

        it { is_expected.to be false }
      end
    end

    context 'to_date' do
      it "has correct format" do
        form.valid?
        expect(form.to_date).to eql('2021-02-28')
      end

      context 'year is not valid' do
        let(:to_date_year) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:to_date_month) { '' }

        it { is_expected.to be false }
      end

      context 'month is not valid' do
        let(:to_date_month) { '21' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { '' }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { nil }

        it { is_expected.to be false }
      end

      context 'day is not valid' do
        let(:to_date_day) { 'dd' }

        it { is_expected.to be false }
      end
    end

  end
end
