module Views
  module Reports
    class OcmcDataExport
      require 'csv'
      include OcmcExportHelper

      def initialize(start_date, end_date, office_id)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day
        @office_id = office_id
      end

      def format_dates(date_attribute)
        DateTime.parse(date_attribute.values.join('/')).utc
      end

      def to_csv
        return "no resutls" unless data.first
        CSV.generate do |csv|
          csv << data.first.keys
          data.each do |row|
            csv << process_row(row).values
          end
        end
      end

      private

      def process_row(row)
        csv_row = row
        csv_row['Age band under 14'] = children_age_band(row['Age band under 14'], :children_age_band_one)
        csv_row['Age band 14+'] = children_age_band(row['Age band 14+'], :children_age_band_two)
        csv_row
      end

      # rubocop:disable Metrics/MethodLength
      def sql_query
        "SELECT
        offices.name AS \"Office\",
        applications.reference as \"HwF reference number\",
        details.fee as \"Fee\",
        applications.application_type as \"Application type\",
        CASE WHEN oa.form_type IS NOT NULL THEN oa.form_type ELSE details.form_type END as \"Form Type\",
        CASE WHEN oa.claim_type IS NOT NULL THEN oa.claim_type ELSE details.claim_type END as \"Claim Type\",
        CASE WHEN oa.form_name IS NOT NULL THEN oa.form_name ELSE details.form_name END as \"Form Name\",
        details.refund as \"Refund\",
        applications.income as \"Income\",
        applications.income_period as \"Income period\",
        applications.children as \"Children\",
        applications.children_age_band as \"Age band under 14\",
        applications.children_age_band as \"Age band 14+\",
        CASE WHEN applicants.married = TRUE THEN 'yes' ELSE 'no' END as \"Married\",
        applications.decision as \"Decision\",
        applications.amount_to_pay as \"Applicant pays estimate\",
        CASE WHEN ec.id IS NULL THEN applications.amount_to_pay ELSE ec.amount_to_pay END as \"Applicant pays\",
        details.fee - applications.amount_to_pay as \"Departmental cost estimate\",
        CASE WHEN ec.id IS NULL THEN details.fee - applications.amount_to_pay ELSE details.fee - ec.amount_to_pay
          END as \"Departmental cost\",
        CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS \"Source\",
        CASE WHEN de.id IS NULL THEN 'no' ELSE 'yes' END AS \"Granted?\",
        CASE WHEN ec.id IS NULL THEN 'no' ELSE 'yes' END AS \"Evidence checked?\",
        CASE WHEN savings.max_threshold_exceeded = TRUE then 'High'
             WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN 'Medium'
             WHEN savings.max_threshold_exceeded = FALSE THEN 'Low'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN 'Low'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN 'High'
             ELSE ''
        END AS \"Capital Band\",
        savings.amount AS \"Saving and Investments\",
        details.case_number AS \"Case number\",
        details.date_received as \"Date received\",
        details.statement_signed_by as \"Statement signed by\",
        CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
             WHEN applicants.partner_ni_number = '' THEN 'false'
             WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
             END AS \"Partner NI entered\",
        CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
             WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
             END AS \"Partner name entered\",
        details.calculation_scheme as \"HwF Scheme\"
        FROM \"applications\" LEFT JOIN offices ON offices.id = applications.office_id
        LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
        LEFT JOIN savings ON savings.application_id = applications.id
        LEFT JOIN decision_overrides de ON de.application_id = applications.id
        LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
        INNER JOIN \"applicants\" ON \"applicants\".\"application_id\" = \"applications\".\"id\"
        INNER JOIN \"details\" ON \"details\".\"application_id\" = \"applications\".\"id\"
        WHERE applications.office_id = #{@office_id}
        AND applications.created_at between '#{@date_from.to_fs(:db)}' AND '#{@date_to.to_fs(:db)}'
        AND applications.state != 0 ORDER BY applications.created_at DESC;"
      end
      # rubocop:enable Metrics/MethodLength

    end
  end
end
