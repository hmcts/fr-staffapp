class BenefitCheck < ActiveRecord::Base
  belongs_to :applicationable, polymorphic: true

  include CommonScopes

  scope :by_office, lambda { |office_id|
    joins(:application).
      where(applications: { office_id: office_id })
  }

  scope :non_digital, lambda {
    joins(:application).joins('LEFT JOIN offices ON applications.office_id = offices.id').
      where.not(offices: { name: 'Digital' })
  }

  scope :by_office_grouped_by_type, lambda { |office_id|
    joins(:application).
      where(applications: { office_id: office_id }).
      group(:dwp_result).
      order(Arel.sql('length(dwp_result)'))
  }

  def outcome
    dwp_result == 'Yes' ? 'full' : 'none'
  end

  def dwp_error?
    bad_request? || benefit_check_unavailable?
  end

  def bad_request?
    dwp_result == 'BadRequest' &&
      (error_message.include?('LSCBC') || error_message.include?('Service unavailable'))
  end

  def benefit_check_unavailable?
    return false if error_message.blank?
    dwp_result == 'Server unavailable' &&
      error_message.include?('The benefits checker is not available at the moment')
  end
end
