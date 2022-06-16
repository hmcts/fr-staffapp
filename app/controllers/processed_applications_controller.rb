class ProcessedApplicationsController < ApplicationController
  include ProcessedViewsHelper

  def index
    authorize :application

    @applications = paginated_applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    @form = Forms::Application::Delete.new(application)
    assign_views

    track_application(application)
  end

  def update
    @form = Forms::Application::Delete.new(application)
    @form.update(delete_params)
    authorize application
    save_and_respond_on_update
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def paginated_applications
    @paginate ||= paginate(
      policy_scope(query_object)
    )
  end

  def delete_params
    params.require(:application).permit(*Forms::Application::Delete.permitted_attributes.keys).to_h
  end

  def save_and_respond_on_update
    if @form.save
      ResolverService.new(application, current_user).delete
      flash[:notice] = I18n.t('processed_applications.notice.deleted')
      redirect_to(action: :index)
    else
      assign_views
      render :show
    end
  end

  def query_object
    Query::ProcessedApplications.new(current_user).find
  end
end
