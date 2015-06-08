require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  include Devise::TestHelpers

  let(:user)        { create :user }
  let(:admin_user)  { create :admin_user }
  let(:test_user)   { create :user }
  let(:manager)     { create :manager }

  context 'logged out user' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #show' do
      it 'redirects to login page' do
        get :show, id: test_user.to_param
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe 'GET #edit' do
      it 'redirects to login page' do
        get :edit, id: test_user.to_param
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  context 'standard user' do

    before(:each) { sign_in user }

    describe 'GET #index' do
      it 'generates access denied error' do
        expect {
          get :index
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end

    describe 'GET #show' do
      it 'generates access denied error' do
        expect {
          get :edit, id: test_user.to_param
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end

    describe 'GET #edit' do
      it 'generates access denied error' do
        expect {
          get :show, id: test_user.to_param
        }.to raise_error CanCan::AccessDenied, 'You are not authorized to access this page.'
      end
    end
  end

  context 'manager' do

    before(:each) do
      User.delete_all
      create_list :user, 3, office: manager.office
      create_list :user, 3, office: create(:office)
      sign_in manager
    end

    describe 'GET #index' do
      it 'only shows users from the current_users office' do
        get :index
        expect(assigns(:users).count).to eql(4)
        expect(User.count).to eql(7)
      end

      it 'does not show admins assigned to their office' do
        create :admin_user, office: manager.office
        get :index
        expect(User.count).to eql(8)
        expect(assigns(:users).count).to eql(4)
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before(:each) { get :show, id: User.first.to_param }

        it 'renders the view' do
          expect(response).to render_template :show
        end
        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'for a user not in their office' do
        it 'returns a redirect code' do
          expect {
            get :show, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end

        it 'renders the index view' do
          expect {
            get :show, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end
      end
    end

    describe 'GET #edit' do
      context 'for a user not in their office' do
        it 'returns a redirect code' do
          expect {
            get :show, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end

        it 'renders the index view' do
          expect {
            get :show, id: User.last.to_param
          }.to raise_error CanCan::AccessDenied, 'You are not authorized to manage this user.'
        end
      end

      context 'for a user in their office' do
        it 'shows edit page' do
          get :edit, id: User.first.to_param
          expect(response).to render_template :edit
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) {
          {
            email: 'new_attributes@hmcts.gsi.gov.uk',
            role: 'user',
            office_id: manager.office_id
          }
        }

        before(:each) { put :update, id: User.first.to_param, user: new_attributes }

        it 'updates the requested user' do
          User.first.reload
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(User.first)
        end

        it 'redirects to the user' do
          assigns(:user)
          expect(response).to redirect_to(user_path)
        end

        context 'and changing office' do

          let(:new_office) { create(:office) }
          let(:new_office_attributes) {
            {
              email: 'new_attributes@hmcts.gsi.gov.uk',
              password: 'aabbccdd',
              role: 'user',
              office_id: new_office.id
            }
          }

          before(:each) { put :update, id: User.first.to_param, user: new_office_attributes }

          it 'updates the user' do
            user.reload
          end

          it 'returns a redirect status' do
            expect(response).to have_http_status(:redirect)
          end

          it 'redirects to the user list' do
            expect(response).to redirect_to users_path
          end

          it 'displays an alert containing contact details for the new manager' do
            err_msg = I18n.t('error_messages.user.moved_offices', user: User.first.name, office: new_office.name, contact: new_office.managers_email)
            expect(flash[:notice]).to be_present
            expect(flash[:notice]).to eql(err_msg)
          end
        end
      end

      context 'with invalid params' do
        it 'assigns the user as @user' do
          put :update, id: User.first.to_param, user: attributes_for(:invalid_user)
          expect(assigns(:user)).to eq(User.first)
        end

        it 're-renders the "edit" template' do
          put :update, id: User.first.to_param, user: attributes_for(:invalid_user)
          expect(response).to render_template('edit')
        end
      end
    end
  end

  context 'admin user' do

    before do
      User.delete_all
      create_list :user, 3, office: admin_user.office
      create_list :user, 3, office: create(:office)
    end

    before(:each) { sign_in admin_user }

    describe 'GET #index' do
      it 'shows user list' do
        get :index
        expect(assigns(:users).count).to eql(7)
      end
    end

    describe 'GET #show' do
      context 'for a user in their office' do

        before(:each) do
          get :show, id: User.first.to_param
        end

        it 'renders the view' do
          expect(response).to render_template :show
        end

        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'for a user not in their office' do

        before(:each) { get :show, id: User.last.to_param }

        it 'returns a success code' do
          expect(response).to have_http_status(:success)
        end

        it 'renders the index view' do
          expect(response).to render_template :show
        end
      end
    end

    describe 'GET #show' do
      it 'shows user details' do
        get :show,  id: test_user.to_param
        expect(assigns(:user)).to eq(test_user)
      end
    end

    describe 'GET #edit' do
      it 'shows edit page' do
        get :edit, id: test_user.to_param
        expect(assigns(:user)).to eq(test_user)
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do

        let(:new_attributes) {
          {
            email: 'new_attributes@hmcts.gsi.gov.uk',
            password: 'aabbccdd',
            role: 'user',
            office_id: test_user.office_id
          }
        }

        before(:each) { put :update, id: test_user.to_param, user: new_attributes }

        it 'updates the requested user' do
          test_user.reload
          expect(test_user.email).to eql('new_attributes@hmcts.gsi.gov.uk')
        end

        it 'assigns the requested user as @user' do
          expect(assigns(:user)).to eq(test_user)
        end

        it 'redirects to the user' do
          expect(response).to redirect_to(user_path)
        end
      end

      context 'with invalid params' do

        before(:each) { put :update, id: test_user.to_param, user: attributes_for(:invalid_user) }

        it 'assigns the user as @user' do
          expect(assigns(:user)).to eq(test_user)
        end

        it 're-renders the "edit" template' do
          expect(response).to render_template('edit')
        end
      end
    end
  end
end
