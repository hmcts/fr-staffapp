require 'rails_helper'

RSpec.feature 'Evidence check page displayed instead of confirmation' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdiction) { create(:jurisdiction) }
  let(:office) { create(:office, jurisdictions: [jurisdiction]) }
  let(:user) { create(:user, office: office) }

  before do
    login_as user
  end

  let(:application) { create(:application_full_remission, office: office, jurisdiction: jurisdiction) }

  context '1 in 10 spot check' do
    scenario 'User continues from the summary page when building the application and is redirected to evidence check' do
      create(:application_full_remission_ev)
      create_list(:application_full_remission, 9)

      visit application_summary_path(application)

      click_button 'Complete processing'

      expect(page).to have_content "#{application.reference} - For HMRC income checking"

      expect(evidence_check_rendered?).to be true
    end
  end

  context '1 in 2 spotcheck refund application' do
    let(:application) { create(:application_full_remission, :refund, office: office, jurisdiction: jurisdiction) }

    scenario 'User continues from the summary page when building the application and is redirected to evidence check' do
      create(:application_full_remission_ev, :refund)
      create(:application_full_remission, :refund)

      visit application_summary_path(application)

      click_button 'Complete processing'

      expect(page).to have_content "#{application.reference} - For HMRC income checking"

      expect(evidence_check_rendered?).to be true
    end
  end

  scenario 'User tries to display confirmation page directly and is redirected to evidence check' do
    create(:evidence_check, application: application)

    visit application_confirmation_path(application.id)

    expect(evidence_check_rendered?).to be true
  end

  def evidence_check_rendered?
    (%r{/evidence_checks/#{application.evidence_check.id}} =~ page.current_url) != nil
  end
end
