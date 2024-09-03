def fill_personal_details(ni_number = 'SN123456C')
  expect(page).to have_text 'Personal details'
  fill_in 'Title', with: 'Mr.'
  fill_in 'First and middle names', with: 'Johny'
  fill_in 'Last name', with: 'Mnemonick'
  fill_in 'application_day_date_of_birth', with: '01'
  fill_in 'application_month_date_of_birth', with: '01'
  fill_in 'application_year_date_of_birth', with: '2000'
  fill_in 'National Insurance number', with: ni_number
  choose 'Single'
  click_button 'Next'
end

def fill_application_details(court_fee = '1000')
  expect(page).to have_css('h1', text: 'Application details')
  fill_in 'application_fee', with: court_fee
  select_jurisdiction
  fill_in_date_received(Date.yesterday)
  select_other_application
  fill_in 'application_form_name', with: 'ABC123'
  click_button 'Next'
end

def fill_application_refund_details(court_fee = '1000')
  expect(page).to have_text 'Application details'
  fill_in 'application_fee', with: court_fee
  select_jurisdiction
  select_other_application
  fill_in 'application_form_name', with: 'ABC123'
  fill_application_dates
end

def fill_application_dates
  fill_in_date_received(Date.yesterday)

  check 'This is a refund case'

  fill_in_date_fee_paid(2.days.ago.to_date)
  click_button 'Next'
end

def fill_application_emergency_details
  expect(page).to have_text 'Application details'
  fill_in 'application_fee', with: '1000'
  select_jurisdiction
  fill_in_date_received(Date.yesterday)
  select_other_application
  fill_in 'application_form_name', with: 'ABC123'
  check 'This is an emergency case'
  fill_in 'Reason for emergency', with: 'Iam in a hurry'
  click_button 'Next'
end

def fill_saving_and_investment
  expect(page).to have_text 'Savings and investments'
  choose 'Less than £3,000'
  click_button 'Next'
end

def fill_saving_exceeded_over_66
  expect(page).to have_text 'Savings and investments'
  choose 'application_min_threshold_exceeded_true'

  choose 'application_max_threshold_exceeded_true'

  click_button 'Next'
end

def fill_saving_above_threshold
  expect(page).to have_text 'Savings and investments'
  choose 'application_min_threshold_exceeded_true'

  fill_in 'How much do they have in savings and investments?', with: '4000'

  click_button 'Next'
end

def fill_benefits(benefits)
  expect(page).to have_text 'Benefits'
  choose benefits ? 'Yes' : 'No'

  click_button 'Next'
end

def fill_benefit_evidence(benefits_options)
  expect(page).to have_text 'Has the applicant provided the correct paper evidence of benefits received for the period they have declared in the application?'
  if benefits_options[:paper_provided]
    choose 'Yes, the applicant has provided supporting evidence'
  else
    choose 'benefit_override_evidence_false'
  end

  click_button 'Next'
end

def fill_income(supporting_children)
  expect(page).to have_text 'Income'
  if supporting_children
    choose 'Yes'
    fill_in 'Number of children', with: '2'
  else
    choose 'No'
  end
  fill_in 'Total monthly income', with: '1000'

  click_button 'Next'
end

def has_evidence_check?
  evidene_check.present?
end

def has_evidence_check_flagged?
  ev_check = evidene_check
  ev_check && ev_check.check_type == 'flag'
end

def fill_income_above_threshold(monthly_income = '6000')
  expect(page).to have_text 'income'
  choose 'application_dependents_false'

  fill_in 'Total monthly income', with: monthly_income

  click_button 'Next'
end

def evidene_check
  reference_number = find(:xpath, './/strong[@class="reference-number"]').text
  application = Application.where(reference: reference_number).last
  application.try(:evidence_check)
end

def create_flag_check(ni_number)
  EvidenceCheckFlag.create(reg_number: ni_number, active: true, count: 1)
end

def fill_application_date_over_limit
  fill_in 'application_fee', with: '1000'
  select_jurisdiction
  fill_in_date_received(Date.yesterday)

  fill_in 'application_form_name', with: 'ABC123'
  check 'This is a refund case'
end

def fill_application_date_set_discretion_no
  fill_application_date_over_limit
  fill_in_date_fee_paid(4.months.ago.to_date)
  select_other_application
  fill_in 'application_form_name', with: 'ABC123'
  click_button 'Next'

  choose 'application_discretion_applied_false'
  click_button 'Next'
end

def fill_application_date_set_discretion_yes
  fill_application_date_over_limit
  fill_in_date_fee_paid(4.months.ago.to_date)
  click_button 'Next'

  select_other_application
  choose 'application_discretion_applied_true'

  within(:css, '#discretion-applied-yes-only') do
    fill_in 'Delivery Manager name', with: 'Tester'
    fill_in 'Discretion reason', with: 'test in progress'
  end
  click_button 'Next'
end

def select_jurisdiction
  choose Jurisdiction.first.display_full.to_s
end

def fill_in_date_received(date_received)
  fill_in 'application_day_date_received', with: date_received.day
  fill_in 'application_month_date_received', with: date_received.month
  fill_in 'application_year_date_received', with: date_received.year
end

def fill_in_date_fee_paid(date_fee_paid)
  fill_in 'application_day_date_fee_paid', with: date_fee_paid.day
  fill_in 'application_month_date_fee_paid', with: date_fee_paid.month
  fill_in 'application_year_date_fee_paid', with: date_fee_paid.year
end

def select_other_application
  choose('other_radio')
end
