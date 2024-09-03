Given("I have looked up an online application") do
  FactoryBot.create(:online_application, :with_reference)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

When('I fill in missing online application details') do
  fill_in('How much is the court or tribunal fee?', with: ' 450.0')
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.content.jurisdiction.click
  process_online_application_page.fill_in_date_application_received
end

When("I see the application details") do
  expect(application_details_digital_page).to be_displayed
  expect(process_online_application_page.content).to have_application_details_header
  expect(process_online_application_page).to have_text 'Peter Smith'

  expect(process_online_application_page).to have_text 'Date submitted by applicant'
  expect(process_online_application_page).to have_text OnlineApplication.last.created_at.strftime("%d %b %Y")
end

And("I click next without selecting a jurisdiction") do
  process_online_application_page.click_next
end

Then("I should see that I must select a jurisdiction error message") do
  expect(process_online_application_page.content).to have_error
end

Then("I add a jurisdiction") do
  process_online_application_page.content.jurisdiction.click
end

Then('I click next') do
  process_online_application_page.click_next
end

Then("I should be taken to the check details page") do
  expect(process_online_application_page.content).to have_check_details_header
end

When("I process the online application") do
  expect(process_online_application_page.content).to have_application_details_header
  fill_in('How much is the court or tribunal fee?', with: '450.0')
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.content.jurisdiction.click
  process_online_application_page.fill_in_date_application_received
  stub_dwp_response_as_not_eligible_request
  process_online_application_page.click_next
  benefit_checker_page.content.no.click
  benefit_checker_page.click_next
  expect(process_online_application_page.content).to have_check_details_header
  complete_processing
end

When("I processed the applications until benefit paper evidence page") do
  expect(process_online_application_page.content).to have_application_details_header
  fill_in('How much is the court or tribunal fee?', with: '450.0')
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.content.jurisdiction.click
  process_online_application_page.fill_in_date_application_received
  stub_dwp_response_as_dwp_down_request
  process_online_application_page.click_next
end

Then("I see the applicant is not eligible for help with fees") do
  expect(process_online_application_page.content).to have_not_eligible_header
  expect(process_online_application_page.content.summary_row[0]).to have_text 'Savings and investments ✓ Passed'
  expect(process_online_application_page.content.summary_row[1]).to have_text 'Benefits ✗ Failed'
end

And("back to start takes me to the homepage") do
  process_online_application_page.content.back_to_start_button.click
  expect(dashboard_page.content).to have_find_an_application_heading
end

And("I can see my processed application") do
  expect(process_online_application_page.content.last_application[1].text).to have_content 'processed Peter Smith'
end

Then("I should see digital before you start advice") do
  expect(application_details_digital_page.content.guidance.guidance_header[0].text).to eq 'Before you start'
end

Then("I see that I should see digital check that the applicant is not") do
  expect(application_details_digital_page.content.guidance.guidance_sub_heading[0].text).to eq 'In all cases, check the applicant is not:'
  expect(application_details_digital_page.content.guidance.guidance_list[0].text).to have_text 'receiving legal aid a vexatious litigant, or bound by an order a company, charity or not for profit organisation'
  expect(application_details_digital_page.content.guidance.guidance_text[0].text).to eq 'What to do if the applicant is one of these'
  expect(application_details_digital_page.content.guidance.guidance_link[0]['href']).to end_with '/guide/process_application#check-applicant-is-not'
end

Then("I see digital check the fee") do
  expect(application_details_digital_page.content.guidance.guidance_sub_heading[1].text).to eq 'Check the fee:'
  expect(application_details_digital_page.content.guidance.guidance_list[1].text).to have_text 'was not processed through the money claim online (MCOL)'
  expect(application_details_digital_page.content.guidance.guidance_text[1].text).to eq 'What to do if the fee is one of these'
  expect(application_details_digital_page.content.guidance.guidance_link[1]['href']).to eq 'https://intranet.justice.gov.uk/documents/2023/11/processing-a-help-with-fees-application-post-27th-november-23.docx'

end

Then("I see Remember for the case details") do
  expect(application_details_digital_page.content.guidance.guidance_sub_heading[2].text).to eq 'Remember:'
  expect(application_details_digital_page.content.guidance.guidance_list[2].text).to have_text 'to enter the correct name of form the application relates to to tick the appropriate box under ‘case details’ if the application is for a refund, emergency or probate case. You will also need to enter the appropriate date for refund and probate cases when prompted'
end

Then("I see digital Emergency advice") do
  expect(application_details_digital_page.content.guidance.guidance_header[1].text).to eq 'Emergency cases'
  expect(application_details_digital_page.content.guidance.guidance_text[2].text).to eq 'An emergency case is one where delay risks harm to the applicant or to the applicant’s case.'
end

Then("I see digital examples of emergency cases") do
  expect(application_details_digital_page.content.guidance.guidance_sub_heading[3].text).to eq 'Example of emergency cases:'
  expect(application_details_digital_page.content.guidance.guidance_list[3].text).to have_text 'suspending an eviction debtor insolvency petition children or vulnerable adults domestic violence injunctions ‘out of hours’ provisions at the Royal Courts of Justice'
  expect(application_details_digital_page.content.guidance.guidance_text[3].text).to eq 'What to do if the application can’t be processed before the emergency application is heard'
  expect(application_details_digital_page.content.guidance.guidance_link[2]['href']).to eq 'https://intranet.justice.gov.uk/documents/2023/11/processing-a-help-with-fees-application-post-27th-november-23.docx'
end

When("I click emergency checkbox") do
  application_details_digital_page.content.emergency_case.click
end

When("I click next without entering a reason") do
  process_online_application_page.click_next
end

Then("I should see a must enter an emergency reason error message") do
  expect(application_details_digital_page.content).to have_emergency_case_error
end

When("I click next after entering a reason") do
  application_details_digital_page.content.emergency_case_textbox.set 'emergency reason'
  process_online_application_page.click_next
end

When('Benefit Check is ok') do
  stub_dwp_response_as_ok_request
end
