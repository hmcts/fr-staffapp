class Users::InvitationsController < Devise::InvitationsController
  respond_to :html
  before_action :authenticate_user!
  before_action :build_role_list, only: [:new, :create]

  load_and_authorize_resource User, except: [:edit, :update]

  def new
    @user = User.new
    render :new
  end

  private

  def build_role_list
    if current_user.admin?
      @roles = User::ROLES
    else
      @roles = User::ROLES - %w[admin]
    end
  end

  def invite_resource
    resource_class.invite!(invite_params, current_inviter)
  end

  def invite_params
    params.require(:user).permit(:email, :role, :name, :office_id)
  end
end
