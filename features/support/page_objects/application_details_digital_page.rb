class ApplicationDetailsDigitalPage < BasePage
  set_url_matcher %r{/online_applications/[0-9]+/edit}

  section :content, '#main-content' do
    element :header, 'h1', text: 'Application details'
    element :jurisdiction_label, 'label', text: 'Jurisdiction'
    element :jurisdiction, '.govuk-radios__item'
    element :jurisdiction_error, '.error', text: 'You must select a jurisdiction'
    element :date_received_label, 'label', text: 'Date received'
    element :date_received_hint, '.hint', text: 'Use this format DD/MM/YYYY'
    element :day_date_received, '#application_day_date_fee_paid'
    element :month_date_received, '#application_month_date_fee_paid'
    element :year_date_received, '#application_year_date_fee_paid'
    element :application_date_error, '.error', text: 'Enter the date in this format DD/MM/YYYY'
    element :form_label, 'label', text: 'Name of form'
    element :form_hint, 'label', text: 'You\'ll find this on the bottom of the form, for example C100 or ADM1A'
    element :form_input, '#application_form_name'
    element :emergency_case, '.govuk-label', text: 'Emergency'
    element :exceed_fee_limit_error, '.error', text: 'You need to enter an amount below £20,000'
    element :fee_blank_error, '.error', text: 'Enter a court or tribunal fee'
    element :form_error_message, '.error', text: 'Enter a valid name of form'
    element :invalid_form_number_message, '.error', text: 'You entered the help with fees name of form. Enter the number on the court or tribunal form.'
    element :next, 'input[value="Next"]'
    element :emergency_case_error, 'label', text: 'Enter reason for emergency'
    element :emergency_case_textbox, '#online_application_emergency_reason'
    section :guidance, '.guidance' do
      elements :guidance_header, 'h2'
      elements :guidance_text, 'p'
      elements :guidance_list, 'ul'
      elements :guidance_sub_heading, 'h3'
      elements :guidance_link, 'a'
    end
  end

  def click_next
    content.wait_until_next_visible
    content.next.click
  end
end
