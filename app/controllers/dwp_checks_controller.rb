class DwpChecksController < ApplicationController
  before_action :authenticate_user!
  respond_to :html
  before_action :find_dwp_check, only: [:show]
  before_action :new_from_params, only: [:lookup]
  def new
    authorize! :new, DwpCheck
    @dwp_checker = DwpCheck.new
  end

  def lookup
    authorize! :lookup, DwpCheck
    if @dwp_checker.valid?
      begin
        ProcessDwpService.new(@dwp_checker)
        return redirect_to dwp_checks_path(@dwp_checker.unique_number) if @dwp_checker.reload
      rescue => e
        flash.now[:alert] = e.message
      end
    end
    render action: :new
  end

  def show
    authorize! :show, DwpCheck
  end

private

  def new_from_params
    @dwp_checker = DwpCheck.new(dwp_params)
    @dwp_checker.update(
      created_by_id: current_user.id,
      office_id: current_user.office_id,
    )
  end

  def dwp_params
    params.require(:dwp_check).permit(:last_name, :dob, :ni_number, :date_to_check)
  end

  def find_dwp_check
    @dwp_checker = DwpCheck.find_by(unique_number: params[:unique_number])
  end
end
