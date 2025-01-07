module ProcessedViewsHelper
  # rubocop:disable Rails/HelperInstanceVariable,Metrics/AbcSize,Metrics/MethodLength
  def assign_views
    @application = application
    @fee_status = Views::Overview::FeeStatus.new(application)
    @applicant = Views::Overview::Applicant.new(application)
    @online_applicant = Views::Overview::OnlineApplicant.new(application)
    @details = Views::Overview::Details.new(application)
    @savings = Views::Overview::SavingsAndInvestments.new(application.saving)
    @children = Views::Overview::Children.new(application)
    @income = Views::Overview::Income.new(application)
    @benefits = Views::Overview::Benefits.new(application)
    @application_view = Views::Overview::Application.new(application)
    @result = Views::ApplicationResult.new(application)
    @declaration = Views::Overview::Declaration.new(application)
    @representative = Views::Overview::Representative.new(build_representative(application))
    @processing_details = Views::ProcessedData.new(application)
  end
  # rubocop:enable Rails/HelperInstanceVariable,Metrics/AbcSize,Metrics/MethodLength

  def paginate(query)
    if per_page_is_all?
      query
    else
      query.paginate(page: page, per_page: per_page)
    end
  end

  def previous_page
    page - 1 if page > 1
  end

  def next_page
    page + 1 if page < total_pages
  end

  def page
    params[:page].try(:to_i) || 1
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def total_pages
    per_page_is_all? ? 1 : @paginate.total_pages
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def per_page
    params[:per_page].try(:to_i) || Settings.processed_deleted.per_page
  end

  def citizen_not_proceeding(evidence)
    evidence.try(:incorrect_reason) == 'citizen_not_processing'
  end

  def evidence_not_received(evidence)
    evidence.try(:incorrect_reason) == 'not_arrived_or_late'
  end

  def build_representative(build_from)
    if build_from.is_a?(Application) || !ucd_changes_apply?(build_from)
      build_from.representative
    else
      Representative.new(
        first_name: build_from.legal_representative_first_name,
        last_name: build_from.legal_representative_last_name,
        organisation: build_from.legal_representative_organisation_name,
        position: build_from.legal_representative_position
      )
    end
  end

  private

  def per_page_is_all?
    params[:per_page].eql?('All')
  end
end
