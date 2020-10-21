When("I click on waiting for evidence") do
  expect(dashboard_page.content).to have_in_progress_header
  dashboard_page.content.waiting_for_evidence.click
end

Then("I should be taken to evidence checks page") do
  expect(page).to have_current_path(%r{/evidence_checks})
end

When("I click on waiting for part-payment") do
  expect(dashboard_page.content).to have_in_progress_header
  click_link('Waiting for part-payments')
end

Then("I should be taken to part payments page") do
  expect(page).to have_current_path(%r{/part_payments})
end

When("I click on view profile") do
  click_link 'View profile', visible: false
end

Then("I am taken to my details") do
  expect(profile_page).to be_displayed
  expect(profile_page).to have_current_path(%r{/users/[0-9]+})
end

When("I click on staff guides") do
  click_link 'Staff Guides', visible: false
end

Then("I am taken to the guide page") do
  expect(guide_page).to be_displayed
  expect(guide_page).to have_current_path(%r{/guide})
end

When("I search for an application using valid reference number") do
  # steps need implementing - wip
  user_dashboard_page.search_valid_reference
end

When("I search for an application using invalid reference number") do
  # steps need implementing - wip
  user_dashboard_page.search_invalid_reference
end

Then("I should see the reference number is not recognised error message") do
  # steps need implementing - wip
end

When("I start to process a new paper application") do
  expect(dashboard_page).to have_current_path('/')
  dashboard_page.process_application
end

Then("I am taken to the applicants personal details page") do
  # steps need implementing - wip
end

When("I look up a valid hwf reference") do
  user_dashboard_page.look_up_valid_reference
end

When("I look up a invalid hwf reference") do
  user_dashboard_page.look_up_invalid_reference
end

When("I click on the reference number of an application that is waiting for evidence") do
  # steps need implementing - wip
end

Then("I am taken to the application waiting for evidence") do
  # steps need implementing - wip
end

When("I click on the reference number of an application that is waiting for part-payment") do
  # steps need implementing - wip
end

Then("I am taken to the application waiting for part-payment") do
  # steps need implementing - wip
end

When("I click on the reference number of one of my last applications") do
  # steps need implementing - wip
end

Then("I am taken to that application") do
  # steps need implementing - wip
end

When("I click on deleted applications") do
  # steps need implementing - wip
end

Then("I am taken to all deleted applicantions") do
  # steps need implementing - wip
end
