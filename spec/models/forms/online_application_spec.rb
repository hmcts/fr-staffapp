require 'rails_helper'

RSpec.describe Forms::OnlineApplication do
  subject(:form) { described_class.new(online_application) }

  params_list = [:fee, :jurisdiction_id, :benefits_override, :date_received, :day_date_received, :case_number,
                 :month_date_received, :year_date_received, :form_name, :form_type, :claim_type, :emergency, :emergency_reason, :user_id, :discretion_applied]

  let(:online_application) { build_stubbed(:online_application) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe '#initialize' do
    let(:online_application) { build_stubbed(:online_application, emergency_reason: emergency_reason) }

    context 'when the online application has emergency reason' do
      let(:emergency_reason) { 'REASON' }

      it 'assigns true to the emergency field' do
        expect(form.emergency).to be true
      end
    end

    context 'when the online application does not have emergency reason' do
      let(:emergency_reason) { nil }

      it 'keeps the emergency field nil' do
        expect(form.emergency).to be_nil
      end
    end
  end

  describe '#enable_default_jurisdiction' do
    subject { form.jurisdiction_id }

    let(:user) { create(:staff, jurisdiction: jurisdiction) }

    before { form.enable_default_jurisdiction(user) }

    context 'when the user has no default jurisdiction' do
      let(:jurisdiction) { nil }

      it { is_expected.to be_nil }
    end

    context 'when the user has a default jurisdiction' do
      let(:jurisdiction) { create(:jurisdiction) }

      it { is_expected.to eq jurisdiction.id }
    end
  end

  describe '#enable_default_jurisdiction for user' do
    let(:jurisdiction) { create(:jurisdiction) }
    let(:user) { create(:staff, jurisdiction: jurisdiction) }

    before { form.jurisdiction_id = 1001 }

    context 'when the form has a jurisdiction already' do
      before { form.enable_default_jurisdiction(user) }

      it { expect(form.jurisdiction_id).to eq 1001 }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_numericality_of(:fee).is_less_than(20_000) }
    it { is_expected.to validate_presence_of(:jurisdiction_id) }
    it { is_expected.to validate_length_of(:emergency_reason).is_at_most(500) }

    describe 'date_received' do
      let(:online_application) { build_stubbed(:online_application, :completed) }

      include_examples 'date_received validation'

      context 'received before submitted' do
        before do
          online_application
          form.date_received = 1.month.ago
        end

        it { is_expected.not_to be_valid }
      end

      context 'received same date as submitted' do
        before do
          online_application
          form.date_received = Time.zone.today
        end

        it { is_expected.to be_valid }

      end

      context 'when the application was created and received more the 3 months ago' do
        before do
          Timecop.freeze(5.months.ago) do
            online_application
          end

          form.date_received = 5.months.ago
        end

        it { is_expected.to be_valid }
      end

      context 'received tomorow' do
        before do
          online_application
          form.date_received = Time.zone.tomorrow
        end

        it { is_expected.not_to be_valid }
      end

      context 'received after submitted' do
        before do
          Timecop.freeze(1.day.ago) do
            online_application
          end
          form.date_received = Time.zone.now
        end

        it { is_expected.to be_valid }
      end

      context 'received exactly 3 months after submitted' do
        before do
          Timecop.freeze(3.months.ago) do
            online_application
          end
          form.date_received = Time.zone.now
        end

        it { is_expected.to be_valid }
      end

      context 'received more then 3 months after submitted' do
        before do
          Timecop.freeze(4.months.ago) do
            online_application
          end
          form.date_received = Time.zone.now
        end

        it { is_expected.not_to be_valid }

        context 'dicscretion applied' do
          before do
            form.discretion_applied = true
          end

          it { is_expected.to be_valid }
        end

        context 'dicscretion not applied' do
          before do
            form.discretion_applied = false
          end

          it { is_expected.not_to be_valid }
        end
      end

      context 'received yesterday' do
        before do
          Timecop.travel(Time.zone.local(2014, 10, 1, 12, 30, 0)) do
            online_application
          end
          form.date_received = Time.zone.yesterday
        end

        it { is_expected.not_to be_valid }
      end

    end

    describe 'emergency' do
      before do
        form.emergency = emergency
      end

      context 'when false' do
        let(:emergency) { false }

        it { is_expected.not_to validate_presence_of(:emergency_reason) }
      end

      context 'when true' do
        let(:emergency) { true }

        it { is_expected.to validate_presence_of(:emergency_reason) }
      end
    end

    describe 'form_type' do
      let(:online_application) do
        build_stubbed(:online_application, :completed)
      end

      context 'when form_type is "Other"' do
        it { is_expected.to be_valid }
      end

      context 'when form_type is "Other" and form_name is nil' do
        let(:online_application) do
          build_stubbed(:online_application, :completed, form_name: nil)
        end

        it { is_expected.not_to be_valid }
      end

      context 'when form_type is "N1 Part 7 Claim" and claim_type is nil' do
        let(:online_application) do
          build_stubbed(:online_application, :completed, form_type: 'N1 Part 7 Claim', claim_type: nil)
        end

        it { is_expected.not_to be_valid }
      end

      context 'when form_type is "N1 Part 7 Claim" and claim_type is "Specified"' do
        let(:online_application) do
          build_stubbed(:online_application, :completed, form_type: 'N1 Part 7 Claim', claim_type: "Specified")
        end

        it { is_expected.to be_valid }
      end
    end

    describe 'form_name' do
      let(:online_application) { build_stubbed(:online_application, :completed, form_name: form_name, date_received: 1.minute.from_now) }

      context 'EX160' do
        let(:form_name) { 'EX160' }

        it { is_expected.not_to be_valid }
      end

      context 'EX161' do
        let(:form_name) { 'EX161' }

        it { is_expected.to be_valid }
      end

      context "can't be blank" do
        let(:form_name) { '' }

        it { is_expected.not_to be_valid }
      end
    end

  end

  describe 'reset_date_received_data' do
    let(:online_application) { create(:online_application, date_received: Time.zone.today, discretion_applied: true) }

    it 'clears date received and discretion data' do
      expect(online_application.date_received).not_to be_nil
      expect(online_application.discretion_applied).not_to be_nil

      form.reset_date_received_data
      expect(online_application.date_received).to be_nil
      expect(online_application.discretion_applied).to be_nil
    end
  end

  describe '#save' do
    subject do
      form.update(params)
      form.save
    end

    let(:online_application) { create(:online_application) }
    let(:jurisdiction) { create(:jurisdiction) }

    context 'when the params are correct' do
      let(:params) do
        {
          fee: 100.23,
          jurisdiction_id: jurisdiction.id,
          date_received: Time.zone.today,
          form_type: 'Other',
          claim_type: nil,
          form_name: 'E45',
          emergency: true,
          emergency_reason: 'SOME REASON',
          benefits_override: true,
          user_id: 2
        }
      end
      let(:reloaded_application) do
        subject
        online_application.reload
      end

      describe 'the saved online application' do
        [:fee, :jurisdiction_id, :date_received, :form_type, :form_name, :emergency_reason, :benefits_override, :user_id].each do |key|
          it "has the correct :#{key}" do
            expect(reloaded_application.send(key)).to eql(params[key])
          end
        end
      end

      it { is_expected.to be true }

      describe 'when emergency is false but emergency_reason had been set' do
        let(:online_application) { create(:online_application, emergency_reason: 'SOME REASON') }
        before do
          params[:emergency] = false
        end

        it 'clears the emergency reason' do
          expect(reloaded_application.emergency_reason).to be_nil
        end
      end
    end

    context 'when the params are not correct' do
      let(:params) { {} }

      it { is_expected.to be false }
    end
  end
end
