module SectionViewsHelper
  # rubocop:disable Rails/HelperInstanceVariable
  def build_sections
    @online_application = @application = online_application
    @online_application_view = Views::Overview::OnlineApplicationView.new(online_application)

    # PRE UCD
    pre_ucd_presenters
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def result_section_list
    list = ['benefits_result', 'savings_result', 'income_result']
    list << 'calculation_scheme' if FeatureSwitching.active?(:band_calculation)
    list
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

  # rubocop:disable Rails/HelperInstanceVariable
  def pre_ucd_presenters
    @fee_status = Views::Overview::FeeStatus.new(@online_application)
    @applicant = Views::Overview::Applicant.new(@online_application)
    @online_applicant = Views::Overview::OnlineApplicant.new(@online_application)
    @children = Views::Overview::Children.new(@online_application)
    @application_view = Views::Overview::Application.new(@online_application)
    @details = Views::Overview::Details.new(@online_application)
    @declaration = Views::Overview::Declaration.new(@online_application)
    @representative = Views::Overview::Representative.new(build_representative(@online_application))
  end
  # rubocop:enable Rails/HelperInstanceVariable
end
