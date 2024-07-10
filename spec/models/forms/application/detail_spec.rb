require 'rails_helper'

RSpec.describe Forms::Application::Detail do
  subject(:form) { described_class.new(detail) }

  params_list = [:fee, :jurisdiction_id, :date_received,
                 :day_date_received, :month_date_received, :year_date_received, :probate,
                 :date_of_death, :day_date_of_death, :month_date_of_death, :year_date_of_death,
                 :deceased_name, :refund, :date_fee_paid, :form_name,
                 :day_date_fee_paid, :month_date_fee_paid, :year_date_fee_paid,
                 :case_number, :emergency, :emergency_reason, :discretion_applied,
                 :discretion_manager_name, :discretion_reason, :statement_signed_by]

  let(:detail) { attributes_for(:detail) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  context 'before validation callbacks' do
    describe 'date applied' do
      before do
        form.day_date_received = 1
        form.month_date_received = 2
        form.year_date_received = 2019
        form.valid?
      end

      it 'saves the values to instance variable' do
        expect(form.date_received.to_fs(:default)).to eq('01/02/2019')
      end
    end
  end

  describe 'when Detail object is passed in' do
    let(:detail) { build_stubbed(:complete_detail) }

    params_list.each do |attr_name|
      next if /day|month|year|emergency/.match?(attr_name.to_s)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq detail.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:detail) { attributes_for(:complete_detail) }

    params_list.each do |attr_name|
      next if /day|month|year|emergency/.match?(attr_name.to_s)

      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq detail[attr_name]
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_numericality_of(:fee).is_less_than(20_000) }
    it { is_expected.to validate_numericality_of(:fee).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }

    context 'when fee is blank' do
      let(:application_details) do
        params = { jurisdiction_id: 1, fee: nil }
        described_class.new(params)
      end

      it 'invalidates the object' do
        expect(application_details.valid?).to be false
      end
    end

    describe 'Date application received' do
      let(:application_details) do
        params = { jurisdiction_id: 1, fee: 500, form_name: 'ABC123' }
        described_class.new(params)
      end

      include_examples 'date_received validation' do
        let(:form) { application_details }
      end
    end

    describe 'probate' do
      subject { probate }

      let(:deceased_name) { 'Bob the builder' }
      let(:probate_status) { true }
      let(:date_of_death) { Time.zone.yesterday }
      let(:date_of_death_day) { date_of_death.day }
      let(:date_of_death_month) { date_of_death.month }
      let(:date_of_death_year) { date_of_death.year }
      let(:date_received) { Time.zone.yesterday }
      let(:probate) do
        params = { jurisdiction_id: 1,
                   fee: 500,
                   day_date_received: date_received.day,
                   month_date_received: date_received.month,
                   year_date_received: date_received.year,
                   probate: probate_status,
                   deceased_name: deceased_name,
                   day_date_of_death: date_of_death_day,
                   month_date_of_death: date_of_death_month,
                   year_date_of_death: date_of_death_year,
                   form_name: 'ABC123' }
        described_class.new(params)
      end

      it { is_expected.to be_valid }

      describe 'when probate unchecked' do
        let(:deceased_name) { nil }
        let(:probate_status) { false }

        it { is_expected.to be_valid }
      end

      describe 'requires' do
        describe 'date of death' do
          describe 'presence' do
            let(:date_of_death_day) { nil }
            let(:date_of_death_month) { nil }
            let(:date_of_death_year) { nil }

            before { probate.valid? }

            it { is_expected.not_to be_valid }

            context 'it returns an error' do
              subject { probate.errors[:date_of_death] }

              it { is_expected.to eq ['Enter the date in this format DD/MM/YYYY'] }
            end
          end

          describe 'range' do
            let(:date_of_death) { Time.zone.tomorrow }

            it { is_expected.not_to be_valid }
          end
        end

        describe 'deceased name' do
          context 'is nil' do
            let(:deceased_name) { nil }
            before { probate.valid? }

            it { is_expected.not_to be_valid }

            context 'it returns an error' do
              subject { probate.errors[:deceased_name] }

              it { is_expected.to eq ["The deceased's name should be entered"] }
            end
          end
        end
      end
    end

    context 'form name' do
      let(:detail) do
        build_stubbed(:complete_detail, form_name: form_name)
      end

      context 'when user types EX160' do
        let(:form_name) { 'EX160' }

        it { is_expected.not_to be_valid }
      end

      context 'when user types ex160' do
        let(:form_name) { 'ex160' }

        it { is_expected.not_to be_valid }
      end

      context 'when user types COP44A' do
        let(:form_name) { 'COP44A' }

        it { is_expected.not_to be_valid }
      end

      context 'when user types COP45A' do
        let(:form_name) { 'COP45A' }

        it { is_expected.to be_valid }
      end

      context 'when form_name is blank' do
        let(:form_name) { '' }

        it { is_expected.not_to be_valid }
      end
    end

    describe 'refund' do
      subject(:refund) do
        params = { jurisdiction_id: 1,
                   fee: 500,
                   date_received: date_received.try(:to_fs, :db),
                   refund: refund_status,
                   date_fee_paid: date_fee_paid.try(:to_fs, :db),
                   form_name: 'ABC123' }
        described_class.new(params)
      end

      let(:current_time) { Time.zone.local(2014, 12, 1, 12, 30, 0) }
      let(:date_received) { Time.zone.local(2014, 11, 15, 12, 30, 0) }
      let(:date_fee_paid) { Time.zone.local(2014, 10, 15, 12, 30, 0) }
      let(:refund_status) { true }

      before { Timecop.freeze(current_time) }
      after { Timecop.return }

      it { is_expected.to be_valid }

      describe 'when refund unchecked' do
        let(:date_fee_paid) { nil }
        let(:refund_status) { false }

        it { is_expected.to be_valid }

        context 'with date fee paid' do
          let(:date_fee_paid) { Time.zone.local(2014, 10, 15, 12, 30, 0) }
          it { is_expected.to be_valid }

          it 'reset date' do
            refund.valid?
            expect(refund.date_fee_paid).to be_nil
          end

        end
      end

      describe 'date fee paid' do
        describe 'range' do
          describe 'maximum boundary is 3 months before date_received' do
            describe 'just inside' do
              let(:date_fee_paid) { Time.zone.local(2014, 8, 16, 0, 10, 0) }

              it { is_expected.to be_valid }
            end

            describe 'on the same day' do
              let(:date_fee_paid) { Time.zone.local(2014, 11, 15, 12, 30, 0) }

              it { is_expected.to be_valid }
            end
          end

          describe 'minimum boundary is the date_received' do
            describe 'just inside' do
              let(:date_fee_paid) { Time.zone.local(2014, 11, 15, 8, 0, 0) }

              it { is_expected.to be_valid }
            end

            describe 'just outside' do
              let(:date_fee_paid) { Time.zone.local(2014, 11, 16, 13, 0, 0) }

              it { is_expected.not_to be_valid }

              it 'returns an error' do
                refund.valid?
                expect(refund.errors[:date_fee_paid]).to eq ['This date can’t be after the application was received']
              end
            end
          end

          describe 'and date received' do
            describe 'longer then 3 months' do
              let(:date_fee_paid) { Time.zone.local(2014, 1, 15, 8, 0, 0) }

              it { is_expected.not_to be_valid }

              it 'returns an error' do
                refund.valid?

                expect(refund.errors[:date_fee_paid]).to eq ['This fee was paid more than 3 months from the date received. Delivery Manager discretion must be applied to progress this application']
              end

              context 'discretion applied' do
                it 'false' do
                  refund.discretion_applied = false
                  expect(refund).to be_valid
                end

                context 'is granted' do
                  before { refund.discretion_applied = true }

                  it 'true' do
                    refund.discretion_reason = 'Dan'
                    refund.discretion_manager_name = 'Looks legit'
                    expect(refund).to be_valid
                  end

                  it 'true but no manager name' do
                    refund.discretion_reason = ''
                    refund.discretion_manager_name = 'Looks legit'

                    expect(refund).not_to be_valid
                  end

                  it 'true but no reason' do
                    refund.discretion_reason = 'Dan'
                    refund.discretion_manager_name = ''

                    expect(refund).not_to be_valid
                  end
                end

                it 'nil' do
                  refund.discretion_applied = nil
                  expect(refund).not_to be_valid
                end
              end

              context 'date_fee_paid within limit and discretion reset' do
                let(:date_fee_paid) { Time.zone.local(2014, 11, 15, 8, 0, 0) }

                context 'discretion value set to nil' do
                  it 'when discretion_applied false' do
                    refund.discretion_applied = false
                    refund.valid?
                    expect(refund.discretion_applied).to be_nil
                  end

                  it 'when discretion_applied true' do
                    refund.discretion_applied = true
                    refund.valid?
                    expect(refund.discretion_applied).to be_nil
                  end

                  context 'when discretion_applied true' do
                    before {
                      refund.discretion_applied = true
                      refund.discretion_reason = 'Paperwork is fine'
                      refund.discretion_manager_name = 'Thompson'
                      refund.valid?
                    }
                    it { expect(refund.discretion_applied).to be_nil }
                    it { expect(refund.discretion_manager_name).to be_nil }
                    it { expect(refund.discretion_reason).to be_nil }
                  end
                end
              end
            end
          end
        end

        describe 'presence' do
          let(:date_fee_paid) { nil }

          before { refund.valid? }

          context 'when date_received is set and is a valid date' do
            it 'sets an error on date_received field' do
              expect(refund.errors[:date_fee_paid]).to eq ['Enter the date in this format DD/MM/YYYY']
            end
          end
        end
      end
    end

    describe 'evidence_reason' do
      let(:reason) do
        params = { jurisdiction_id: 1,
                   fee: 500,
                   date_received: Time.zone.yesterday,
                   emergency: true,
                   emergency_reason: 'REASON',
                   form_name: 'ABC123' }
        described_class.new(params)
      end

      it 'has a valid factory build' do
        expect(reason).to be_valid
      end

      context 'emergency is true' do
        before do
          reason.emergency = false
          reason.emergency_reason = nil
        end

        it 'passes if emergency unchecked' do
          expect(reason.valid?).to be true
        end
      end

      context 'emergency is false' do
        before do
          reason.emergency = true
          reason.emergency_reason = nil
        end

        it 'the reason is not filled in' do
          expect(reason.valid?).not_to be true
        end
      end

      context 'is over 500 characters' do
        before { reason.emergency_reason = ('a' * 500).concat('1') }

        it 'is not valid' do
          expect(reason.valid?).to be false
        end
      end
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(detail) }

    subject(:update_form) do
      form.update(params)
      form.save
    end

    let(:jurisdiction) { create(:jurisdiction) }
    let(:detail) { create(:detail) }

    context 'when attributes are correct' do
      let(:attributes) { attributes_for(:complete_detail, :probate, :refund, :emergency, :probate) }
      let(:params) { attributes.merge(jurisdiction_id: jurisdiction.id) }

      it { is_expected.to be true }

      before do
        update_form
        detail.reload
      end

      it 'saves the parameters in the detail' do
        params.each do |key, value|
          expect(detail.send(key)).to eql(value)
        end
      end
    end

    context 'when attributes are incorrect' do
      let(:params) { { fee: '' } }

      it { is_expected.to be false }
    end

    context 'fee is saved as decimal value' do
      before { update_form }
      let(:params) {
        { jurisdiction_id: jurisdiction.id,
          fee: 11.34,
          date_received: Time.zone.today,
          date_fee_paid: 1.month.ago.to_fs(:db),
          form_name: 'ABC123' }
      }

      it { expect(detail.fee.to_f).to be(11.34) }
      it { expect(form.fee.to_f).to be(11.34) }
    end

    context 'clear unselected data' do
      let(:attributes) { attributes_for(:complete_detail, :probate, :refund, :emergency, :probate) }
      let(:params) { attributes.merge(jurisdiction_id: jurisdiction.id, emergency: false, probate: false) }

      it { is_expected.to be true }

      before do
        update_form
        detail.reload
      end

      it 'resets emergency reason' do
        expect(detail.emergency_reason).to be_nil
      end

      it 'resets probate data' do
        expect(detail.deceased_name).to be_nil
        expect(detail.date_of_death).to be_nil
      end
    end

  end
end
