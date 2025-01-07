require 'rails_helper'

RSpec.describe Forms::Application::Applicant do
  subject(:created_applicant) { described_class.new(personal_information) }

  params_list = [:last_name, :date_of_birth, :day_date_of_birth, :month_date_of_birth, :year_date_of_birth,
                 :married, :title, :first_name, :ni_number, :ho_number]

  let(:personal_information) { attributes_for(:personal_information) }

  describe '.permitted_attributes' do
    it 'returns a list of attributes' do
      expect(described_class.permitted_attributes.keys).to match_array(params_list)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_least(2) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }

    describe 'date_of_birth' do

      context 'when the date_of_birth is less than minimum age allowed' do
        let(:minimum_age) { Time.zone.today + 1.day }

        before do
          personal_information[:day_date_of_birth] = minimum_age.day
          personal_information[:month_date_of_birth] = minimum_age.month
          personal_information[:year_date_of_birth] = minimum_age.year
        end

        it { expect(created_applicant.valid?).not_to be true }

        describe 'error message' do
          before { created_applicant.valid? }
          let(:error) { ["Applicant's date of birth cannot be in the future"] }

          it { expect(created_applicant.errors[:date_of_birth]).to eql error }
        end
      end

      context 'when the date_of_birth exceeds maximum allowed age' do
        let(:maximum_age) { Time.zone.today - (described_class::MAXIMUM_AGE + 1).years }

        before do
          personal_information[:day_date_of_birth] = maximum_age.day
          personal_information[:month_date_of_birth] = maximum_age.month
          personal_information[:year_date_of_birth] = maximum_age.year
        end

        it { expect(created_applicant.valid?).not_to be true }

        describe 'error message' do
          before { created_applicant.valid? }
          let(:error) { ["The applicant can't be over #{described_class::MAXIMUM_AGE} years old"] }

          it { expect(created_applicant.errors[:date_of_birth]).to eql error }
        end
      end

      context 'when the the date_of_birth is passed a two digit year' do

        before do
          personal_information[:day_date_of_birth] = 1
          personal_information[:month_date_of_birth] = 11
          personal_information[:year_date_of_birth] = 80
        end

        it { expect(created_applicant.valid?).not_to be true }

        it 'returns an error message, if omitted' do
          created_applicant.valid?
          expect(created_applicant.errors[:date_of_birth]).to eq ['Enter a valid date of birth']
        end
      end
    end

    describe 'married' do
      context 'when true' do
        before { personal_information[:married] = true }

        it { expect(created_applicant.valid?).to be true }
      end

      context 'when false' do
        before { personal_information[:married] = false }

        it { expect(created_applicant.valid?).to be true }
      end

      context 'when not a boolean value' do
        before { personal_information[:married] = 'string' }

        it { expect(created_applicant.valid?).to be false }
      end
    end

    describe 'ni_number' do
      context 'when valid' do
        before { personal_information[:ni_number] = 'AB112233A' }

        it 'passes validation' do
          expect(created_applicant.valid?).to be true
        end
      end

      context 'when blank' do
        before { created_applicant.ni_number = '' }

        it 'passes validation' do
          expect(created_applicant.valid?).to be true
        end
      end

      context 'when invalid' do
        before { created_applicant.ni_number = 'FOOBAR' }

        it 'passes validation' do
          expect(created_applicant.valid?).to be false
        end
      end

      context 'when passed in as lower case' do
        before { created_applicant.ni_number = 'ab112233a' }

        it 'up-cases it to pass the validation' do
          expect(created_applicant.valid?).to be true
        end
      end

      context 'when white space is passed in' do
        before { created_applicant.ni_number = ' AB112233A' }

        it 'strips it away to pass the validation' do
          expect(created_applicant.valid?).to be true
        end
      end
    end
    ['title', 'first_name', 'last_name'].each do |attribute|
      describe attribute.to_s do
        context 'when valid' do
          before { personal_information[attribute.to_sym] = 'Mr' }

          it 'passes validation' do
            expect(created_applicant.valid?).to be true
          end
        end

        context 'when white space is passed in' do
          before do
            personal_information[attribute.to_sym] = ' sm it '
            created_applicant.valid?
          end

          it 'strips it away' do
            expect(created_applicant.send(attribute)).to eql('sm it')
          end
        end
      end
    end

  end

  describe 'when Applicant object is passed in' do
    let(:applicant) { build(:applicant) }
    let(:form) { described_class.new(applicant) }

    params_list.each do |attr_name|
      next if /day|month|year/.match?(attr_name.to_s)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq applicant.send(attr_name)
      end
    end
  end

  describe 'when a Hash is passed in' do
    let(:hash) { attributes_for(:full_personal_information) }
    let(:form) { described_class.new(hash) }

    most_attribs = params_list - [:date_of_birth]

    most_attribs.each do |attr_name|
      next if /day|month|year/.match?(attr_name.to_s)
      it "assigns #{attr_name}" do
        expect(form.send(attr_name)).to eq hash[attr_name]
      end
    end

    it 'assign date_of_birth attribute' do
      day = hash[:day_date_of_birth]
      month = hash[:month_date_of_birth]
      year = hash[:year_date_of_birth]
      form.valid?
      expect(form.date_of_birth).to eq "#{day}/#{month}/#{year}".to_date
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(applicant) }

    subject(:form_save) do
      form.update(params)
      form.save
    end

    let(:application) { create(:application) }
    let(:applicant) { create(:applicant_with_all_details, :married, application: application, ni_number: 'SN143621C') }

    context 'when the attributes are correct' do
      let(:dob) { '01/01/1980' }
      let(:married) { true }

      let(:params) do
        {
          title: 'Mr',
          last_name: 'foo',
          first_name: 'bar',
          day_date_of_birth: '01',
          month_date_of_birth: '01',
          year_date_of_birth: '1980',
          married: married,
          ni_number: 'AB123456A',
          ho_number: 'L6543210'
        }
      end

      let(:parsed_dob) { Date.parse(dob) }

      it { is_expected.to be true }

      before do
        form_save
        applicant.reload
      end

      it 'saves the parameters in the applicant' do
        params.each do |key, value|
          next if /day|month|year/.match?(key.to_s)
          expect(applicant.send(key)).to eql(value)
        end
      end

      it 'saves the correct date of birth' do
        expect(applicant.date_of_birth).to eql(parsed_dob)
      end

      it 'saves the correct ho_number' do
        expect(applicant.ho_number).to eq 'L6543210'
      end

      context 'single' do
        let(:married) { false }
        it 'clears partner info' do
          expect(applicant.partner_first_name).to be_nil
          expect(applicant.partner_last_name).to be_nil
          expect(applicant.partner_ni_number).to be_nil
          expect(applicant.partner_date_of_birth).to be_nil
        end
      end
    end

    context 'when the attributes are incorrect' do
      let(:dob) { '01/01/1980' }
      let(:params) { { last_name: '' } }

      it 'returns false' do
        is_expected.to be false
      end
    end
  end

  describe 'Home office number validations' do
    describe 'New HO format' do
      before { personal_information[:ho_number] = '1212-0001-0240-0490' }

      it { expect(created_applicant.valid?).to be true }

      context 'multiple applicants' do
        before { personal_information[:ho_number] = '1212-0001-0240-0490/1' }

        it { expect(created_applicant.valid?).to be true }
      end

      context 'invalid' do
        context 'not enought digits' do
          before { personal_information[:ho_number] = '1212-0001-0240-040' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'letters mixed in' do
          before { personal_information[:ho_number] = '12s2-0001-0240-0490' }

          it { expect(created_applicant.valid?).to be false }
        end
      end
    end

    context 'when NI not provided' do
      before { personal_information[:ho_number] = 'L1234561' }

      it { expect(created_applicant.valid?).to be true }

      describe 'format for single applicant' do
        context 'invalid only numbers' do
          before { personal_information[:ho_number] = '12345678' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid only letters' do
          before { personal_information[:ho_number] = 'ABCDEFG' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid too short' do
          before { personal_information[:ho_number] = 'L123456' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid letter not at the begining' do
          before { personal_information[:ho_number] = '12L3456' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'when passed in as lower case' do
          before { personal_information[:ho_number] = 'l1234567' }

          it { expect(created_applicant.valid?).to be true }

          it 'capitalize ho number before save' do
            created_applicant.valid?
            expect(created_applicant.ho_number).to eq('L1234567')
          end
        end

      end

      describe 'format for multiple applicants' do
        context 'invalid only numbers' do
          before { personal_information[:ho_number] = '1234567/1' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid only letters' do
          before { personal_information[:ho_number] = 'ABCDEFG/1' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid too short' do
          before { personal_information[:ho_number] = 'L123456/1' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid letter not at the begining' do
          before { personal_information[:ho_number] = '12L3456/1' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid no number after slash' do
          before { personal_information[:ho_number] = 'L1234567/' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid number and letters after slash' do
          before { personal_information[:ho_number] = 'L1234567/1a' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'invalid letters after slash' do
          before { personal_information[:ho_number] = 'L1234567/a' }

          it { expect(created_applicant.valid?).to be false }
        end

        context 'valid numbers only after slash' do
          before { personal_information[:ho_number] = 'L1234567/20' }

          it { expect(created_applicant.valid?).to be true }
        end
      end
    end
  end

end
