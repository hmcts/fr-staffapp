module EvidenceCheckHelper
  SECTION_TO_INCOME_KIND_MAPPING = {
    'wages' => ["Wages before tax and National Insurance are taken off", "Net profits from self employment",
                "Pensions (state, work, private)", "Pensions (state, work, private, pension credit (savings credit))"],
    'child_maintenance' => ["Maintenance payments"],
    'rental' => ["Rent from anyone living with the applicant", "Rent from other properties the applicant owns",
                 "Rent from anyone living with the partner", "Rent from other properties the partner owns",
                 "Rent from anyone living with you", "Rent from other properties you own"],
    'benefits_and_credits' => ["Working Tax Credit", "Child Tax Credit",
                               "Contribution-based Jobseekers Allowance (JSA)",
                               "Contribution-based Employment and Support Allowance (ESA)", "Universal Credit",
                               "Pensions (state, work, private)",
                               "Pensions (state, work, private, pension credit (savings credit))"],
    'goods_selling' => ["Other income - For example, income from online selling",
                        "Other income - For example, income from online selling or from dividend or interest payments",
                        "Other income"]
  }.freeze

  def maximum_income_allowed(application)
    thresholds = IncomeThresholds.new(application.applicant.married?, application.children)
    thresholds.max_threshold
  end

  def income_increase?(application)
    if application.income.try(:positive?) &&
       application.evidence_check.income.try(:positive?) &&
       (application.income < application.evidence_check.income)
      return true
    end
    false
  end

  def display_evidence_section?(application, section_name)
    list = income_kind_list(application)
    return false if list.blank? || !SECTION_TO_INCOME_KIND_MAPPING.key?(section_name)
    SECTION_TO_INCOME_KIND_MAPPING[section_name].intersect?(list)
  end

  def income_kind_list(application) # rubocop:disable Metrics/MethodLength
    return nil if application.income_kind.blank?

    list = []
    list += application.income_kind[:applicant].map do |kind|
      I18n.t(kind, scope: ['activemodel.attributes.forms/application/income_kind_applicant', 'kinds'])
    end
    if application.income_kind.key?(:partner)
      list += application.income_kind.try(:[], :partner).map do |kind|
        I18n.t(kind, scope: ['activemodel.attributes.forms/application/income_kind_partner', 'kinds'])
      end
    end

    list
  end # rubocop:enable Metrics/MethodLength

end
