class ProblemWithEvidencePage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'What is the problem?'
    element :not_arrived_too_late, '.govuk-label', text: 'Not arrived or too late', visible: false
    element :not_proceeding, '.govuk-label', text: 'Citizen not proceeding', visible: false
    element :staff_error, '.govuk-label', text: 'Staff error'
    element :error, '.error', text: 'Select from one of the options'
  end

  def go_to_problem_with_evidence_page
    waiting_evidence_application_ni
    waiting_evidence_application_ni
    click_link("#{reference_prefix}-000002")
    evidence_page.content.evidence_can_not_be_processed.click
    click_link('Return application')
  end

  def submit_not_arrived_too_late
    problem_with_evidence_page.content.not_arrived_too_late.click
    click_on 'Next', visible: false
  end

  def submit_not_proceeding
    problem_with_evidence_page.content.not_proceeding.click
    click_on 'Next', visible: false
  end

  def submit_staff_error
    problem_with_evidence_page.content.staff_error.click
    fill_in 'Please add details of the staff error', with: 'These are the details of the staff error'
    click_on 'Next', visible: false
  end
end
