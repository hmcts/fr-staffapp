require 'rails_helper'

RSpec.feature 'Office management', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user)          { FactoryGirl.create :user }
  let(:admin_user)    { FactoryGirl.create :admin_user }

  context 'Admin user' do
    scenario 'creates a new office' do

      new_court = 'new court'

      login_as admin_user
      visit new_office_path

      fill_in 'office_name', with: new_court
      click_button 'Create Office'

      expect(page).to have_text("Name:#{new_court}")
    end
  end
end
