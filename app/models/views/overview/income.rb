module Views
  module Overview
    class Income < Views::Overview::Base

      def all_fields
        pre_ucd_change_fields
      end

      def initialize(application)
        @application = application
      end

      def children?
        convert_to_boolean(@application.dependents?)
      end

      def children
        @application.dependents? ? @application.children : 0
      end

      def income
        "£#{@application.income.try(:round)}"
      end
      alias income_new income

      def income_period
        scope = 'activemodel.attributes.forms/application/income'
        I18n.t(".income_period_#{@application.income_period}", scope: scope)
      end

      def income_kind_applicant
        return if @application.income_kind.nil? || @application.income_kind[:applicant].blank?
        scope = 'activemodel.attributes.forms/application/income_kind_applicant'
        @application.income_kind[:applicant].map do |kind|
          I18n.t(kind, scope: [scope, 'kinds'])
        end.join(', ')
      end

      def income_kind_partner
        return if @application.income_kind.nil? || @application.income_kind[:partner].blank?
        scope = 'activemodel.attributes.forms/application/income_kind_partner'
        @application.income_kind[:partner].map do |kind|
          I18n.t(kind, scope: [scope, 'kinds'])
        end.join(', ')
      end

      private

      def pre_ucd_change_fields
        ['children?', 'children', 'income']
      end

      def detail
        @application.detail
      end

      def show_ucd_changes?
        return FeatureSwitching.active?(:band_calculation) if detail.try(:calculation_scheme).blank?
        detail.try(:calculation_scheme) == FeatureSwitching::CALCULATION_SCHEMAS[1].to_s
      end

    end
  end
end
