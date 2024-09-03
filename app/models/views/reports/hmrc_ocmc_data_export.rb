# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class HmrcOcmcDataExport
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
        return "no results" unless data.first
        CSV.generate do |csv|
          csv << (data.first.keys - ['tax_credit'])
          data.each do |row|
            csv << process_row(row).values
          end
        end
      end

      private

      # rubocop:disable Metrics/MethodLength
      def sql_query
        "SELECT
        offices.name AS \"Office\",
        applications.reference as \"HwF reference number\",
        applications.created_at as \"Created at\",
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
        CASE WHEN ec.id IS NULL THEN applications.amount_to_pay ELSE ec.amount_to_pay END as \"Applicant pays\",
        details.fee - applications.amount_to_pay as \"Departmental cost estimate\",
        CASE WHEN ec.id IS NULL THEN details.fee - applications.amount_to_pay ELSE details.fee - ec.amount_to_pay
          END as \"Departmental cost\",
        CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS \"Source\",
        CASE WHEN de.id IS NULL THEN 'no' ELSE 'yes' END AS \"Granted?\",
        CASE WHEN ec.id IS NULL THEN 'no' ELSE 'yes' END AS \"Evidence checked?\",
        CASE WHEN savings.max_threshold_exceeded = TRUE then '16,000 or more'
             WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN '3,000 - 15,999'
             WHEN savings.max_threshold_exceeded = FALSE THEN '0 - 2,999'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN '0 - 2,999'
             WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN '3000 or more'
             ELSE ''
        END AS \"Capital\",
        savings.amount AS \"Saving and Investments\",
        details.case_number AS \"Case number\",
        details.date_received as \"Date received\",
        CASE WHEN applicants.married = TRUE THEN 'yes' ELSE 'no' END as \"Married\",
        applications.decision as \"Decision\",
        applications.amount_to_pay as \"Applicant pays estimate\",
        applications.income_kind as \"Declared income sources\",
        ec.check_type as \"DB evidence check type\",
        ec.income_check_type as \"DB income check type\",
        CASE WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'paper' AND hc_id IS NULL then 'Manual NIDuplicate'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'hmrc' then 'HMRC NumberRule'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'hmrc' then 'HMRC NIFlag'
         WHEN ec.check_type = 'ni_exist' AND ec.income_check_type = 'hmrc' then 'HMRC NIDuplicate'
         WHEN ec.check_type = 'flag' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
         WHEN ec.check_type = 'random' AND ec.income_check_type = 'paper' AND hc_id IS NOT NULL then 'ManualAfterHMRC'
           ELSE ''
        END AS \"Evidence check type\",
        CASE WHEN hc_id IS NULL then ''
           WHEN hc_id IS NOT NULL AND error_response IS NULL then 'Yes'
           WHEN hc_id IS NOT NULL AND error_response IS NOT NULL then 'No'
           ELSE ''
        END AS \"HMRC response?\",
        error_response as \"HMRC errors\",
        CASE WHEN hc_id IS NULL then ''
           WHEN hc_id IS NOT NULL AND ec.completed_at IS NOT NULL then 'Yes'
           WHEN hc_id IS NOT NULL AND ec.completed_at IS NULL then 'No'
           ELSE ''
        END AS \"Complete processing?\",
        CASE WHEN hc_income IS NULL then ''
           WHEN hc_income IS NOT NULL then hc_income
           ELSE ''
        END as \"HMRC total income\",
        CASE WHEN additional_income IS NULL then NULL
           WHEN additional_income IS NOT NULL AND ec.income_check_type = 'paper' then NULL
           WHEN additional_income IS NOT NULL AND ec.income_check_type = 'hmrc'
            AND additional_income > 0 then additional_income
           ELSE NULL
        END as \"Additional income\",
        CASE WHEN hc_id IS NULL then NULL
           WHEN ec.income_check_type = 'paper' AND ec.completed_at IS NOT NULL then NULL
           WHEN ec.income_check_type = 'hmrc' AND ec.completed_at IS NOT NULL then ec.income
           ELSE NULL
        END as \"Income processed\",
        request_params as \"HMRC request date range\",
        tax_credit,
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
        LEFT JOIN (
         SELECT id as \"hc_id\", income as \"hc_income\", request_params, tax_credit, additional_income,
            error_response, evidence_check_id, created_at, row_number() over
            (partition by evidence_check_id order by created_at desc)
            as row_number from hmrc_checks) hc ON ec.id = hc.evidence_check_id
        LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
        INNER JOIN \"applicants\" ON \"applicants\".\"application_id\" = \"applications\".\"id\"
        INNER JOIN \"details\" ON \"details\".\"application_id\" = \"applications\".\"id\"
        WHERE applications.office_id = #{@office_id}
        AND applications.created_at between '#{@date_from.to_fs(:db)}' AND '#{@date_to.to_fs(:db)}'
        AND (row_number = 1 OR row_number IS NULL)
        AND applications.state != 0 ORDER BY applications.created_at DESC;"
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize
      def process_row(row)
        csv_row = row
        csv_row['Created at'] = csv_row['Created at'].to_fs(:db)
        csv_row['Declared income sources'] = income_kind(row['Declared income sources'])
        csv_row['HMRC total income'] = hmrc_total_income(row)
        csv_row['HMRC request date range'] = hmrc_date_range(row['HMRC request date range'])
        csv_row['Age band under 14'] = children_age_band(row['Age band under 14'], :children_age_band_one)
        csv_row['Age band 14+'] = children_age_band(row['Age band 14+'], :children_age_band_two)
        csv_row['tax_credit'] = ''
        csv_row
      end
      # rubocop:enable Metrics/AbcSize

      def income_kind(value)
        return unless value
        income_kind_hash = YAML.parse(value).to_ruby
        return if income_kind_hash.blank?
        applicant = income_kind_hash[:applicant].join(',')
        partner = income_kind_hash[:partner].try(:join, ',')
        [applicant, partner].compact_blank.join(", ")
      rescue TypeError
        ""
      end

      def hmrc_total_income(row)
        paye = hmrc_income(row['HMRC total income'])
        tax_credits = tax_credit(row['tax_credit'], row['HMRC request date range'])
        total = paye + tax_credits
        total.positive? ? total : ''
      end

      def hmrc_income(value)
        return 0 if value.blank?
        income_hash = YAML.parse(value).to_ruby
        HmrcIncomeParser.paye(income_hash)
      end

      def tax_credit(value, date_range)
        return 0 if value.blank?
        date = date_formatted(date_range)
        tax_credit_hash = YAML.parse(value).to_ruby
        work = HmrcIncomeParser.tax_credit(tax_credit_hash.try(:[], :work), date)
        child = HmrcIncomeParser.tax_credit(tax_credit_hash.try(:[], :child), date)
        work + child
      end

      def date_formatted(date_range)
        return nil if date_range.blank?
        request_params_hash = YAML.parse(date_range).to_ruby
        request_params_hash[:date_range]
      end

      def hmrc_date_range(date_range)
        return unless date_formatted(date_range)
        from = date_formatted(date_range)[:from]
        to = date_formatted(date_range)[:to]
        "#{from} - #{to}"
      end

    end
  end
end
# rubocop:enable Metrics/ClassLength
