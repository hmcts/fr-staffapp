require 'rails_helper'

# I'm disabling this Rubocop check to allow writing readable scenarios
# rubocop:disable RSpec/NoExpectationExample

RSpec.feature 'Staff can search for online application' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:jurisdictions) { create_list(:jurisdiction, 4) }
  let(:office) { create(:office, jurisdictions: jurisdictions) }
  let(:user) { create(:staff, office: office) }
  let(:current_time) { Time.zone.parse('10/10/2015') }

  before do
    dwp_api_response 'Yes'
    login_as user
  end

  let(:online_application) { create(:online_application, :with_reference) }

  scenario 'User fills in all required fields and the application is saved' do
    Timecop.freeze(current_time) do
      online_application
      given_user_is_editting_the_application
      when_they_fill_in_all_required_fields
      then_the_summary_page_is_displayed
    end
  end

  scenario 'User does not fill in all the required fields and the application fails to save' do
    Timecop.freeze(current_time) do
      given_user_is_editting_the_application
      when_they_do_not_fill_in_all_required_fields
      then_the_application_fails_to_save
    end
  end

  def given_user_is_editting_the_application
    visit "/online_applications/#{online_application.id}/edit"
  end

  def when_they_fill_in_all_required_fields
    fill_in :online_application_fee, with: '200', wait: true
    choose "jurisdiction_#{jurisdictions.first.id}"
    fill_in :online_application_day_date_received, with: '10'
    fill_in :online_application_month_date_received, with: '10'
    fill_in :online_application_year_date_received, with: '2015'
    choose 'Other'
    fill_in :online_application_form_name, with: 'E45'
    check :online_application_emergency
    fill_in :online_application_emergency_reason, with: 'EMERGENCY REASON'
    click_button 'Next'
  end

  def then_the_summary_page_is_displayed
    expect(page).to have_content 'Check details'
    expect(page).to have_content 'Fee£200'
    expect(page).to have_content 'Date received10 October 2015'
  end

  def when_they_do_not_fill_in_all_required_fields
    click_button 'Next'
  end

  def then_the_application_fails_to_save
    expect(page).to have_content 'Enter a court or tribunal fee'
    expect(page).to have_content 'You must select a jurisdiction'
  end
end
# rubocop:enable RSpec/NoExpectationExample
