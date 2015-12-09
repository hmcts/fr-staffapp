require 'rails_helper'

RSpec.describe 'users/invitations/new', type: :view do

  include Devise::TestHelpers

  context 'as an admin' do
    let(:admin) { FactoryGirl.create :admin_user }
    before(:each) do
      assign(:user, User.new)
      assign(:roles, User::ROLES)
      sign_in admin
      render
    end
    it 'renders new user invite form with three roles' do
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", count: 3)
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Admin')
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Manager')
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'User')
    end
    it 'renders the office as a drop down' do
      expect(rendered).to have_xpath("//select[@name='user[office_id]']")
      expect(rendered).to have_xpath("//select[@name='user[office_id]']/option")
    end

  end

  context 'as a manager' do
    let(:manager) { FactoryGirl.create :manager }

    before(:each) do
      assign(:user, User.new)
      assign(:roles, User::ROLES - %w[admin])
      sign_in manager
      render
    end
    it 'renders new user invite form with three roles' do
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", count: 2)
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'Manager')
      expect(rendered).to have_xpath("//select[@name='user[role]']/option", text: 'User')
      expect(rendered).to_not have_xpath("//select[@name='user[role]']/option", text: 'Admin')
    end
    it 'does not render the office name' do
      expect(rendered).to_not include(manager.office.name)
    end
    it 'adds a hidden field for office id' do
      expect(rendered).to_not have_xpath("//select[@name='user[office_id]']")
      expect(rendered).to have_xpath("//input[@name='user[office_id]' and @value='#{manager.office.id}']")

    end
  end
end
