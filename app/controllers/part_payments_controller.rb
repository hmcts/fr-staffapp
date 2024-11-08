class PartPaymentsController < ApplicationController
  skip_after_action :verify_authorized, only: :index

  before_action :authorize_part_payment_update, except: [:show, :index]
  before_action only: [:show, :accuracy, :summary, :confirmation, :return_letter] do
    track_application(application)
  end

  before_action :store_path, except: [:accuracy_save, :income_save, :confirmation]
  before_action :clear_path, only: :confirmation

  include ProcessedViewsHelper
  include FilterApplicationHelper

  def index
    @waiting_for_part_payment = LoadApplications.waiting_for_part_payment(current_user, filter)
  end

  def show
    authorize part_payment

    processing_details
    assign_views
  end

  def accuracy
    @form = Forms::PartPayment::Accuracy.new(part_payment)
  end

  def accuracy_save
    @form = Forms::PartPayment::Accuracy.new(part_payment)
    @form.update(accuracy_params)

    if @form.save
      redirect_to(summary_part_payment_path(part_payment))
    else
      render :accuracy
    end
  end

  def summary
    @part_payment = part_payment
    assign_views
    @result = Views::PartPayment::Result.new(part_payment)
  end

  def summary_save
    ResolverService.new(part_payment, current_user).complete
    redirect_to(confirmation_part_payment_path(part_payment))
  end

  def confirmation
    assign_views
    @result = Views::PartPayment::Result.new(part_payment)
  end

  def return_letter
    assign_views
  end

  def return_application
    if ResolverService.new(part_payment, current_user).return
      back_to_start_or_list
    else
      flash[:alert] = t('error_messages.part_payment.cannot_be_saved')
      redirect_to return_letter_part_payment_path
    end
  end

  private

  def part_payment
    @part_payment ||= PartPayment.find(params[:id])
  end

  def application
    part_payment.application
  end

  def authorize_part_payment_update
    authorize part_payment, :update?
  end

  def processing_details
    @processing_details = Views::ProcessedData.new(part_payment.application)
  end

  def accuracy_params
    params.require(:part_payment).permit(*Forms::Accuracy.permitted_attributes).to_h
  end

  def back_to_start_or_list
    redirect_to params[:back_to_list].present? ? part_payments_path : root_path
  end
end
