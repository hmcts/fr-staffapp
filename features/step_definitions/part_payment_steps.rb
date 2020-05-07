Given("I am on a processed application that rquires a part payment") do
  sign_in_page.load_page
  sign_in_page.user_account
  part_payment_application
  click_link "#{reference_prefix}-000001"
end

And("the payment is ready to process") do
  click_link 'Start now'
  part_payment_page.ready_to_process_payment
end

And("the payment is not ready to process") do
  click_link 'Start now'
  part_payment_page.not_ready_to_process_payment
end

And("I open the processed part payment application") do
  click_link "#{reference_prefix}-000001"
end

Then("I can see that the applicant has paid £40 towards the fee") do
  expect(processed_applications_page.content.result.text).to eq 'The applicant has paid £40 towards the fee'
end

Then("I should see my reason on the part payments summary page") do
  expect(summary_page.content.summary_section[0].list_row[1].text).to eq 'Part payment No Change Part payment'
  expect(summary_page.content.summary_section[0].list_row[2].text).to eq 'Reason No signature on cheque Change Reason'
end

Then("I can see that the applicant needs to make a new application") do
  expect(processed_applications_page.content.result.text).to eq 'The applicant will need to make a new application'
end

Then("processing is complete I should see a letter template") do
  click_on 'Complete processing'
  expect(part_payment_page.content).to have_evidence_confirmation_letter
  click_on 'Back to start'
  expect(current_url).to end_with '/'
end
