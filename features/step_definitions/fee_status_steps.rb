Given('UCD changes are active') do
  enable_feature_switch('band_calculation')
end

Given('new legislation applies') do
  # temporary solution to new UCD work
  update_legislation_value
end

Given('I started to process paper application') do
  start_application
  click_on 'Start now', visible: false
end

Given('I am on the fee status page') do
  expect(fee_status_page.content).to have_header
end

Then('I should see that I must fill in date received') do
  expect(fee_status_page.content).to have_application_date_received_error
end

Then('I should have to enter refund information') do
  expect(fee_status_page.content).to have_application_refund_error
end

When('I fill in date received') do
  fee_status_page.fill_in_date_received
end

When('I will in refund with range outside of the scope') do
  fee_status_page.content.find_by_id('application_refund_true', visible: false).click
  fee_status_page.fill_in_date_payed(8.months)
  fee_status_page.click_next
end

Then('I should see error about the refund date') do
  expect(fee_status_page.content).to have_application_refund_scope_error
end

When('I fill in discretion') do
  fee_status_page.content.find_by_id('application_discretion_applied_true', visible: false).click
  fee_status_page.fill_in_discretion_manager
  fee_status_page.click_next
end

Then('I should be on personal page') do
  expect(personal_details_page.content).to have_header
end

When('I will in refund within range') do
  fee_status_page.content.find_by_id('application_refund_true', visible: false).click
  fee_status_page.fill_in_date_payed(3.months)
  fee_status_page.click_next
end

Then('I should not see fields from fee status page') do
  expect(application_details_page.content).should_not have_text "Date application received"
  expect(application_details_page.content).should_not have_text "This is a refund case"
end

When('I successfully submit my required application details post UCD') do
  application_details_page.fill_in('How much is the court or tribunal fee?', with: '6000')
  application_details_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  application_details_page.content.form_input.set 'C100'
  application_details_page.fill_in('Case number', with: 'E71YX571')
  application_details_page.click_next
end

Then('I should see a fee status section') do
  expect(summary_page.content).to have_text "Date received and fee status"
  expect(summary_page.content).to have_text "Date received and fee status"
end

When('I click on change date received link') do
  summary_page.content.summary_section[0].change_date_received.click
end

Then('I should be one the declaration page') do
  expect(declaration_page.content).to have_header
end

When('I choose applicant and submit') do
  declaration_page.sign_by_applicant
end

Then('I should be taken to the children page') do
  expect(children_page.content).to have_header
end

When('I choose no chilren') do
  children_page.no_children
end

Then('I submit the last month income') do
  incomes_page.submit_incomes_1200_ucd
end

Then('I should be taken to the incomes type page') do
  expect(income_kind_applicant_page.content).to have_header
end

When('I choose wages') do
  expect(income_kind_applicant_page.content.checkboxes[0].text).to eq('Wages before tax and National Insurance are taken off')
  income_kind_applicant_page.content.checkboxes[0].click
  income_kind_applicant_page.content.next.click
end
