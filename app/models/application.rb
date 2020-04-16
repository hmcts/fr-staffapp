class Application < ActiveRecord::Base
  include PgSearch::Model

  self.per_page = 25

  pg_search_scope :extended_search, against: [:reference], associated_against: {
    detail: [:case_number],
    applicant: [:ni_number]
  }

  pg_search_scope :name_search, associated_against: {
    applicant: [:first_name, :last_name]
  }

  has_paper_trail

  belongs_to :user, -> { with_deleted }
  belongs_to :completed_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :deleted_by, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :office, optional: true
  belongs_to :business_entity, optional: true
  belongs_to :online_application, optional: true
  has_many :benefit_checks, dependent: :destroy
  has_one :applicant, dependent: :destroy
  has_one :detail, inverse_of: :application, dependent: :destroy
  has_one :saving, inverse_of: :application, dependent: :destroy
  has_one :evidence_check, required: false, dependent: :destroy
  has_one :part_payment, required: false, dependent: :destroy
  has_one :benefit_override, required: false, dependent: :destroy
  has_one :decision_override, required: false, dependent: :destroy

  scope :with_evidence_check_for_ni_number, (lambda do |ni_number|
    Application.where(state: states[:waiting_for_evidence]).
      joins(:evidence_check).
      joins(:applicant).where('applicants.ni_number = ?', ni_number)
  end)

  scope :with_evidence_check_for_ho_number, (lambda do |ho_number|
    Application.where(state: states[:waiting_for_evidence]).
      joins(:evidence_check).
      joins(:applicant).where('applicants.ho_number = ?', ho_number)
  end)

  scope :except_created, -> { where.not(state: 0) }
  scope :given_office_only, lambda { |office_id|
    where(office_id: office_id)
  }

  enum state: {
    created: 0,
    waiting_for_evidence: 1,
    waiting_for_part_payment: 2,
    processed: 3,
    deleted: 4
  }

  validates :reference, uniqueness: true, allow_blank: true

  def last_benefit_check
    benefit_checks.where.not(benefits_valid: nil, dwp_result: nil).order(:id).last
  end

  def self.sort_received(sort_string)
    return 'details.date_received asc' if sort_string == 'received_asc'
    'details.date_received desc'
  end

  def self.sort_processed(sort_string)
    return 'completed_at asc' if sort_string == 'processed_asc'
    'completed_at desc'
  end

  def self.sort_fee(sort_string)
    return 'details.fee asc' if sort_string == 'fee_asc'
    'details.fee desc'
  end
end
