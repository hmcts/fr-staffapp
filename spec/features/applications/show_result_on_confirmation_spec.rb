# coding: utf-8

require 'rails_helper'

RSpec.feature 'The result is shown on the confirmation page', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:dob) { Time.zone.today - 25.years }
  let(:date_received) { Time.zone.today - 20.days }

  after { Capybara.use_default_driver }

  context 'when the application', js: true do
    before do
      Capybara.current_driver = :webkit
      dwp_api_response 'Yes'

      login_as user

      start_new_application

      fill_in 'application_last_name', with: 'Smith'
      fill_in 'application_day_date_of_birth', with: dob.day
      fill_in 'application_month_date_of_birth', with: dob.month
      fill_in 'application_year_date_of_birth', with: dob.year

      fill_in 'application_ni_number', with: 'AB123456A'
      choose 'application_married_false'
      click_button 'Next'
    end

    context 'exceeds the savings threshold' do
      before do
        application_details_step
        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the benefit data' do
        expect(page).to have_xpath('//h1', text: 'Check details')
        expect(page).to have_xpath('//h2', text: 'Savings and investments')
        expect(page).to have_no_xpath('//h2', text: 'Income')
        expect(page).to have_no_xpath('//h2', text: 'Benefits')
      end
    end

    context 'applicant is under 15' do
      let(:dob) { Time.zone.today - 14.years }
      before do
        fill_in :application_litigation_friend_details, with: 'As one friend to another'
        click_button 'Next'
        application_details_step
        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the litigation friend details' do
        expect(page).to have_content('Litigation friend details')
        expect(page).to have_content('As one friend to another')
      end
    end

    context 'has wrong DOB' do
      before do
        application_details_step
        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the benefit data' do
        expect(page).to have_xpath('//h1', text: 'Check details')
        dob_text = dob.strftime('%-d %B %Y')
        expect(page).to have_content("Date of birth #{dob_text}")

        first(:xpath, ".//a[@data-section-name='personal-details']").click

        expect(page).to have_xpath(".//input[@id='application_day_date_of_birth'][@value='#{dob.day}']")
        expect(page).to have_xpath(".//input[@id='application_month_date_of_birth'][@value='#{dob.month}']")
        expect(page).to have_xpath(".//input[@id='application_year_date_of_birth'][@value='#{dob.year}']")

        fill_in 'application_day_date_of_birth', with: '22'
        fill_in 'application_month_date_of_birth', with: '7'
        fill_in 'application_year_date_of_birth', with: '1995'
        click_button 'Next'
        click_button 'Next'
        click_button 'Next'
        expect(page).to have_content('Date of birth 22 July 1995')
      end
    end

    context 'has wrong application received date' do
      let(:new_date_received) { date_received - 1.month }
      before do
        application_details_step
        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the benefit data' do
        date_received_text = date_received.strftime('%-d %B %Y')
        expect(page).to have_xpath('//h1', text: 'Check details')
        expect(page).to have_content("Date received #{date_received_text}")
        first(:xpath, ".//a[@data-section-name='application-details']").click

        expect(page).to have_xpath(".//input[@id='application_day_date_received'][@value='#{date_received.day}']")
        expect(page).to have_xpath(".//input[@id='application_month_date_received'][@value='#{date_received.month}']")
        expect(page).to have_xpath(".//input[@id='application_year_date_received'][@value='#{date_received.year}']")

        fill_in 'application_day_date_received', with: new_date_received.day
        fill_in 'application_month_date_received', with: new_date_received.month
        fill_in 'application_year_date_received', with: new_date_received.year

        click_button 'Next'
        click_button 'Next'

        date_received_text = new_date_received.strftime('%-d %B %Y')
        expect(page).to have_content("Date received #{date_received_text}")
      end
    end

    context 'Updating date of death' do
      let(:deceased_date) { 3.months.ago }
      let(:new_deceased_date) { 3.months.ago + 11.days }

      before do
        expect(page).to have_xpath('//h1', text: 'Application details')
        fill_in 'application_fee', with: '300'
        find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
        fill_in 'application_day_date_received', with: date_received.day
        fill_in 'application_month_date_received', with: date_received.month
        fill_in 'application_year_date_received', with: date_received.year
        fill_in 'Form number', with: 'ABC123'

        check('application_probate')
        fill_in 'application_deceased_name', with: 'Jane'
        fill_in 'application_day_date_of_death', with: deceased_date.day
        fill_in 'application_month_date_of_death', with: deceased_date.month
        fill_in 'application_year_date_of_death', with: deceased_date.year
        click_button 'Next'

        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the benefit data' do
        deceased_date_text = deceased_date.strftime('%-d %B %Y')
        expect(page).to have_xpath('//h1', text: 'Check details')
        expect(page).to have_content("Name of the deceased Jane")
        expect(page).to have_content("Date of their death #{deceased_date_text}")

        first(:xpath, ".//a[@data-section-name='application-details']").click

        expect(page).to have_xpath(".//input[@id='application_day_date_of_death'][@value='#{deceased_date.day}']")
        expect(page).to have_xpath(".//input[@id='application_month_date_of_death'][@value='#{deceased_date.month}']")
        expect(page).to have_xpath(".//input[@id='application_year_date_of_death'][@value='#{deceased_date.year}']")

        fill_in 'application_day_date_of_death', with: new_deceased_date.day
        fill_in 'application_month_date_of_death', with: new_deceased_date.month
        fill_in 'application_year_date_of_death', with: new_deceased_date.year

        click_button 'Next'
        click_button 'Next'

        new_deceased_date_text = new_deceased_date.strftime('%-d %B %Y')
        expect(page).to have_content("Date of their death #{new_deceased_date_text}")
      end
    end

    context 'Updating refund date' do
      let(:refund_date) { 3.months.ago }
      let(:new_refund_date) { 3.months.ago + 11.days }

      before do
        expect(page).to have_xpath('//h1', text: 'Application details')
        fill_in 'application_fee', with: '300'
        find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
        fill_in 'application_day_date_received', with: date_received.day
        fill_in 'application_month_date_received', with: date_received.month
        fill_in 'application_year_date_received', with: date_received.year
        fill_in 'Form number', with: 'ABC123'

        check('application_refund')
        fill_in 'application_day_date_fee_paid', with: refund_date.day
        fill_in 'application_month_date_fee_paid', with: refund_date.month
        fill_in 'application_year_date_fee_paid', with: refund_date.year
        click_button 'Next'

        choose :application_min_threshold_exceeded_true
        fill_in :application_amount, with: 3500
        click_button 'Next'
      end

      scenario 'the summary page shows the benefit data' do
        refund_date_text = refund_date.strftime('%-d %B %Y')
        expect(page).to have_xpath('//h1', text: 'Check details')
        expect(page).to have_content("Date fee paid #{refund_date_text}")

        first(:xpath, ".//a[@data-section-name='application-details']").click

        expect(page).to have_xpath(".//input[@id='application_day_date_fee_paid'][@value='#{refund_date.day}']")
        expect(page).to have_xpath(".//input[@id='application_month_date_fee_paid'][@value='#{refund_date.month}']")
        expect(page).to have_xpath(".//input[@id='application_year_date_fee_paid'][@value='#{refund_date.year}']")

        fill_in 'application_day_date_fee_paid', with: new_refund_date.day
        fill_in 'application_month_date_fee_paid', with: new_refund_date.month
        fill_in 'application_year_date_fee_paid', with: new_refund_date.year

        click_button 'Next'
        click_button 'Next'

        new_refund_date_text = new_refund_date.strftime('%-d %B %Y')
        expect(page).to have_content("Date fee paid #{new_refund_date_text}")
      end
    end

    context 'does not exceed the savings threshold' do
      before do
        application_details_step
        choose 'application_min_threshold_exceeded_false'
        click_button 'Next'
      end

      context 'is benefit based' do
        before do
          choose 'application_benefits_true'
          click_button 'Next'
        end

        scenario 'the summary page shows the benefit data' do
          expect(page).to have_xpath('//h1', text: 'Check details')
          expect(page).to have_xpath('//h2', text: 'Savings and investments')
          expect(page).to have_xpath('//h2', text: 'Benefits')
          expect(page).to have_no_xpath('//h2', text: 'Income')

          expect(page).to have_no_xpath('//div[contains(@class,"callout")]')
        end

        context 'when the "Complete processing" button is pushed' do
          before { click_button 'Complete processing' }

          context 'the confirmation page' do
            scenario 'shows the correct outcomes' do
              expect(page).to have_content 'Savings and investments ✓ Passed'
              expect(page).to have_content 'Benefits ✓ Passed'
            end

            scenario 'shows the status banner' do
              expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "full")]/h2[@class="govuk-heading-l"]', text: 'Eligible for help with fees')
            end
          end
        end
      end

      context 'is income based' do
        before do
          choose 'application_benefits_false'
          click_button 'Next'
          choose 'application_dependents_true'
          fill_in 'application_children', with: '3'
          fill_in 'application_income', with: '1200'
          click_button 'Next'
        end

        scenario 'the summary page shows the income data' do
          expect(page).to have_xpath('//h1', text: 'Check details')
          expect(page).to have_xpath('//h2', text: 'Savings and investments')
          expect(page).to have_xpath('//h2', text: 'Benefits')
          expect(page).to have_xpath('//h2', text: 'Income')

          expect(page).to have_no_xpath('//div[contains(@class,"callout")]')
        end

        context 'when the "Complete processing" button is pushed' do
          before { click_button 'Complete processing' }

          context 'the confirmation page' do
            scenario 'shows the correct outcomes' do
              expect(page).to have_content 'Savings and investments ✓ Passed'
              expect(page).to have_content 'Income ✓ Passed'
            end

            scenario 'shows the status banner' do
              expect(page).to have_xpath('//div[contains(@class,"callout")][contains(@class, "full")]/h2[@class="govuk-heading-l"]', text: 'Eligible for help with fees')
            end
          end
        end
      end
    end
  end

  # rubocop:disable Metrics/AbcSize
  def application_details_step
    expect(page).to have_xpath('//h1', text: 'Application details')
    fill_in 'application_fee', with: '300'
    find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
    fill_in 'application_day_date_received', with: date_received.day
    fill_in 'application_month_date_received', with: date_received.month
    fill_in 'application_year_date_received', with: date_received.year
    fill_in 'Form number', with: 'ABC123'
    click_button 'Next'
  end
  # rubocop:enable Metrics/AbcSize
end
