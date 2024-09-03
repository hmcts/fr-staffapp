Given("I process a paper application with high income") do
  start_application
  expect(dashboard_page.content).to have_find_an_application_heading
  dashboard_page.process_application
  expect(personal_details_page.content).to have_header
  personal_details_page.submit_required_personal_details
  expect(application_details_page.content).to have_header
  application_details_page.submit_fee_100
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than
  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_no
  expect(incomes_page.content).to have_header
  incomes_page.submit_incomes_no
end

When("I enter input as £{int}") do |int|
  incomes_page.submit_incomes(int)
  expect(summary_page.content).to have_header
  complete_processing
end

Then("the rejection letter should state {string}") do |string|
  expect(page).to have_text(string)
end

Given("I have an online application with high income") do
  FactoryBot.create(:online_application, :with_reference, :income_6065, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

When("I process that application") do
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

Given("I have an online application with children") do
  FactoryBot.create(:online_application, :with_reference, :childandincome6065)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

Given("I have an online application with big savings") do
  FactoryBot.create(:online_application, :with_reference, :big_saving)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end

Given("I have an online application with medium savings") do
  FactoryBot.create(:online_application, :with_reference, :threshold_exceeded, :completed)
  sign_in_page.load_page
  sign_in_page.user_account
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  dashboard_page.click_look_up
end
