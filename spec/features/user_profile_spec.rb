require 'rails_helper'

RSpec.feature 'User profile', type: :feature do

  include Warden::Test::Helpers
  Warden.test_mode!

  let(:user) { create :user, office: create(:office) }
  let(:another_user) { create :user, office: create(:office) }

  context 'as a user' do

    before(:each) do
      login_as user
      visit '/'
    end

    scenario 'link to their profile' do
      top_right_corner = '/html/body/div[1]/nav/section/ul/li/div/span/text()'
      expect(page).to have_xpath(top_right_corner, text: "#{user.name}")
    end

    context 'show view' do
      scenario 'view their profile' do
        click_link 'View profile'
        ['Staff details',
         "#{user.email}",
         "#{user.role}"].each { |line| expect(page).to have_text line }
      end

      scenario 'only view their own profile' do
        visit user_path(another_user.id)
        expect(page).not_to have_text "#{another_user.email}"
      end
    end

    context 'edit' do
      before(:each) { visit edit_user_path user.id }

      scenario 'their profile' do
        ['Change details',
         'Office',
         'Main jurisdiction',
         'Role'].each { |value| expect(page).to have_text value }
      end

      scenario 'their role should not be editable' do
        expect(page).not_to have_select('user[role]', options: ['User', 'Manager'])
      end
    end
  end
end
