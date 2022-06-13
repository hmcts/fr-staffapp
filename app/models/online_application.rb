class OnlineApplication < ActiveRecord::Base
  serialize :income_kind

  belongs_to :jurisdiction, optional: true
  has_many :online_benefit_checks, dependent: :destroy

  validates :date_of_birth, :first_name, :last_name, :address,
            :postcode, presence: true
  validates :married, :min_threshold_exceeded, :benefits, :refund, :email_contact,
            :phone_contact, :post_contact, :feedback_opt_in, inclusion: [true, false]
  validates :reference, uniqueness: true

  validates :ni_number, presence: true, if: ->(app) { app.ho_number.blank? }

  def full_name
    [title, first_name, last_name].compact.join(' ')
  end

  def applicant
    Applicant.new(online_applicant_attributes)
  end

  # FIXME: This is here temporarily until we can refactor view models
  def detail
    self
  end

  def processed?
    linked_application.present? && !linked_application.created?
  end

  def linked_application
    Application.find_by(online_application: self)
  end

  def last_benefit_check
    online_benefit_checks.where.not(benefits_valid: nil).where.not(dwp_result: nil).order(:id).last
  end

  def failed_because_dwp_error?
    return false if last_benefit_check.blank?
    bad_request? || benefit_check_unavailable?
  end

  def bad_request?
    last_benefit_check.dwp_result == 'BadRequest' &&
      last_benefit_check.error_message.include?('LSCBC959: Service unavailable')
  end

  def benefit_check_unavailable?
    return false if last_benefit_check.error_message.blank?
    last_benefit_check.dwp_result == 'Server unavailable' &&
      last_benefit_check.error_message.include?('The benefits checker is not available at the moment')
  end

  private

  def online_applicant_attributes
    fields = [:title, :first_name, :last_name, :date_of_birth, :ni_number, :ho_number, :married]
    fields.index_with { |field| send(field) }.to_h
  end

end
