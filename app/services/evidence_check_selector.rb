class EvidenceCheckSelector
  def initialize(application, expires_in_days)
    @application = application
    @expires_in_days = expires_in_days
  end

  def decide!
    return if skip_ev_check?
    type = evidence_check_type
    if type
      save_evidence_check(type)
    end
  end

  private

  def skip_ev_check?
    @application.skip_ev_check?
  end

  def evidence_check_type
    return 'random'
    if random_evidence_check?
      'random'
    elsif flagged?
      'flag'
    elsif low_income_check?
      'low_income'
    elsif does_applicant_have_pending_evidence_check?
      'ni_exist'
    end
  end

  def random_evidence_check?
    if ccmcc_evidence_rules?
      outcome = ccmcc_evidence_rules_check
      @ccmcc.clean_annotation_data unless outcome
      outcome
    else
      @application.detail.refund? ? check_every_other_refund : check_every_tenth_non_refund
    end
  end

  def save_evidence_check(type)
    ev_check_attributes = { expires_at: expires_at, check_type: type }

    if type == 'low_income'
      ev_check_attributes[:checks_annotation] = @low_income&.annotation
    elsif @ccmcc.try(:check_type)
      ev_check_attributes[:checks_annotation] = @ccmcc.check_type
    end
    ev_check_attributes[:income_check_type] = income_check_type
    @application.create_evidence_check(ev_check_attributes)
  end

  def check_every_other_refund
    get_evidence_check(2, true)
  end

  def check_every_tenth_non_refund
    get_evidence_check(10, false)
  end

  def get_evidence_check(frequency, refund)
    position = application_position(refund, frequency)
    position_matching_frequency?(position, frequency)
  end

  def position_matching_frequency?(position, frequency)
    (position >= 1) && (position % frequency).zero?
  end

  def application_position(refund, frequency)
    # get only as many last applications we need to check for the frequency
    list = Query::EvidenceCheckable.new.list(@application.id, refund, frequency)

    check_position_index(frequency, list)
  end

  def check_position_index(frequency, list)
    # edge case for test/staging/demo environments
    return 1 if list.count < frequency
    index = list.map { |a| a.evidence_check.try(:check_type) }.rindex('random').to_i

    frequency - index
  end

  def expires_at
    @expires_in_days.days.from_now
  end

  def flagged?
    evidence_check_flag.present? && evidence_check_flag.active?
  end

  def evidence_check_flag
    @evidence_check_flag ||= EvidenceCheckFlag.where(reg_number: registration_number).last
  end

  def registration_number
    @application.applicant.registration_number
  end

  def skip_ni_check_based_on_flag?
    return false if evidence_check_flag.blank?
    !evidence_check_flag.active?
  end

  def does_applicant_have_pending_evidence_check?
    applicant = @application.applicant
    return false if skip_ni_check_based_on_flag?
    applicant.pending_ev_checks?(@application)
  end

  def income_check_type
    hmrc_income_check_type? ? 'hmrc' : 'paper'
  end

  def hmrc_income_check_type?
    @application.hmrc_check_type?
  end

  def ccmcc_evidence_rules_check
    position = check_position_index(@ccmcc.frequency, ccmcc_query)

    position_matching_frequency?(position, @ccmcc.frequency)
  end

  def ccmcc_query
    if @ccmcc.query_type == CCMCCEvidenceCheckRules::QUERY_ALL
      query = 'applications.id <= ? AND applications.office_id = ?'
      values = [@application.id, @application.office_id]
    else
      refund = @ccmcc.query_type == CCMCCEvidenceCheckRules::QUERY_REFUND
      query = 'applications.id <= ? AND applications.office_id = ? AND details.refund = ?'
      values = [@application.id, @application.office_id, refund]
    end

    Query::EvidenceCheckable.new.find_all.where([query, values].flatten).last(@ccmcc.frequency)
  end

  def ccmcc_evidence_rules?
    @ccmcc = CCMCCEvidenceCheckRules.new(@application)
    @ccmcc.rule_applies?
  end

  def low_income_check?
    @low_income = LowIncomeEvidenceCheckRules.new(@application)
    @low_income.rule_applies?
  end
end
