When("I submit a refund application with no refund date") do
  application_details_page.submit_fee_600_blank_refund_date
end

Then("I should see a enter date in this format error") do
  expect(application_details_page.content).to have_application_date_error
  expect(application_details_page.content.refund_section).not_to have_delivery_manager_question
end

When("I submit a refund application where refund date is beyond 3 months from application received date") do
  application_details_page.submit_as_refund_case_date_too_late
end

Then("I should see a delivery manager discretion error") do
  expect(application_details_page.content).to have_delivery_manager_error
end

When("I submit a refund application where refund date is within 3 months of application received date") do
  application_details_page.submit_as_refund_case
end

When("I submit a refund application where refund date is after the date that the form was received") do
  application_details_page.submit_as_refund_case_future_date
end

Then("I should see an error message saying the refund date can't be later than receipt date") do
  expect(application_details_page.content.refund_section).to have_future_refund_date_error
end

When("I select Yes to Delivery Manager discretion applied?") do
  application_details_page.content.refund_section.yes_answer.click
end

When("I submit without providing Delivery Manager name or Discretion reason") do
  application_details_page.click_next
end

Then("I see two discretion related errors") do
  expect(application_details_page.content.refund_section).to have_delivery_manager_name_error
  expect(application_details_page.content.refund_section).to have_delivery_manager_reason_error
end

When("I submit after providing Delivery Manager name or Discretion reason") do
  application_details_page.choose_other_radio_button
  application_details_page.content.form_input.set 'C100'
  application_details_page.content.refund_section.delivery_manager_name_input.set 'Test Name'
  application_details_page.content.refund_section.discretion_reason_input.set 'Test Reason'
  application_details_page.click_next
end

When("I process application through to Check details page") do
  expect(savings_investments_page.content).to have_header
  savings_investments_page.submit_less_than

  expect(benefits_page.content).to have_header
  benefits_page.submit_benefits_yes

  expect(paper_evidence_page.content).to have_header
  paper_evidence_page.submit_evidence_yes

  expect(summary_page.content).to have_header
end

Then("I should see the date fee paid") do
  expect(summary_page.content.summary_section[1].text).to have_content 'Date fee paid'
end

Then("I should see Delivery Manager discretion applied Yes") do
  expect(summary_page.content.summary_section[1].text).to have_content(/Delivery Manager discretion applied Yes/)
end

Then("I should see the Delivery Manager name") do
  expect(summary_page.content.summary_section[1].text).to have_content(/Delivery Manager name Test Name/)
end

Then("I should see the Discretionary reason") do
  expect(summary_page.content.summary_section[1].text).to have_content(/Discretion reasons Test Reason/)
end

When("I select No to Delivery Manager discretion applied? and submit form") do
  application_details_page.choose_other_radio_button
  application_details_page.content.form_input.set 'C100'
  application_details_page.content.refund_section.no_answer.click
  application_details_page.click_next
end

Then("I am on the Check details page") do
  expect(summary_page).to be_displayed
end

Then("I should see Delivery Manager discretion applied No") do
  expect(summary_page.content.summary_section[1]).to have_content(/Delivery Manager discretion applied No/)
end

When("I click Change date fee paid on check details page") do
  summary_page.content.summary_section[1].list_actions[5].click_link
end

When("I change the date fee paid to a valid date and submit") do
  date_fee_paid = Time.zone.today - 4.months
  application_details_page.content.day_date_received.set date_fee_paid.day
  application_details_page.content.month_date_received.set date_fee_paid.month
  application_details_page.content.year_date_received.set date_fee_paid.year
  application_details_page.click_next
end

When("I change the date fee paid to a valid date") do
  date_fee_paid = Time.zone.today - 4.months
  application_details_page.content.day_date_received.set date_fee_paid.day
  application_details_page.content.month_date_received.set date_fee_paid.month
  application_details_page.content.year_date_received.set date_fee_paid.year
end

Then("I should not see discretion information") do
  expect(summary_page.content.summary_section[1].text).to have_no_content(/Delivery Manager name Test Name/)
  expect(summary_page.content.summary_section[1].text).to have_no_content(/Discretion reasons Test Reason/)
  expect(summary_page.content.summary_section[1].text).to have_no_content(/Delivery Manager discretion applied/)
end

Then("I see application is complete") do
  expect(confirmation_page.content).to have_application_complete
end

Then("I see Delivery Manager Discretion as Failed") do
  expect(confirmation_page.content.summary_list_row[0].text).to have_content 'Delivery Manager Discretion'
  expect(confirmation_page.content.summary_list_row[0].text).to have_content '✗ Failed'
end

When("I select Yes to Delivery Manager discretion applied? and enter name and reason") do
  application_details_page.content.refund_section.yes_answer.click
  application_details_page.content.refund_section.delivery_manager_name_input.set 'Test Name'
  application_details_page.content.refund_section.discretion_reason_input.set 'Test Reason'
  application_details_page.click_next
end

Then("I should not see Delivery Manager discretion applied? checkboxes") do
  expect(application_details_page.content.refund_section).not_to have_yes_answer
  expect(application_details_page.content.refund_section).not_to have_no_answer
  expect(application_details_page.content.refund_section).not_to have_delivery_manager_question
end
