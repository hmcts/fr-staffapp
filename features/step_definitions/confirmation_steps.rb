And("I have processed an application") do
  confirmation_page.go_to_confirmation_page
end

Given("I am on the confirmation page") do
  expect(current_path).to include 'confirmation'
  expect(confirmation_page.content).to have_eligible
end

When("I click on back to start") do
  click_on 'Back to start'
end

Then("I should be taken back to my dashboard") do
  expect(current_path).to eq '/'
end

Then("I should see my processed application in your last applications") do
  expect(dashboard_page.content).to have_processed_applications
  expect(dashboard_page.content).to have_last_application
end

Then("I should see that the applicant is eligible for help with fees") do
  expect(confirmation_page.content).to have_eligible
end

Then("I should see a help with fees reference number") do
  expect(confirmation_page.content).to have_reference_number_is
  reference_number = "#{reference_prefix}-000001"
  expect(confirmation_page.content.reference_number.text).to eql(reference_number)
end

Then("I should see the next steps") do
  expect(confirmation_page.content).to have_next_steps_steps
  expect(confirmation_page.content).to have_write_ref
  expect(confirmation_page.content).to have_copy_ref
  expect(confirmation_page.content).to have_can_be_issued
end

When("I can view the guides in a new window") do
  new_window = window_opened_by { click_link 'See the guides' }
  within_window new_window do
    expect(guide_page).to be_displayed
    expect(guide_page.content).to have_guide_header
  end
end
