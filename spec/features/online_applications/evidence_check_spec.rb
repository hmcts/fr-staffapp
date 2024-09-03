require 'rails_helper'

RSpec.feature 'Online application processing Evidence check' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdiction) { create(:jurisdiction) }
  let(:office) { create(:office, jurisdictions: [jurisdiction]) }
  let(:user) { create(:user, office: office) }
  let(:online_application_1) do
    create(:online_application, :completed, :with_reference,
           married: false,
           children: 3,
           benefits: false,
           fee: 155,
           form_name: 'D11',
           income_min_threshold_exceeded: false)
  end

  let(:online_application_2) do
    create(:online_application, :completed, :with_reference,
           married: false,
           children: 0,
           benefits: false,
           fee: 155,
           form_name: 'D11',
           income: 1000,
           ni_number: online_application_1.ni_number,
           created_at: 2.months.ago)
  end
  let(:old_application) { create(:old_application, reference: online_application_1.reference) }

  before do
    login_as user
    dwp_api_response 'Yes'
    create(:application_full_remission_ev)
    create_list(:application_part_remission, 9)
  end

  scenario 'Processing income based application from online application' do
    visit  home_index_url

    fill_in 'online_search[reference]', with: online_application_1.reference
    click_button 'Look up'

    fill_in :online_application_fee, with: '200', wait: true
    choose Jurisdiction.first.display_full.to_s
    choose "Other"
    fill_in :online_application_day_date_received, with: Date.current.day
    fill_in :online_application_month_date_received, with: Date.current.month
    fill_in :online_application_year_date_received, with: Date.current.year
    fill_in :online_application_form_name, with: 'E45'
    click_button 'Next'
    expect(page).to have_text 'Check details'
    click_button 'Complete processing'

    expect(page).to have_text 'Evidence of income needs to be checked'
    click_link 'Back to start'

    click_link 'Waiting for evidence'
    reference = Application.last.reference
    within(:xpath, './/table[@class="govuk-table waiting-for-evidence"]') do
      click_link reference
    end

    # because it's 10th so random evidence check
    expect(page).to have_text("#{reference} - Waiting for evidence")

    click_link 'Start now'
    choose 'No, there is a problem with the evidence and it needs to be returned'
    click_button 'Next'
    check 'Requested sources not provided'
    click_button 'Next'
    click_button 'Complete processing'
    click_link "Back to start"

    click_link 'Waiting for part-payment'
    expect(page).to have_text('There are no applications waiting for part-payment')
    online_application_2

    visit home_index_url

    fill_in 'online_search[reference]', with: online_application_2.reference
    click_button 'Look up'

    choose Jurisdiction.first.display_full.to_s
    click_button 'Next'
    click_button 'Complete processing'
    # because there is a flag from previous check
    expect(page).to have_text 'Evidence of income needs to be checked'
    click_link 'Back to start'

    click_link 'Waiting for evidence'
    within(:xpath, './/table[@class="govuk-table waiting-for-evidence"]') do
      click_link Application.last.reference
    end
    click_link 'Start now'
    choose 'Yes, the evidence is for the correct applicant and covers the correct time period'
    click_button 'Next'

    fill_in 'evidence_income', with: '1359'
    click_button 'Next'

    expect(page).to have_text('The applicant must pay £90 towards the fee')
  end
end
