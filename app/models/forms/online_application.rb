module Forms
  class OnlineApplication < FormObject
    def self.permitted_attributes
      { fee: Integer,
        jurisdiction_id: Integer,
        date_received: Date,
        form_name: String,
        emergency: Boolean,
        emergency_reason: String }
    end

    define_attributes

    validates :fee, numericality: { allow_blank: true }, presence: true
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
      self.jurisdiction_id = user.jurisdiction_id
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
        form_name: form_name
      }
    end
  end
end
