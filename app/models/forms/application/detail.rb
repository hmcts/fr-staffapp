module Forms
  module Application
    class Detail < ::FormObject
      include ActiveModel::Validations::Callbacks
      include DataFieldFormattable
      include RefundValidatable

      ATTRIBUTE_TYPES = {
        fee: Decimal,
        jurisdiction_id: Integer,
        date_received: Date,
        day_date_received: Integer,
        month_date_received: Integer,
        year_date_received: Integer,
        probate: Boolean,
        date_of_death: Date,
        day_date_of_death: Integer,
        month_date_of_death: Integer,
        year_date_of_death: Integer,
        deceased_name: String,
        refund: Boolean,
        emergency: Boolean,
        emergency_reason: String,
        date_fee_paid: Date,
        day_date_fee_paid: Integer,
        month_date_fee_paid: Integer,
        year_date_fee_paid: Integer,
        form_type: String,
        claim_type: String,
        form_name: String,
        case_number: String,
        discretion_applied: Boolean,
        discretion_manager_name: String,
        discretion_reason: String,
        statement_signed_by: String
      }.freeze

      def self.permitted_attributes
        ATTRIBUTE_TYPES
      end

      define_attributes

      before_validation :format_date_fields
      after_validation :check_discretion
      after_validation :check_refund_values

      validates :fee, presence: true, numericality: { greater_than: 0, less_than: 20_000 }
      validates :jurisdiction_id, presence: true
      validate :reason
      validate :emergency_reason_size
      validates :discretion_manager_name, :discretion_reason, presence: true, if: -> { discretion_applied }

      validates :date_received, date: { before: :tomorrow }

      validates :form_type, inclusion: { in: :form_type_options }, allow_blank: true
      validate :claim_type_presence, if: -> { form_type == form_type_n1 }
      validate :form_name_presence, if: -> { form_type == form_type_other }
      validates :claim_type, inclusion: { in: :claim_type_options }, if: -> { form_type == form_type_n1 }
      validates :form_name, format: { with: /\A((?!EX160|COP44A).)*\z/i }, allow_nil: true

      with_options if: :probate? do
        validates :deceased_name, presence: true
        validates :date_of_death, date: { before: :tomorrow }
      end

      with_options if: :validate_date_fee_paid? do
        validates :date_fee_paid,
                  date: { after_or_equal_to: :max_refund_date, before_or_equal_to: :date_received, allow_blank: false }
      end

      def format_date_fields
        [:date_received, :date_of_death, :date_fee_paid].each { |key| format_dates(key) if format_the_dates?(key) }
      end

      private

      def min_date
        3.months.ago.midnight
      end

      def tomorrow
        Time.zone.tomorrow
      end

      def reason
        errors.add(:emergency_reason, :cant_have_emergency_reason_without_emergency) if emergency_without_reason?
        format_reason
      end

      def emergency_without_reason?
        emergency? && emergency_reason.blank?
      end

      def emergency_reason_present_and_too_long?
        emergency_reason.present? && emergency_reason.size > 500
      end

      def emergency_reason_size
        errors.add(:emergency_reason, :too_long) if emergency_reason_present_and_too_long?
      end

      def format_reason
        self.emergency_reason = nil if emergency_reason.blank?
      end

      def persist!
        @object.update(fields_to_update)
      end

      def fields_to_update
        excluded_keys = [:emergency, :day_date_received, :month_date_received, :year_date_received, :day_date_of_death,
                         :month_date_of_death, :year_date_of_death, :day_date_fee_paid,
                         :month_date_fee_paid, :year_date_fee_paid]
        (self.class.permitted_attributes.keys - excluded_keys).index_with do |name|
          send(name)
        end
      end

      def claim_type_presence
        errors.add(:claim_type, :blank) if claim_type.blank?
      end

      def form_name_presence
        errors.add(:form_name, :blank) if form_name.blank?
      end

      def form_type_options
        [
          I18n.t('activemodel.attributes.forms/application/detail.form_type_n1'),
          I18n.t('activemodel.attributes.forms/application/detail.form_type_other')
        ]
      end

      def claim_type_options
        [
          I18n.t('activemodel.attributes.forms/application/detail.claim_type_specified'),
          I18n.t('activemodel.attributes.forms/application/detail.claim_type_unspecified'),
          I18n.t('activemodel.attributes.forms/application/detail.claim_type_personal_injury')
        ]
      end

      def form_type_n1
        I18n.t('activemodel.attributes.forms/application/detail.form_type_n1')
      end

      def form_type_other
        I18n.t('activemodel.attributes.forms/application/detail.form_type_other')
      end
    end
  end
end
