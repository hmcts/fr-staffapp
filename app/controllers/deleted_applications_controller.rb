class DeletedApplicationsController < ApplicationController
  include ProcessedViewsHelper
  include FilterApplicationHelper

  def index
    authorize :application

    @applications = paginated_applications.map do |application|
      Views::ApplicationList.new(application)
    end
  end

  def show
    authorize application

    assign_views

    track_application(application)
  end

  private

  def application
    @application ||= Application.find(params[:id])
  end

  def paginated_applications
    @paginate ||= paginate(policy_scope(Query::DeletedApplications.new(current_user).find(filter)))
  end
end
