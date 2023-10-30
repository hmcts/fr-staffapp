module Views
  module Overview
    class FeeStatus
      include ActionView::Helpers::NumberHelper

      def initialize(application)
        @application = application
      end

      def all_fields
        [
          'date_received', 'refund_request', 'date_fee_paid', 'discretion_applied',
          'discretion_manager_name', 'discretion_reason'
        ]
      end

      def skip_change_link
        ['refund_request', 'date_fee_paid'] if @application.is_a?(OnlineApplication)
      end

      [:date_received, :date_fee_paid].each do |method|
        define_method(method) do
          format_date(detail.public_send(method))
        end
      end

      def refund_request
        scope = 'activemodel.attributes.views/overview/fee_status'
        I18n.t(".refund_request_#{detail.refund}", scope: scope)
      end

      def discretion_applied
        return if @application.is_a?(OnlineApplication) || detail.discretion_applied.nil?
        scope = 'activemodel.attributes.forms/application/fee_status'
        I18n.t(".discretion_applied_#{detail.discretion_applied}", scope: scope)
      end

      def discretion_manager_name
        return if discretion_applied.blank?
        detail.discretion_manager_name
      end

      def discretion_reason
        return if discretion_applied.blank?
        detail.discretion_reason
      end

      private

      def detail
        @application.detail
      end

      def format_date(date)
        date&.to_fs(:gov_uk_long)
      end
    end
  end
end
