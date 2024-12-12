module Views
  module Overview
    class OnlineApplicationView
      include ActionView::Helpers::NumberHelper
      include IncomePeriodHelper
      include OnlineSaving

      delegate :married, :form_name, :case_number, :probate, :deceased_name, :emergency_reason,
               :amount, :over_66, :benefits, :children, :legal_representative,
               :legal_representative_organisation_name, :email_address, to: :@online_application

      def initialize(online_application)
        @online_application = online_application
      end

      def date_received
        format_date(@online_application.date_received)
      end

      def refund_request
        @online_application.refund? ? 'Yes' : 'No'
      end

      def date_fee_paid
        format_date(@online_application.date_fee_paid)
      end

      def partner_full_name
        [@online_application.partner_first_name, @online_application.partner_last_name].compact_blank.join(' ')
      end

      def full_name
        [@online_application.first_name, @online_application.last_name].compact_blank.join(' ')
      end

      def ni_number
        @online_application.ni_number&.gsub(/(.{2})/, '\1 ')
      end

      def ho_number
        @online_application.ho_number
      end

      def partner_ni_number
        @online_application.partner_ni_number&.gsub(/(.{2})/, '\1 ')
      end

      def status
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        I18n.t("married_#{@online_application.married?}", scope: locale_scope)
      end

      def date_of_birth
        format_date @online_application.date_of_birth
      end

      def partner_date_of_birth
        # temporary fix for dob from partner - should be nil
        return nil if @online_application.partner_first_name.nil?
        format_date @online_application.partner_date_of_birth
      end

      def under_age
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        if @online_application.over_16
          I18n.t("over_16_true", scope: locale_scope)
        else
          I18n.t("over_16_false", scope: locale_scope)
        end
      end

      def fee
        number_to_currency(@online_application.fee, precision: 2, unit: '£')
      end

      def jurisdiction
        @online_application.jurisdiction.name
      end

      def date_of_death
        format_date @online_application.date_of_death
      end

      def saving_amount_total
        number_to_currency(@online_application.amount, precision: 2, unit: '£')
      end

      def on_benefits?
        @online_application.benefits ? 'Yes' : 'No'
      end

      def children?
        @online_application.children ? 'Yes' : 'No'
      end

      def children_age_band
        return nil if @online_application.children_age_band.blank?
        one = age_band_value(1)
        two = age_band_value(2)
        return nil if one.zero? && two.zero?
        # rubocop:disable Rails/OutputSafety
        "#{one} (aged 0-13) <br />
           #{two} (aged 14+)".html_safe
        # rubocop:enable Rails/OutputSafety
      end

      def income
        number_to_currency(@online_application.income, precision: 2, unit: '£')
      end

      def income_kind_applicant
        return if @online_application.income_kind.nil? || @online_application.income_kind[:applicant].blank?
        @online_application.income_kind[:applicant].join(', ')
      end

      def income_kind_partner
        return if @online_application.income_kind.nil? || @online_application.income_kind[:partner].blank?
        @online_application.income_kind[:partner].join(', ')
      end

      def statement_signed_by
        return '' if @online_application.statement_signed_by.blank?
        scope = 'activemodel.attributes.views/overview/declaration'
        I18n.t(".#{@online_application.statement_signed_by}", scope: scope)
      end

      def representative_full_name
        [@online_application.legal_representative_first_name,
         @online_application.legal_representative_last_name].compact_blank.join(' ')
      end

      private

      def format_date(date)
        date&.to_fs(:gov_uk_long)
      end

      def age_band_value(band_name)
        band = @online_application.children_age_band

        case band_name
        when 1
          (band[:one] || band['one'] || 0).to_i
        when 2
          (band[:two] || band['two'] || 0).to_i
        end
      end

    end
  end
end
