class EvidenceController < ApplicationController
  before_action :authorize_evidence_check_update, except: :show
  before_action only: [:accuracy, :income, :result, :summary,
                       :confirmation, :return_letter, :show] do
    track_application(application)
  end

  before_action :only_non_processed_applications, except: [:confirmation]
  before_action :store_path, except: [:accuracy_save, :income_save, :confirmation]
  before_action :clear_path, only: :confirmation

  include ProcessedViewsHelper

  def show
    authorize evidence

    processing_details
    assign_views
  end

  def accuracy
    @form = Forms::Evidence::Accuracy.new(evidence)
  end

  def accuracy_save
    @form = Forms::Evidence::Accuracy.new(evidence)
    @form.update(accuracy_params)

    if @form.save
      redirect_after_accuracy_save
    else
      render :accuracy
    end
  end

  def income
    @form = Forms::Evidence::Income.new(evidence)
  end

  def income_save
    @form = Forms::Evidence::Income.new(evidence)
    @form.update(income_params)

    if @form.save
      redirect_to result_evidence_path
    else
      render :income
    end
  end

  def result
    application_result
  end

  def summary
    evidence_view
    assign_views
    application_result
  end

  def summary_save
    ResolverService.new(evidence, current_user).complete
    process_evidence_check_flag
    redirect_to confirmation_evidence_path
  end

  def confirmation
    evidence_confirmation
  end

  def return_letter
    assign_views
  end

  def return_application
    if ResolverService.new(evidence, current_user).return
      back_to_start_or_list
    else
      flash[:alert] = t('error_messages.evidence.cannot_be_saved')
      redirect_to return_letter_evidence_path
    end
  end

  def process_evidence_check_flag
    evidence_check = EvidenceCheckFlaggingService.new(evidence)
    evidence_check.process_flag if evidence_check.can_be_flagged?
  end

  private

  def authorize_evidence_check_update
    authorize evidence, :update?
  end

  def evidence
    @evidence ||= EvidenceCheck.find(params[:id])
  end

  def application
    evidence.application
  end

  def processing_details
    @processing_details = Views::ProcessedData.new(evidence.application)
  end

  def evidence_view
    @evidence_view = Views::Evidence.new(evidence)
  end

  def accuracy_params
    return {} unless params.key?(:evidence)
    params.require(:evidence).permit(*Forms::Evidence::Accuracy.permitted_attributes).to_h
  end

  def redirect_after_accuracy_save
    if @form.correct
      redirect_to income_evidence_path
    else
      redirect_to evidence_accuracy_incorrect_reason_path(evidence)
    end
  end

  def income_params
    params.require(:evidence).permit(*Forms::Evidence::Income.permitted_attributes).to_h
  end

  def application_result
    @result = Views::ApplicationResult.new(evidence.application)
  end

  def evidence_confirmation
    @application = evidence.application
    @confirm = Views::Confirmation::Result.new(@application)
    @form = Forms::Application::DecisionOverride.new(@application)
    render 'applications/process/confirmation/index'
  end

  def only_non_processed_applications
    if @evidence.try(:completed_at).present?
      flash[:alert] = I18n.t('application_redirect.processed')
      redirect_to root_path
    end
  end

  def back_to_start_or_list
    redirect_to params[:back_to_list].present? ? evidence_checks_path : root_path
  end
end
