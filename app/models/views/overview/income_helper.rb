module Views
  module Overview
    module IncomeHelper

      def income_result
        return if @application.application_type != "income"
        format_locale(['full', 'part'].include?(result).to_s)
      end

      def income_kind_applicant
        return if @application.income_kind.nil? || @application.income_kind[:applicant].blank?
        @application.income_kind[:applicant].join(', ')
      end

      def income_kind_partner
        return if @application.income_kind.nil? || @application.income_kind[:partner].blank?
        @application.income_kind[:partner].join(', ')
      end

      def income_period
        return if @application.income_period.nil?
        scope = 'activemodel.attributes.views/overview/application'
        I18n.t("income_period_#{@application.income_period}", scope: scope)
      end

    end
  end
end
