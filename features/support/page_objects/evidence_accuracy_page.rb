class EvidenceAccuracyPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Is the evidence ready to process?'
    element :correct_evidence, '.govuk-label', text: 'Yes, the evidence is for the correct applicant and covers the correct time period'
    element :problem_with_evidence, '.govuk-label', text: 'No, there is a problem with the evidence and it needs to be returned'
  end
end
