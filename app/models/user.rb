class User < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :office
  belongs_to :jurisdiction

  ROLES = %w[user manager admin]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable, :rememberable and :omniauthable
  devise :database_authenticatable,
    :recoverable,
    :trackable,
    :validatable,
    :invitable

  scope :sorted_by_email, -> {  all.order(:email) }

  scope :by_office, ->(office_id) { where('office_id = ?', office_id) }

  email_regex = /\A([^@\s]+)@(hmcts\.gsi|digital\.justice)\.gov\.uk\z/i
  validates :role, :name, presence: true
  validates :email, format: {
    with: email_regex,
    on: [:create, :update],
    allow_nil: true,
    message: I18n.t('dictionary.invalid_email', email: Settings.mail_tech_support)
  }
  validates :role, inclusion: {
    in: ROLES,
    message: "%{value} is not a valid role",
    allow_nil: true
  }
  validate :jurisdiction_is_valid

  def elevated?
    admin? || manager?
  end

  def admin?
    role == 'admin'
  end

  def manager?
    role == 'manager'
  end

  private

  def jurisdiction_is_valid
    unless jurisdiction_id.nil? || Jurisdiction.exists?(jurisdiction_id)
      errors.add(:jurisdiction, 'Jurisdiction must exist')
    end
  end
end
