module Forms
  class OnlineApplication < FormObject
    include ActiveModel::Validations::Callbacks
    include DataFieldFormattable

    # rubocop:disable Metrics/MethodLength
    def self.permitted_attributes
      { fee: Decimal,
        jurisdiction_id: Integer,
        date_received: Date,
        day_date_received: Integer,
        month_date_received: Integer,
        year_date_received: Integer,
        form_name: String,
        emergency: Boolean,
        emergency_reason: String,
        benefits_override: Boolean,
        user_id: Integer }
    end
    # rubocop:enable Metrics/MethodLength

    define_attributes

    before_validation :format_date_fields, :format_fee

    validates :fee, presence: true,
                    numericality: { allow_blank: true, less_than: 20_000 }
    validates :fee, presence: true,
                    numericality: { allow_blank: true, greater_than: 0 }
    validates :jurisdiction_id, presence: true
    validates :emergency_reason, presence: true, if: :emergency?
    validates :emergency_reason, length: { maximum: 500 }

    validates :date_received, date: {
      after_or_equal_to: :min_date,
      before: :tomorrow
    }

    validates :form_name, format: { with: /\A((?!EX160|COP44A).)*\z/i }, allow_nil: true
    validates :form_name, presence: true

    def initialize(online_application)
      super(online_application)
      self.emergency = true if emergency_reason.present?
    end

    def enable_default_jurisdiction(user)
      return if jurisdiction_id.present?
      self.jurisdiction_id = user.jurisdiction_id
    end

    def format_date_fields
      format_dates(:date_received) if format_the_dates?(:date_received)
    end

    private

    def min_date
      3.months.ago.midnight
    end

    def tomorrow
      Time.zone.tomorrow
    end

    def persist!
      @object.update(fields_to_update)
    end

    def fields_to_update
      fixed_fields.tap do |fields|
        fields[:emergency_reason] = (emergency ? emergency_reason : nil)
      end
    end

    def fixed_fields
      {
        fee: fee,
        jurisdiction_id: jurisdiction_id,
        date_received: date_received,
        form_name: form_name,
        benefits_override: benefits_override,
        user_id: user_id
      }
    end

    def format_fee
      @fee = fee.strip.to_f if fee.is_a?(String) && fee.strip.to_f.positive?
    end
  end
end
