# spec/views/online_application_view_spec.rb

require 'rails_helper'

RSpec.describe Views::Overview::OnlineApplicationView do
  let(:online_application) { instance_double(OnlineApplication) }
  let(:online_app_view) { described_class.new(online_application) }
  let(:under_age) { true }

  before do
    allow(online_application).to receive(:partner_first_name).and_return('John')
    allow(online_application).to receive(:partner_first_name).and_return('John')
    allow(online_application).to receive_messages(date_received: Date.new(2023, 1, 1), refund?: true, date_fee_paid: Date.new(2023, 1, 2), partner_last_name: 'Doe', first_name: 'Jane', last_name: 'Smith', ni_number: 'AB123456C', ho_number: 'HO123456', partner_ni_number: 'CD789012E', married?: true, date_of_birth: Date.new(1990, 1, 1), partner_date_of_birth: Date.new(1992, 2, 2), over_16: under_age, over_66: nil)
  end

  describe 'online savings' do
    it 'returns formatted date received' do
      expect(online_app_view.saving_over_66).to eq('No')
    end
  end

  describe '#date_received' do
    it 'returns formatted date received' do
      expect(online_app_view.date_received).to eq('1 January 2023')
    end
  end

  describe '#refund_request' do
    it 'returns Yes if refund is requested' do
      expect(online_app_view.refund_request).to eq('Yes')
    end
  end

  describe '#date_fee_paid' do
    it 'returns formatted date fee paid' do
      expect(online_app_view.date_fee_paid).to eq('2 January 2023')
    end
  end

  describe '#partner_full_name' do
    it 'returns full name of the partner' do
      expect(online_app_view.partner_full_name).to eq('John Doe')
    end
  end

  describe '#full_name' do
    it 'returns full name of the applicant' do
      expect(online_app_view.full_name).to eq('Jane Smith')
    end
  end

  describe '#ni_number' do
    it 'returns formatted NI number' do
      expect(online_app_view.ni_number).to eq('AB 12 34 56 C')
    end
  end

  describe '#ho_number' do
    it 'returns HO number' do
      expect(online_app_view.ho_number).to eq('HO123456')
    end
  end

  describe '#partner_ni_number' do
    it 'returns formatted partner NI number' do
      expect(online_app_view.partner_ni_number).to eq('CD 78 90 12 E')
    end
  end

  describe '#status' do
    it 'returns the marital status' do
      allow(I18n).to receive(:t).with('married_true', scope: 'activemodel.attributes.forms/application/applicant').and_return('Married')
      expect(online_app_view.status).to eq('Married')
    end
  end

  describe '#date_of_birth' do
    it 'returns formatted date of birth' do
      expect(online_app_view.date_of_birth).to eq('1 January 1990')
    end
  end

  describe '#partner_date_of_birth' do
    it 'returns formatted partner date of birth if partner first name is present' do
      expect(online_app_view.partner_date_of_birth).to eq('2 February 1992')
    end

    it 'returns nil if partner first name is nil' do
      allow(online_application).to receive(:partner_first_name).and_return(nil)
      expect(online_app_view.partner_date_of_birth).to be_nil
    end
  end

  describe '#under_age' do
    context 'when under 16' do
      it 'returns the under age status' do
        expect(online_app_view.under_age).to eq('Yes')
      end
    end
    context 'when over 16' do
      let(:under_age) { false }
      it 'returns the under age status' do
        expect(online_app_view.under_age).to eq('No')
      end
    end
  end
end
