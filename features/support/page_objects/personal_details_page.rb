class PersonalDetailsPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Personal details'
    element :application_first_name, '#application_first_name'
    element :dob_legend, 'legend', text: 'Date of birth'
    element :dob_hint, '.govuk-hint', text: 'For example, 31 3 1980'
    element :application_day_date_of_birth, '#application_day_date_of_birth'
    element :application_month_date_of_birth, '#application_month_date_of_birth'
    element :application_year_date_of_birth, '#application_year_date_of_birth'
    element :ni_label, '.govuk-label', text: 'National Insurance number'
    element :ni_hint, '.hint', text: 'Must be completed for benefits-based applications'
    element :application_ni_number, '#application_ni_number'
    element :ho_label, '.govuk-label', text: 'Home Office reference number'
    element :ho_hint, '.hint', text: 'Where provided'
    element :application_ho_number, '#application_ho_number'
    element :last_name_error, '.error', text: 'Enter the applicant\'s last name'
    element :last_name_too_short_error, '.error', text: 'Last name is too short (minimum is 2 characters)'
    element :invalid_date_of_birth_error, '.error', text: 'Enter a valid date of birth'
    element :dob_in_the_future_error, '.error', text: 'Applicant\'s date of birth cannot be in the future'
    element :martial_status_error, '.error', text: 'Select a marital status'
    element :martial_status_legend, 'legend', text: 'Select the applicant\'s marital status'
    element :status_single, 'label', text: 'Single'
    element :status_married, 'label', text: 'Married or living with someone and sharing an income'
    section :guidance, '.guidance' do
      elements :guidance_header, 'h2'
      elements :guidance_text, 'p'
      elements :guidance_list, 'ul'
      elements :guidance_sub_heading, 'h3'
      elements :guidance_link, 'a'
    end
  end

  def full_name
    fill_in 'Title', with: 'Mr'
    fill_in 'First and middle names', with: 'John Christopher'
    fill_in 'Last name', with: 'Smith'
  end

  def valid_dob
    content.application_day_date_of_birth.set '10'
    content.application_month_date_of_birth.set '02'
    content.application_year_date_of_birth.set '1986'
  end

  def in_the_future_dob
    tomorrow = Time.zone.tomorrow
    content.application_day_date_of_birth.set tomorrow.day
    content.application_month_date_of_birth.set tomorrow.month
    content.application_year_date_of_birth.set tomorrow.year
  end

  def valid_ni
    content.application_ni_number.set 'JR054008D'
  end

  def valid_ho
    content.application_ho_number.set '1212-0001-0240-0490/01'
  end

  def submit_required_personal_details
    fill_in 'Last name', with: 'Smith'
    valid_dob
    content.status_single.click
    next_page
  end

  def submit_all_personal_details
    full_name
    valid_dob
    valid_ni
    valid_ho
    content.status_single.click
    next_page
  end
end
