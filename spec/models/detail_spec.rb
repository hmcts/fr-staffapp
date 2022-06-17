require 'rails_helper'

RSpec.describe Detail, type: :model do
  it { is_expected.to validate_presence_of(:application) }

  describe 'before validation' do
    before do
      detail.valid?
    end

    describe 'emergency_reason' do
      let(:detail) { described_class.new(emergency_reason: '') }

      it 'is set to nil if the string is empty' do
        expect(detail.emergency_reason).to be_nil
      end
    end
  end
end
