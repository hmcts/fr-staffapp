Given("I have started an application") do
  start_application
end

And("I am on the personal details part of the application") do
  expect(current_path).to include 'personal_informations'
  expect(personal_details_page.content).to have_header
end

When("I successfully submit my required personal details") do
  expect(personal_details_page.content).to have_dob_legend
  expect(personal_details_page.content).to have_dob_hint
  expect(personal_details_page.content).to have_ni_label
  expect(personal_details_page.content).to have_ni_hint
  expect(personal_details_page.content).to have_ho_label
  expect(personal_details_page.content).to have_ho_hint
  expect(personal_details_page.content).to have_martial_status_legend
  personal_details_page.submit_all_personal_details
end

Then("I should be taken to the application details page") do
  expect(current_path).to include 'details'
  expect(application_details_page.content).to have_header
end

When("I submit a date that makes the applicant born in the future") do
  personal_details_page.in_the_future_dob
  next_page
end

Then("I should see that the applicant cannot be under 16 years old error message") do
  expect(personal_details_page.content).to have_dob_in_the_future_error
end

Then("I should see the invalid date of birth error message") do
  expect(personal_details_page.content).to have_invalid_date_of_birth_error
end

When("I leave the date of birth blank") do
  next_page
end

When("I click on next without answering any questions") do
  next_page
end

Then("I should see that I must fill in my last name") do
  expect(personal_details_page.content).to have_last_name_error
end

Then("I should have to enter my date of birth") do
  expect(personal_details_page.content).to have_invalid_date_of_birth_error
end

Then("I should have to enter my marital status") do
  expect(personal_details_page.content).to have_martial_status_error
end

When("I fill in the form with a last name with one letter") do
  fill_in 'Last name', with: 'S'
  next_page
end

Then("I should see error message last name is too short") do
  expect(personal_details_page.content).to have_last_name_too_short_error
end

Then("I should see before you start advice") do
  expect(personal_details_page.content.guidance.guidance_header[0].text).to eq 'Before you start'
  expect(personal_details_page.content.guidance.guidance_text[0].text).to eq 'Check the statement of truth has been signed.'
end

Then("I see that I should check that the applicant is not") do
  expect(personal_details_page.content.guidance.guidance_sub_heading[0].text).to eq 'Check the applicant is not:'
  expect(personal_details_page.content.guidance.guidance_list[0].text).to eq 'receiving legal aid a vexatious litigant, or bound by an order a company, charity or not for profit organisation'
  expect(personal_details_page.content.guidance.guidance_text[1].text).to eq 'What to do if the applicant is one of these'
  expect(personal_details_page.content.guidance.guidance_link[0]['href']).to end_with '/guide/process_application#not-eligible'
end

Then("I see that I should check the fee") do
  expect(personal_details_page.content.guidance.guidance_sub_heading[1].text).to eq 'Check the fee:'
  expect(personal_details_page.content.guidance.guidance_list[1].text).to eq 'was not processed through the money claim online (MCOL) or possession claim online (PCOL) services is not for a search or request for duplicate documents (unless the applicant did not receive the originals or had no fixed address when an order was made)'
  expect(personal_details_page.content.guidance.guidance_text[2].text).to eq 'What to do if the fee is one of these'
  expect(personal_details_page.content.guidance.guidance_link[1]['href']).to end_with '/guide/process_application#not-eligible'
end

Then("I see that I should look for a national insurance number") do
  expect(personal_details_page.content.guidance.guidance_header[1].text).to eq 'National Insurance number'
  expect(personal_details_page.content.guidance.guidance_sub_heading[2].text).to eq 'If NI number isn\'t provided:'
  expect(personal_details_page.content.guidance.guidance_list[2].text).to eq "check answer to question 9 if 'No', continue to process without NI number if 'Yes', don\'t process and contact applicant by phone to ask for their NI number"
  expect(personal_details_page.content.guidance.guidance_text[3].text).to eq 'What to do if you’re unable to obtain the NI number'
  expect(personal_details_page.content.guidance.guidance_link[2]['href']).to end_with '/guide/process_application#ni-number'
end

Then("I see more information about home office numbers") do
  expect(personal_details_page.content.guidance.guidance_header[2].text).to eq 'Home Office reference number'
  expect(personal_details_page.content.guidance.guidance_text[4].text).to eq 'A Home Office reference number needs to be provided if the applicant is subject to immigration control'
  expect(personal_details_page.content.guidance.guidance_text[5].text).to eq "An applicant can find their Home Office reference number on any correspondence received from the Home Office."
end

Then("I see that I should check the status of the applicant") do
  expect(personal_details_page.content.guidance.guidance_header[3].text).to eq 'Status'
  expect(personal_details_page.content.guidance.guidance_list[2].text).to eq "check answer to question 9 if 'No', continue to process without NI number if 'Yes', don\'t process and contact applicant by phone to ask for their NI number"
  expect(personal_details_page.content.guidance.guidance_text[6].text).to eq "If the applicant is part of a couple but their case concerns their partner, eg divorce, dissolution or domestic violence, select 'Single'."
  expect(personal_details_page.content.guidance.guidance_link[3]['href']).to end_with '/guide/process_application#status'
  expect(personal_details_page.content.guidance.guidance_link[4]['href']).to end_with '/guide'
end
