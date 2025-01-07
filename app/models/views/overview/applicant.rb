module Views
  module Overview
    class Applicant

      delegate(:full_name, :partner_full_name, :ho_number, :married, to: :applicant)

      def initialize(application)
        @application = application
      end

      def all_fields
        ['full_name', 'date_of_birth', 'under_age', 'ni_number', 'ho_number', 'status',
         'partner_full_name', 'partner_date_of_birth', 'partner_ni_number']
      end

      def ni_number
        applicant.ni_number&.gsub(/(.{2})/, '\1 ')
      end

      def partner_ni_number
        applicant.partner_ni_number&.gsub(/(.{2})/, '\1 ')
      end

      def status
        locale_scope = 'activemodel.attributes.forms/application/applicant'
        I18n.t("married_#{applicant.married?}", scope: locale_scope)
      end

      def date_of_birth
        format_date applicant.date_of_birth
      end

      def partner_date_of_birth
        format_date applicant.partner_date_of_birth
      end

      def under_age
        return if applicant.under_age?.nil?
        locale_scope = 'activemodel.attributes.forms/application/applicant'

        if applicant.under_age?
          I18n.t("over_16_false", scope: locale_scope)
        else
          I18n.t("over_16_true", scope: locale_scope)
        end
      end

      private

      def applicant
        @application.applicant
      end

      def format_date(date)
        date&.to_fs(:gov_uk_long)
      end
    end
  end
end
