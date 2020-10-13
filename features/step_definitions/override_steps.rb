Given("I have completed an ineligible paper application") do
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
  expect(personal_details_page).to have_current_path(%r{personal_informations})
  personal_details_page.submit_all_personal_details_ni
  expect(application_details_page).to have_current_path(%r{details})
  application_details_page.submit_fee_100
  expect(savings_investments_page).to have_current_path(%r{savings_investments})
  savings_investments_page.submit_more_than
  savings_investments_page.submit_exact_amount
  expect(summary_page).to have_current_path(%r{/summary})
  complete_processing
  expect(confirmation_page.content).to have_ineligible
end

When("I click on Grant help with fees") do
  confirmation_page.content.wait_until_grant_hwf_visible
  confirmation_page.content.grant_hwf.click
end

When("Click Update application without selecting an option") do
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

Then("I should see an error telling me to select an option") do
  expect(confirmation_page).to have_content(%r{Please select a reason for granting help with fees})
end

Then("I should see an error telling me to enter a reason for granting help with fees") do
  expect(confirmation_page).to have_content(%r{Please enter a reason for granting help with fees})
end

When("I check the Other option") do
  confirmation_page.content.override.wait_until_other_option_visible
  confirmation_page.content.override.other_option.click
end

When("Click Update application without providing detail") do
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

When("Click Update application after providing detail") do
  confirmation_page.content.override.wait_until_other_reason_textbox_visible
  confirmation_page.content.override.other_reason_textbox.set 'Reason'
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

Then("The application should remain ineligible") do
  expect(confirmation_page.content).to have_ineligible
end

Then("The application should become eligible") do
  expect(confirmation_page.content).to have_granted_hwf
end

When("Click Update application") do
  confirmation_page.content.override.wait_until_update_application_button_visible
  confirmation_page.content.override.update_application_button.click
end

Then("I should see a message telling me the application passed by manager's decision") do
  expect(confirmation_page.content).to have_passed_by_manager
end

When("I check the Paper evidence option") do
  confirmation_page.content.override.wait_until_paper_evidence_option_visible
  confirmation_page.content.override.paper_evidence_option.click
end

Then("I should not see a message telling me the application passed by manager's decision") do
  expect(confirmation_page.content).not_to have_passed_by_manager
end

