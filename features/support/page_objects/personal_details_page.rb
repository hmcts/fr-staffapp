class PersonalDetailsPage < BasePage
  section :content, '#content' do
    element :header, 'h1', text: 'Personal details'
    element :application_title, '#application_title'
    element :application_first_name, '#application_first_name'
    element :application_last_name, '#application_last_name'
    element :last_name_error, '.field_with_errors', text: 'Enter the applicant\'s last name'
    element :application_day_date_of_birth, '#application_day_date_of_birth'
    element :application_month_date_of_birth, '#application_month_date_of_birth'
    element :application_year_date_of_birth, '#application_year_date_of_birth'
    element :application_ni_number, '#application_ni_number'
    element :invalid_date_of_birth_error, '.error', text: 'Enter a valid date of birth'
    element :under_16_error, '.error', text: 'The applicant can\'t be under 16 years old'
    element :status_single, 'label', text: 'Single'
    element :status_married, 'label', text: 'Married or living with someone and sharing an income'
  end

  def full_name
    content.application_title.set 'Mr'
    content.application_first_name.set 'John Christopher'
    content.application_last_name.set 'Smith'
  end

  def valid_dob
    content.application_day_date_of_birth.set '10'
    content.application_month_date_of_birth.set '02'
    content.application_year_date_of_birth.set '1986'
  end

  def under_16_dob
    content.application_day_date_of_birth.set '10'
    content.application_month_date_of_birth.set '02'
    content.application_year_date_of_birth.set  Time.zone.today.year
  end

  def valid_ni
    content.application_ni_number.set 'JR054008D'
  end

  def submit_required_personal_details
    content.application_last_name.set 'Smith'
    valid_dob
    content.status_single.click
    next_page
  end

  def submit_all_personal_details
    full_name
    valid_dob
    valid_ni
    content.status_single.click
    next_page
  end
end
