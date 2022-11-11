require 'rails_helper'

RSpec.describe Jurisdiction do

  let(:jurisdiction) { create(:jurisdiction) }

  it { is_expected.to have_many(:business_entities) }

  describe '.available_for_office' do
    subject { described_class.available_for_office(office) }

    let!(:office) { create(:office, jurisdictions: [jurisdiction2], business_entities: [business_entity]) }
    let(:jurisdiction1) { create(:jurisdiction) }
    let!(:jurisdiction2) { create(:jurisdiction) }
    let(:business_entity) { create(:business_entity, jurisdiction: jurisdiction2) }

    it 'includes jurisdictions which have business entity present' do
      is_expected.to eq([jurisdiction2])
    end

    context 'if a business entity is removed' do
      before { office.business_entities.first.update(valid_to: 1.day.from_now) }

      it 'no longer returns it as available' do
        is_expected.to match_array []
      end
    end
  end

  describe 'validation' do
    it 'enforces presence of name' do
      jurisdiction.name = nil
      expect(jurisdiction).to be_invalid
    end

    it 'enforces unique name' do
      new = build(:jurisdiction, name: jurisdiction.name)
      expect(new).to be_invalid
    end

    it 'enforces unique abbreviation' do
      new = build(:jurisdiction, abbr: jurisdiction.abbr)
      expect(new).to be_invalid
    end

    describe 'allows multiple empty abbreviations' do
      let(:jurisdiction) { create(:jurisdiction, name: 'High Court', abbr: nil) }
      let(:new) { create(:jurisdiction, name: 'County Court', abbr: nil) }

      it { expect(jurisdiction).to be_valid }
      it { expect(new).to be_valid }
    end
  end

  describe 'display' do
    it 'returns abbr if set' do
      expect(jurisdiction.display).to eql(jurisdiction.abbr)
    end

    it 'returns name if abbreviation is empty' do
      jurisdiction.abbr = nil
      expect(jurisdiction.display).to eql(jurisdiction.name)
    end
  end

  describe 'display_full' do
    it 'returns name and abbr if set' do
      expected = "#{jurisdiction.name} (#{jurisdiction.abbr})"
      expect(jurisdiction.display_full).to eq expected
    end

    it 'returns name only if abbreviation is empty' do
      jurisdiction.abbr = nil
      expect(jurisdiction.display_full).to eql(jurisdiction.name)
    end
  end

  describe 'office' do
    describe 'can be nil' do
      before { jurisdiction.offices.clear }
      it { expect(jurisdiction.offices.count).to eq 0 }
      it { expect(jurisdiction).to be_valid }
    end

    it 'can be added' do
      jurisdiction.offices << create(:office)
      jurisdiction.save
      expect(jurisdiction.offices.count).to eq 1
    end

    it 'can have multiple added' do
      jurisdiction.offices.clear
      jurisdiction.offices << create(:office)
      jurisdiction.offices << create(:office)
      jurisdiction.save
      expect(jurisdiction.offices.count).to eq 2
    end
  end
end
