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
        return unless @application.income
        "£#{@application.income.try(:round)}"
      end
      alias income_new income

      def income_period
        return unless @application.income
        scope = 'activemodel.attributes.forms/application/income'
        I18n.t(".income_period_#{@application.income_period}", scope: scope)
      end

      def income_kind_applicant
        translate_kinds(:applicant)
      end

      def income_kind_partner
        translate_kinds(:partner)
      end

      def translate_kinds(person)
        return if @application.income_kind.nil? || @application.income_kind[person].blank?

        @application.income_kind[person].map do |kind|
          I18n.t(kind, scope: ["activemodel.attributes.forms/application/income_kind_#{person}", 'kinds'])
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
