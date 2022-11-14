require 'rails_helper'

RSpec.describe Saving do
  subject(:savings) { create(:saving, application: application) }

  let(:fee) { 50 }
  let(:application) { create(:application) }
  let(:detail) { create(:detail, application: application, fee: fee) }

  it { is_expected.to validate_presence_of(:application) }

end
