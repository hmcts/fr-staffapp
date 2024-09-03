# coding: utf-8

require 'rails_helper'

def personal_details_page
  dob = Time.zone.today - 25.years
  fill_in 'application_first_name', with: 'John', wait: true
  fill_in 'application_last_name', with: 'Smith', wait: true
  fill_in 'application_day_date_of_birth', with: dob.day
  fill_in 'application_month_date_of_birth', with: dob.month
  fill_in 'application_year_date_of_birth', with: dob.year
  fill_in 'application_ni_number', with: 'AB123456A'
  choose 'application_married_false'
  click_button 'Next'
end

def application_details
  date_received = Time.zone.today
  fill_in 'application_fee', with: 410, wait: true
  find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
  fill_in 'application_day_date_received', with: date_received.day
  fill_in 'application_month_date_received', with: date_received.month
  fill_in 'application_year_date_received', with: date_received.year
  choose 'Other'
  fill_in 'Name of form', with: 'ABC123'
  click_button 'Next'
end

def savings_and_investments
  choose 'application_min_threshold_exceeded_false'
  click_button 'Next'
end

def benefits_page
  choose 'application_benefits_true'
  click_button 'Next'
end

RSpec.feature 'Allow override when DWP checker says "NO"' do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list(:jurisdiction, 3) }
  let!(:office)        { create(:office, jurisdictions: jurisdictions) }
  let!(:user)          { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }

  before do
    dwp_api_response 'No'
    login_as user
    start_new_application
    personal_details_page
    application_details
    savings_and_investments
    benefits_page
  end

  scenario 'they should be on the Benefit page straight away' do
    expect(page).to have_xpath('//h1', text: 'Benefits')
  end

  context 'when the user provides paper evidence' do
    before do
      choose 'benefit_override_evidence_true'
      click_button 'Next'
    end

    context 'and the evidence is correct' do
      describe 'when displaying the summary' do
        scenario 'shows the benefits result as passed' do
          expect(page).to have_content 'Check details'
          expect(page).to have_xpath('//dt[contains(@class,"govuk-summary-list__key")][text()="Correct evidence provided"]/following-sibling::*[1][text()="Yes"]')
        end
      end
    end
  end

  context 'when the user does not provide supporting evidence' do
    before do
      choose 'benefit_override_evidence_false'
      click_button 'Next'
    end

    describe 'when displaying the summary' do
      scenario 'shows the benefits result as failed' do
        expect(page).to have_content 'Check details'
        expect(page).to have_xpath('//dt[contains(@class,"govuk-summary-list__key")][text()="Correct evidence provided"]/following-sibling::*[1][text()="No"]')
      end
    end
  end

end
