# coding: utf-8

require 'rails_helper'

RSpec.feature 'Completing the application details', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let!(:jurisdictions) { create_list :jurisdiction, 3 }
  let!(:office) { create(:office, jurisdictions: jurisdictions) }
  let!(:user) { create(:user, jurisdiction_id: jurisdictions[1].id, office: office) }
  let(:dob) { Time.zone.today - 25.years }
  let(:date_received) { Time.zone.yesterday }

  context 'as a signed in user with default jurisdiction', js: true do
    before { login_as user }

    context 'the applicant is single and under 61' do
      context 'after completing the personal details page' do
        before do
          start_new_application

          fill_in 'application_last_name', with: 'Smith', wait: true
          fill_in 'application_day_date_of_birth', with: dob.day
          fill_in 'application_month_date_of_birth', with: dob.month
          fill_in 'application_year_date_of_birth', with: dob.year
          fill_in 'application_ni_number', with: 'AB123456A'
          choose 'application_married_false'
          click_button 'Next'
        end

        scenario 'application details is shown' do
          expect(page).to have_xpath('//h1', text: 'Application details')
        end

        context 'when the dwp says the applicant is not on benefits' do
          before { dwp_api_response 'No' }

          context 'after completing the application_details page' do
            before do
              find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
              fill_in 'application_fee', with: 300
              fill_in 'application_day_date_received', with: date_received.day
              fill_in 'application_month_date_received', with: date_received.month
              fill_in 'application_year_date_received', with: date_received.year
              fill_in 'Form number', with: 'ABC123'
              click_button 'Next'
            end

            scenario 'savings and investments is shown' do
              expect(page).to have_xpath('//h1', text: 'Savings and investments')
            end

            context 'when the applicant exceeds the savings threshold' do
              before do
                choose 'application_min_threshold_exceeded_true'
                fill_in :application_amount, with: 3500
                click_button 'Next'
              end

              scenario 'the summary page is shown with correct display' do
                expect(page).to have_xpath('//h1', text: 'Check details')
                expect(page).to have_xpath('//h2', text: 'Savings and investments')
                expect(page).to have_content('Less than £3,000No')
                expect(page).to have_content('Savings amount£3500')
                expect(page).to have_no_content('£16,000 or more')
                expect(page).to have_no_xpath('//h2', text: 'Benefits')
                expect(page).to have_no_xpath('//h2', text: 'Income')
              end
            end

            context 'when the applicant passes the savings threshold' do
              before do
                choose 'application_min_threshold_exceeded_false'
                click_button 'Next'
              end

              scenario 'benefits is shown' do
                expect(page).to have_xpath('//h1', text: 'Benefits')
              end

              context 'when the applicant says they are on benefits' do
                before do
                  choose 'application_benefits_true'
                  click_button 'Next'
                end

                scenario 'benefit override page is shown with' do
                  expect(page).to have_xpath('//h1', text: 'Benefits')
                end

                context 'when benefits confirmed' do
                  before do
                    choose 'benefit_override_evidence_false'
                    click_button 'Next'
                  end

                  scenario 'the summary page is shown with correct display' do
                    expect(page).to have_xpath('//h1', text: 'Check details')
                    expect(page).to have_xpath('//h2', text: 'Savings and investments')
                    expect(page).to have_xpath('//h2', text: 'Benefits')
                    expect(page).to have_no_xpath('//h2', text: 'Income')
                  end
                end
              end

              context 'when the applicant says they are not on benefits' do
                before do
                  choose 'application_benefits_false'
                  click_button 'Next'
                end

                scenario 'income is shown' do
                  expect(page).to have_xpath('//h1', text: 'Income')
                end

                context 'when the applicant has children' do
                  before do
                    choose 'application_dependents_true'
                  end

                  scenario 'shows children and income inputs' do
                    expect(page).to have_xpath('//input[@id="application_income"]')
                    expect(page).to have_xpath('//input[@id="application_children"]')
                  end

                  context 'after completing income page' do
                    before do
                      fill_in 'application_children', with: 2
                      fill_in 'application_income', with: 1750
                      click_button 'Next'
                    end

                    context 'on summary page' do
                      scenario 'the summary page is shown with correct display' do
                        expect(page).to have_xpath('//h1', text: 'Check details')
                        expect(page).to have_xpath('//h2', text: 'Savings and investments')
                        expect(page).to have_xpath('//h2', text: 'Benefits')
                        expect(page).to have_xpath('//h2', text: 'Income')
                      end

                      context 'when the user returns to the savings threshold' do
                        before { click_link 'ChangeLess than £3,000' }

                        scenario 'savings and investments is shown' do
                          expect(page).to have_xpath('//h1', text: 'Savings and investments')
                        end

                        context 'and changes the threshold to exceeded' do
                          before do
                            choose :application_min_threshold_exceeded_true
                            fill_in :application_amount, with: 3500
                            click_button 'Next'
                          end

                          scenario 'the summary page is shown with correct display' do
                            expect(page).to have_xpath('//h1', text: 'Check details')
                            expect(page).to have_xpath('//h2', text: 'Savings and investments')
                            expect(page).to have_no_xpath('//h2', text: 'Benefits')
                            expect(page).to have_no_xpath('//h2', text: 'Income')
                          end
                        end
                      end
                    end
                  end
                end

                context 'when the applicant does not have children' do
                  before do
                    choose 'application_dependents_false'
                  end

                  scenario 'shows income input' do
                    expect(page).to have_xpath('//input[@id="application_income"]')
                  end
                end
              end
            end
          end
        end

        context 'when the dwp says the applicant is on benefits' do
          before { dwp_api_response 'Yes' }

          context 'after completing the application_details page' do
            before do
              find(:xpath, '(//input[starts-with(@id,"application_jurisdiction_id_")])[1]').click
              fill_in 'application_fee', with: 300
              fill_in 'application_day_date_received', with: date_received.day
              fill_in 'application_month_date_received', with: date_received.month
              fill_in 'application_year_date_received', with: date_received.year
              fill_in 'Form number', with: 'ABC123'
              click_button 'Next'
            end

            scenario 'savings and investments is shown' do
              expect(page).to have_xpath('//h1', text: 'Savings and investments')
            end

            context 'when the applicant exceeds the savings threshold' do
              before do
                choose :application_min_threshold_exceeded_true
                fill_in :application_amount, with: 3500
                click_button 'Next'
              end

              scenario 'the summary page is shown with correct display' do
                expect(page).to have_xpath('//h1', text: 'Check details')
                expect(page).to have_xpath('//h2', text: 'Savings and investments')
                expect(page).to have_no_xpath('//h2', text: 'Benefits')
                expect(page).to have_no_xpath('//h2', text: 'Income')
              end
            end

            context 'when the applicant passes the savings threshold' do
              before do
                choose 'application_min_threshold_exceeded_false'
                click_button 'Next'
              end

              scenario 'benefits is shown' do
                expect(page).to have_xpath('//h1', text: 'Benefits')
              end

              context 'when the applicant says they are on benefits' do
                before do
                  choose 'application_benefits_true'
                  click_button 'Next'
                end

                scenario 'the summary page is shown with correct display' do
                  expect(page).to have_xpath('//h1', text: 'Check details')
                  expect(page).to have_xpath('//h2', text: 'Savings and investments')
                  expect(page).to have_xpath('//h2', text: 'Benefits')
                  expect(page).to have_no_xpath('//h2', text: 'Income')
                end

                context 'when the user returns to the savings threshold' do
                  before { click_link 'ChangeLess than £3,000' }

                  scenario 'savings and investments is shown' do
                    expect(page).to have_xpath('//h1', text: 'Savings and investments')
                  end

                  context 'and changes the threshold to exceeded' do
                    before do
                      choose :application_min_threshold_exceeded_true
                      fill_in :application_amount, with: 3500
                      click_button 'Next'
                    end

                    scenario 'the summary page is shown with correct display' do
                      expect(page).to have_xpath('//h1', text: 'Check details')
                      expect(page).to have_xpath('//h2', text: 'Savings and investments')
                      expect(page).to have_no_xpath('//h2', text: 'Benefits')
                      expect(page).to have_no_xpath('//h2', text: 'Income')
                    end
                  end
                end

                context 'when the user clicks continue' do
                  before { click_button 'Complete processing' }

                  scenario 'the confirmation is shown' do
                    expect(page).to have_xpath('//div[contains(@class,"callout")]/h2[@class="govuk-heading-l"]')
                  end

                  context 'when the user clicks Back to Start' do
                    before { click_link 'Back to start' }

                    scenario 'the home page is shown' do
                      expect(page).to have_text 'Process a paper application'
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
