module Views
  module Overview
    class Details
      include ActionView::Helpers::NumberHelper

      delegate(:form_name, :case_number, :deceased_name, :emergency_reason, :calculation_scheme, :probate, to: :detail)

      def initialize(application)
        @application = application
      end

      def all_fields
        if show_ucd_changes?
          if @application.is_a?(OnlineApplication)
            online_application_fields
          else
            paper_application_fields
          end
        else
          pre_ucd_change_fields
        end
      end

      def skip_change_link
        ['refund_request', 'date_fee_paid']
      end

      def medium
        @application.is_a?(OnlineApplication) ? 'digital' : 'paper'
      end

      def fee
        number_to_currency(detail.fee, precision: 2, unit: '£')
      end

      def jurisdiction
        detail.jurisdiction.name
      end

      [:date_received, :date_of_death, :date_fee_paid].each do |method|
        define_method(method) do
          format_date(detail.public_send(method))
        end
      end

      def refund_request
        scope = 'activemodel.attributes.views/overview/details'
        I18n.t(".refund_request_#{detail.refund}", scope: scope)
      end

      def discretion_applied
        return if detail.discretion_applied.nil?
        scope = 'activemodel.attributes.forms/application/detail'
        I18n.t(".discretion_applied_#{detail.discretion_applied}", scope: scope)
      end

      def discretion_manager_name
        return if discretion_applied.blank?
        detail.try(:discretion_manager_name)
      end

      def discretion_reason
        return if discretion_applied.blank?
        detail.try(:discretion_reason)
      end

      private

      def detail
        @application.detail
      end

      def format_date(date)
        date&.to_fs(:gov_uk_long)
      end

      def pre_ucd_change_fields
        [
          'fee', 'jurisdiction', 'date_received', 'form_name', 'case_number', 'deceased_name', 'date_of_death',
          'refund_request', 'date_fee_paid', 'discretion_applied',
          'discretion_manager_name', 'discretion_reason', 'emergency_reason'
        ]
      end

      def show_ucd_changes?
        return FeatureSwitching.active?(:band_calculation) if detail.try(:calculation_scheme).blank?
        detail.try(:calculation_scheme) == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
      end

      def online_application_fields
        [
          'fee', 'jurisdiction', 'form_name', 'case_number',
          'discretion_applied', 'deceased_name', 'date_of_death', 'emergency_reason'
        ]
      end

      def paper_application_fields
        [
          'fee', 'jurisdiction', 'form_name', 'case_number',
          'deceased_name', 'date_of_death', 'emergency_reason'
        ]
      end

    end
  end
end
