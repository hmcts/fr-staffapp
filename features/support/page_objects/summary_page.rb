class SummaryPage < BasePage
  set_url_matcher %r{/applications/[0-9]+/summary}

  section :content, '#content' do
    element :header, 'h1', text: 'Check details'
    element :personal_details_header, 'h2', text: 'Personal details'
    sections :summary_section, 'dl' do
      element :evidence_header, 'h2', text: 'Evidence'
      elements :list_row, '.govuk-summary-list__row'
      elements :list_key, '.govuk-summary-list__key'
      elements :list_actions, '.govuk-summary-list__actions'
      element :evidence_reason, '.govuk-summary-list__row', text: 'Reason Not arrived or too late'
      element :evidence_incorrect_reason_category, '.govuk-summary-list__row', text: 'Incorrect reason category Requested sources not provided, Wrong type provided, Unreadable or illegible, Pages missing, Cannot identify applicant, Wrong date range Change'
      element :change_benefits, 'a', text: 'Change Benefits declared in application'
    end
  end
end
