Given("I create an application A that waits for evidence") do
  @user1 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, ni_number: 'AB123456D', office: @user1.office, user: @user1)
end

And("I create an Application B that has correct evidence") do
  @user2 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, ni_number: 'AB123456D', office: @user2.office, user: @user2)

  sign_in_page.load_page
  fill_in 'Email', with: @user2.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link.click
  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.correct_evidence.click
  evidence_accuracy_page.click_next
  expect(incomes_page.content).to have_header
  fill_in 'Total monthly income from evidence', with: 1000
  evidence_income_page.click_next
  evidence_result_page.click_next
  complete_processing

end

When("I create Application C") do
  click_link 'Sign out', visible: false
  @user3 = FactoryBot.create(:user)
  fill_in 'Email', with: @user3.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'

  FactoryBot.create(:online_application, :with_reference, :income1000, ni_number: 'AB123456D')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

When("I create an Application B and wrong evidence is provided") do
  @user2 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, ni_number: 'AB123456D', office: @user2.office, user: @user2)

  sign_in_page.load_page
  fill_in 'Email', with: @user2.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link.click
  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  expect(evidence_accuracy_page.content).to have_problem_with_evidence
  evidence_accuracy_page.content.problem_with_evidence.click
  evidence_accuracy_page.click_next
  expect(reason_for_rejecting_evidence_page.content).to have_header
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  reason_for_rejecting_evidence_page.click_next
  complete_processing
end

And("evidence check is skipped") do
  expect(process_online_application_page.content.summary_row[1]).to have_text 'Income ✓ Passed'
end

And("evidence check is called") do
  expect(process_online_application_page.content.summary_row[1]).to have_text 'Income Waiting for evidence'
end

And("I close application A") do
  click_link 'Sign out', visible: false
  fill_in 'Email', with: @user1.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link.click
  evidence_page.content.evidence_can_not_be_processed.click
  click_link 'Return application', visible: false
  problem_with_evidence_page.submit_not_arrived_too_late
  click_on 'Back to start'
end

Then("I create Application D") do
  click_link 'Sign out', visible: false
  sign_in_as_user
  FactoryBot.create(:online_application, :with_reference, :income1000, ni_number: 'AB123456D')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

When("Application C has correct evidence") do
  click_link 'Sign out', visible: false
  fill_in 'Email', with: @user3.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link2.click

  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.correct_evidence.click
  evidence_accuracy_page.click_next
  expect(incomes_page.content).to have_header
  fill_in 'Total monthly income from evidence', with: 1000
  evidence_income_page.click_next
  evidence_result_page.click_next
  complete_processing
end

Then("I create Application E") do
  click_link 'Sign out', visible: false
  sign_in_as_user
  FactoryBot.create(:online_application, :with_reference, :income1000, ni_number: 'AB123456D')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up

  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

When("Application A has failed evidence") do
  click_link 'Sign out', visible: false
  fill_in 'Email', with: @user1.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.waiting_for_evidence_application_link.click

  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  expect(evidence_accuracy_page.content).to have_problem_with_evidence
  evidence_accuracy_page.content.problem_with_evidence.click
  evidence_accuracy_page.click_next
  expect(reason_for_rejecting_evidence_page.content).to have_header
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  reason_for_rejecting_evidence_page.click_next
  complete_processing
end

When("Application D has correct evidence") do
  dashboard_page.go_home
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link2.click

  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.correct_evidence.click
  evidence_accuracy_page.click_next
  expect(incomes_page.content).to have_header
  fill_in 'Total monthly income from evidence', with: 1000
  evidence_income_page.click_next
  evidence_result_page.click_next
  complete_processing
end

Given("I create an application A that waits for evidence with the same ho_number") do
  @user1 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino,
                                   :waiting_for_evidence_state, :applicant_full, office: @user1.office, user: @user1, ni_number: '', ho_number: 'L1234567')
  @applicant = @application.applicant

end

And("I create an Application B that has correct evidence with the same ho_number") do
  @user2 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state, :applicant_full,
                                   office: @user2.office, user: @user2, ni_number: '', ho_number: 'L1234567')
  @applicant = @application.applicant

  sign_in_page.load_page
  fill_in 'Email', with: @user2.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link.click
  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  evidence_accuracy_page.content.correct_evidence.click
  evidence_accuracy_page.click_next
  expect(incomes_page.content).to have_header
  fill_in 'Total monthly income from evidence', with: 1000
  evidence_income_page.click_next
  evidence_result_page.click_next
  complete_processing
end

When("I create Application C with the same ho_number") do
  click_link 'Sign out', visible: false
  @user3 = FactoryBot.create(:user)
  fill_in 'Email', with: @user3.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'

  FactoryBot.create(:online_application, :with_reference, :income1000, ho_number: 'L1234567', ni_number: '')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up

  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

When("I create Application C with the same ho_number and lowercase ho_number") do
  click_link 'Sign out', visible: false
  @user3 = FactoryBot.create(:user)
  fill_in 'Email', with: @user3.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'

  FactoryBot.create(:online_application, :with_reference, :income1000, ho_number: 'l1234567', ni_number: '')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up

  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

Then("I create Application D with the same ho_number") do
  click_link 'Sign out', visible: false
  sign_in_as_user
  FactoryBot.create(:online_application, :with_reference, :income1000, ho_number: 'L1234567', ni_number: '')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end

And("I create an Application B and wrong evidence is provided with the same ho_number") do
  @user2 = FactoryBot.create(:user)
  @application = FactoryBot.create(:application_full_remission_nino, :waiting_for_evidence_state,
                                   :applicant_full, ni_number: '', ho_number: 'L1234567', office: @user2.office, user: @user2)
  @applicant = @application.applicant

  sign_in_page.load_page
  fill_in 'Email', with: @user2.email
  fill_in 'Password', with: 'password1234'
  click_on 'Sign in'
  dashboard_page.content.wait_until_last_application_header_visible
  dashboard_page.content.waiting_for_evidence_application_link.click
  click_on 'Start now', visible: false
  expect(evidence_accuracy_page.content).to have_header
  expect(evidence_accuracy_page.content).to have_problem_with_evidence
  evidence_accuracy_page.content.problem_with_evidence.click
  evidence_accuracy_page.click_next
  expect(reason_for_rejecting_evidence_page.content).to have_header
  reason_for_rejecting_evidence_page.content.requested_sources_not_provided.click
  reason_for_rejecting_evidence_page.click_next
  complete_processing
end

Then("I create Application E with the same ho_number") do
  click_link 'Sign out', visible: false
  sign_in_as_user
  FactoryBot.create(:online_application, :with_reference, :income1000, ho_number: 'L1234567', ni_number: '')
  reference = OnlineApplication.last.reference
  fill_in 'Reference', with: reference
  expect(dashboard_page.content.online_search_reference.value).to have_text(reference)
  dashboard_page.click_look_up
  expect(process_online_application_page.content).to have_application_details_header
  process_online_application_page.content.jurisdiction.click
  choose('other_radio', allow_label_click: true)
  process_online_application_page.content.form_input.set 'ABC123'
  process_online_application_page.click_next
  complete_processing
end
