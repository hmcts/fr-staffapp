# rubocop:disable Metrics/ClassLength
module Views
  module Confirmation
    class Result < Views::Overview::Base

      def all_fields
        ['discretion_applied?', 'savings_passed?', 'benefits_passed?', 'income_passed?']
      end

      def initialize(application)
        @application = application
      end

      def savings_passed?
        passed = @application.saving.passed
        return nil if passed.nil?
        if decision_overridden? && passed == false
          return I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        end
        return nil if @application.detail.discretion_applied == false
        convert_to_pass_fail(@application.saving.passed?) if @application.saving
      end

      def allow_override?
        return false if @application.saving.passed == false && @application.online_application_id.blank?
        true
      end

      def benefits_passed?
        if decision_overridden? && @application.benefits
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        elsif benefits_have_been_overridden?
          convert_to_pass_fail(applicant_is_on_benefits)
        elsif !benefit_overridden?
          paper_or_standard?
        end
      end

      def income_passed?
        return unless application_type_is?('income')
        path = 'activemodel.attributes.views/confirmation/result'

        return I18n.t('income_evidence', scope: path) if @application.waiting_for_evidence?

        return I18n.t('income_part', scope: path) if @application.waiting_for_part_payment?

        if decision_overridden? && income_over_limit?
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        else
          convert_to_pass_fail(['full', 'part'].include?(outcome).to_s)
        end
      end

      def discretion_applied?
        discretion_value = @application.detail.discretion_applied
        return false if discretion_value.nil?

        if decision_overridden?
          I18n.t('activemodel.attributes.forms/application/summary.passed_by_override')
        else
          convert_to_pass_fail(@application.detail.discretion_applied)
        end
      end

      def decision_overridden?
        @application.decision_override.present? && @application.decision_override.id
      end

      def amount_to_pay
        if @application.evidence_check && !@application.waiting_for_evidence?
          @application.evidence_check.amount_to_pay
        else
          @application.amount_to_pay
        end
      end

      def result
        return 'granted' if decision_overridden?
        return 'callout' if @application.waiting_for_evidence?
        return 'full' if return_full?
        return 'none' if @application.outcome.nil?
        ['full', 'part', 'none'].include?(outcome) ? outcome : 'error'
      end

      def outcome
        if @application.evidence_check && !@application.waiting_for_evidence?
          @application.evidence_check.outcome
        else
          @application.outcome
        end
      end

      def expires_at
        if @application.waiting_for_part_payment?
          @application.part_payment.expires_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
        elsif @application.evidence_check && @application.processed?
          @application.evidence_check.expires_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
        else
          @application.payment_expires_at.try(:strftime, Date::DATE_FORMATS[:gov_uk_long])
        end
      end

      def income
        return @application.evidence_check.income if @application.evidence_check.try(:income).try(:positive?)
        @application.income
      end

      private

      def convert_to_pass_fail(input)
        I18n.t(input.to_s, scope: 'convert_pass_fail')
      end

      def return_full?
        !benefit_overridden? && benefit_overide_correct?
      end

      def applicant_is_on_benefits
        result = false
        if @application.benefits? && @application.last_benefit_check.present?
          result = @application.last_benefit_check.dwp_result.eql?('Yes')
        end
        result.to_s
      end

      def benefit_overide_correct?
        @application.benefit_override.correct.eql?(true)
      end

      def benefit_overridden?
        @application.benefit_override.nil?
      end

      def application_type_is?(input)
        @application.application_type.eql?(input)
      end

      def paper_or_standard?
        if benefit_overide_correct?
          I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence')
        else
          I18n.t('activemodel.attributes.forms/application/summary.failed_with_evidence')
        end
      end

      def benefits_have_been_overridden?
        application_type_is?('benefit') && benefit_overridden?
      end

      def income_over_limit?
        @application.income_max_threshold_exceeded == true
      end

    end
  end
end
# rubocop:enable Metrics/ClassLength
