class Applicant < ActiveRecord::Base
  belongs_to :application, optional: false

  include ApplicantCheckable

  before_validation :format_ni_number, :format_ho_number
  before_validation :remove_partner_info, if: :married_changed?

  validates :ni_number, format: {
    with: /\A(?!BG|GB|NK|KN|TN|NT|ZZ)[ABCEGHJ-PRSTW-Z][ABCEGHJ-NPRSTW-Z]\d{6}[A-D]\z/
  }, allow_blank: true

  def age
    @now = Time.zone.now.utc.to_date
    @now.year - date_of_birth.year - compare_months
  end

  def full_name
    [title, first_name, last_name].compact_blank.join(' ')
  end

  def partner_full_name
    [partner_first_name, partner_last_name].compact_blank.join(' ')
  end

  def over_66?
    received_minus_age = application.detail.date_received - 66.years
    received_minus_age >= date_of_birth
  end

  def under_age?
    age < 16
  end

  private

  def remove_partner_info
    return if married == true
    self.partner_date_of_birth = nil
    self.partner_first_name = nil
    self.partner_last_name = nil
    self.partner_ni_number = nil
  end

  def compare_months
    current_month_past_date_of_birth_month || current_day_past_date_of_birth_day ? 0 : 1
  end

  def current_month_past_date_of_birth_month
    @now.month > date_of_birth.month
  end

  def current_day_past_date_of_birth_day
    @now.month == date_of_birth.month && @now.day >= date_of_birth.day
  end

  def format_ni_number
    ni_number.delete!(' ') && ni_number.upcase! unless ni_number.nil?
  end

  def format_ho_number
    unless ho_number.nil?
      ho_number.upcase!
      ho_number.delete!(' ')
    end
  end

end
