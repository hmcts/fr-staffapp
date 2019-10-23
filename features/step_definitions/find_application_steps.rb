When("I search for an application using a valid hwf reference") do
  expect(find_application_page.content).to have_search_header
  find_application_page.search_by_hwf_reference
end

Then("I see that application under search results") do
  expect(find_application_page.content).to have_search_results_header
  expect(find_application_page.content.search_results_group.found_application.text).to have_content 'PA19-000001'
end

Then("I should see the result for that full name") do
  expect(find_application_page.content).to have_search_results_header
  expect(find_application_page.content.search_results_group.found_application.text).to have_content 'John Christopher Smith'
end

When("I search for an application using a last name") do
  find_application_page.search_by_last_name
end

When("I search for an application using a full name") do
  find_application_page.search_by_full_name
end

When("there is a single result for that full name") do
  expect(find_application_page.content).to have_search_results_header
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'John Christopher Smith'
end

Then("I should see a list of the results for that last name") do
  expect(find_application_page.content).to have_search_results_header
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'Smith'
  expect(result[1].text).to include 'Smith'
end

And("that there is one result for my office") do
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'PA19'
  expect(result[1].text).to eq '1 result'
end

And("that there are two results for my office") do
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'PA19'
  expect(result[1].text).to include 'PA19'
  expect(result[2].text).to eq '2 results'
end

When("I search for an application using a case number") do
  find_application_page.search_case_number('E71YX571')
end

Then("I should see there is a single result for that case number") do
  expect(find_application_page.content).to have_search_results_header
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[0].text).to have_content 'E71YX571'
end

When("I search for an application using a national insurance number") do
  find_application_page.search_ni_number
end

Then("I should see there is a single result for that national insurance number") do
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[0].text).to include 'John Christopher Smith'
end

Then("the national insurance number is not displayed in the list of results") do
  expect(find_application_page.content.search_results_group).to have_no_content('JR054008D')
end

When("my search is invalid") do
  find_application_page.search_invalid_reference
end

Then("I should see reference number is not recognised error message") do
  expect(find_application_page.content).to have_no_search_results_header
  expect(find_application_page.content).to have_no_results_found_error
end

When("I search leaving the input box blank") do
  find_application_page.content.search_button.click
end

Then("I get the cannot be blank error message") do
  expect(find_application_page.content).to have_no_search_results_header
  expect(find_application_page.content).to have_cant_be_blank_error
end

Given("I have more than 20 search results") do
  find_application_page.paginated_search_results
end

Then("I see that it is paginated by 20 results per page") do
  result = find_application_page.content.search_results_group.found_application.result
  expect(result[25].text).to include '123…1516'
end

And("I can navigate forward a page") do
  find_application_page.pagination_next_page
  expect(find_application_page.content).to have_previous_page
end

And("I can navigate back a page") do
  find_application_page.pagination_previous_page
  expect(find_application_page.content).to have_no_previous_page
end

Given("I have a list of search results") do
  start_application
  multiple_applications
  find_application_page.search_by_last_name
end

Then("I can sort by reference") do
  expect(find_application_page.content.search_results_group.sort_reference['href']).to include 'sort_by=reference&sort_to=asc'
  find_application_page.sort_by_reference
  expect(find_application_page.content.search_results_group.sort_reference['href']).to include 'sort_by=reference&sort_to=desc'
end

And("I can sort by entered") do
  expect(find_application_page.content.search_results_group.sort_entered['href']).to include '&sort_by=entered&sort_to=asc'
  find_application_page.sort_by_entered
  expect(find_application_page.content.search_results_group.sort_entered['href']).to include '&sort_by=entered&sort_to=desc'
end

Then("I can sort by first name") do
  expect(find_application_page.content.search_results_group.sort_first_name['href']).to include '&sort_by=first_name&sort_to=asc'
  find_application_page.sort_by_first_name
  expect(find_application_page.content.search_results_group.sort_first_name['href']).to include '&sort_by=first_name&sort_to=desc'
end

Then("I can sort by last name") do
  expect(find_application_page.content.search_results_group.sort_last_name['href']).to include '&sort_by=last_name&sort_to=asc'
  find_application_page.sort_by_last_name
  expect(find_application_page.content.search_results_group.sort_last_name['href']).to include '&sort_by=last_name&sort_to=desc'
end

Then("I can sort by case number") do
  expect(find_application_page.content.search_results_group.sort_case_number['href']).to include '&sort_by=case_number&sort_to=asc'
  find_application_page.sort_by_case_number
  expect(find_application_page.content.search_results_group.sort_case_number['href']).to include '&sort_by=case_number&sort_to=desc'
end

Then("I can sort by fee") do
  expect(find_application_page.content.search_results_group.sort_fee['href']).to include '&sort_by=fee&sort_to=asc'
  find_application_page.sort_by_fee
  expect(find_application_page.content.search_results_group.sort_fee['href']).to include '&sort_by=fee&sort_to=desc'
end

Then("I can sort by remission") do
  expect(find_application_page.content.search_results_group.sort_remission['href']).to include '&sort_by=remission&sort_to=asc'
  find_application_page.sort_by_remission
  expect(find_application_page.content.search_results_group.sort_remission['href']).to include '&sort_by=remission&sort_to=desc'
end

Then("I can sort by completed") do
  expect(find_application_page.content.search_results_group.sort_completed['href']).to include '&sort_by=completed&sort_to=asc'
  find_application_page.sort_by_completed
  expect(find_application_page.content.search_results_group.sort_completed['href']).to include '&sort_by=completed&sort_to=desc'
end

Given("a user has processed an application") do
  start_application
  eligable_application
  navigation_page.sign_out
end

Given("I am signed in as a user from a different office") do
  sign_in_page.user_account
end

When("I search for the application processed by the different office") do
  find_application_page.search_by_hwf_reference
end

Then("I am told that the application has been processed by another office") do
  find_application_page.content.processed_by_another_office
end

Then("I am not able to view that application") do
  expect(find_application_page.content).to have_no_search_results_header
  expect(find_application_page.content).to have_no_search_results_group
end
