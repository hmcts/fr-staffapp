require 'rails_helper'

# I'm disabling this Rubocop check to allow writing readable scenarios

RSpec.feature 'Manager has to setup their preferences' do

  let(:jurisdictions) { create_list(:jurisdiction, 3) }
  let(:office) { create(:office, jurisdictions: jurisdictions) }

  scenario 'Signing in for second time or later and is redirected to dashboard' do
    manager_has_signed_in_before
    when_they_sign_in
    then_they_are_redirected_to_the_dashboard
  end

  scenario 'Signing in for the first time is redirected to their profile setup' do
    manager_has_not_signed_in_before
    when_they_sign_in
    then_they_are_redirected_to_the_profile_setup
  end

  scenario 'After setting up their profile, they are redirected to dashboard if signing in for the first time' do
    manager_has_not_signed_in_before
    and_they_sign_in
    when_whey_setup_their_profile
    then_they_are_redirected_to_the_dashboard
  end

  def manager_has_signed_in_before
    @manager = create(:manager, sign_in_count: 2, jurisdiction_id: jurisdictions[1].id, office: office)
  end

  def manager_has_not_signed_in_before
    @manager = create(:manager, sign_in_count: 0, jurisdiction_id: jurisdictions[1].id, office: office)
  end

  def when_they_sign_in
    visit new_user_session_path
    fill_in 'user_email', with: @manager.email
    fill_in 'user_password', with: @manager.password
    click_button 'Sign in'
  end
  alias_method :and_they_sign_in, :when_they_sign_in

  def when_whey_setup_their_profile
    choose Jurisdiction.first.name
    click_button 'Save changes'
  end

  def then_they_are_redirected_to_the_dashboard
    expect(page.current_path).to eql '/'
  end

  def then_they_are_redirected_to_the_profile_setup
    expect(page.current_path).to eql "/users/#{@manager.id}/edit"
  end
end
