class Applications::BuildController < ApplicationController
  include Wicked::Wizard
  before_action :authenticate_user!
  before_action :find_application, only: [:show, :update]
  before_action :populate_jurisdictions, only: [:show, :update]

  steps :personal_information,
    :application_details,
    :savings_investments,
    :benefits,
    :benefits_result,
    :income,
    :income_result,
    :summary

  def create
    @application = Application.create(
      jurisdiction_id: current_user.jurisdiction_id,
      office_id: current_user.office_id,
      user_id: current_user.id
    )
    redirect_to wizard_path(steps.first, application_id: @application.id)
  end

  def show # rubocop:disable CyclomaticComplexity
    case step
    when :benefits
      jump_to(:summary) unless @application.savings_investment_result?
    when :benefits_result
      jump_to(:income) unless @application.benefits
    when :income
      jump_to(:summary) if @application.benefits
    end
    render_wizard
  end

  def update
    params[:application][:status] = (step == steps.last) ? 'active' : step.to_s
    @application.update(application_params)
    render_wizard @application
  end

  private

  def find_application
    @application = Application.find(params[:application_id])
  end

  def personal_information
    [:title,
     :first_name,
     :last_name,
     :date_of_birth,
     :ni_number,
     :married]
  end

  def application_details
    [:fee, :jurisdiction_id, :date_received,
     :form_name, :case_number, :probate,
     :deceased_name, :date_of_death, :refund,
     :date_fee_paid]
  end

  def application_params
    all_params            = [:status]
    savings_investments   = [:threshold_exceeded, :over_61, :high_threshold_exceeded]
    benefits              = [:benefits]
    income                = [:dependents, :income, :children]

    all_params << personal_information << application_details <<
      savings_investments << benefits << income

    params.require(:application).permit(all_params.flatten)
  end

  def populate_jurisdictions
    @jurisdictions = current_user.office.jurisdictions
  end
end
