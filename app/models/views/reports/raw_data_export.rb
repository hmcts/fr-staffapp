# rubocop:disable Metrics/ClassLength
module Views
  module Reports
    class RawDataExport < ReportBase

      FIELDS = {
        id: 'id',
        name: 'office',
        reference: 'reference',
        jurisdiction: 'jurisdiction',
        sop_code: 'SOP code',
        fee: 'fee',
        estimated_amount_to_pay: 'estimated applicant pay',
        estimated_cost: 'estimated cost',
        form_type: 'form type',
        claim_type: 'claim type',
        form_name: 'form name',
        application_type: 'application type',
        probate: 'probate',
        refund: 'refund',
        emergency: 'emergency',
        income: 'income',
        income_threshold: 'income_threshold exceeded',
        income_period: 'income period',
        reg_number: 'ho/ni number',
        children: 'children',
        children_age_band_one: 'age band under 14',
        children_age_band_two: 'age band 14+',
        married: 'married',
        over_66: 'pension age',
        decision: 'decision',
        final_amount_to_pay: 'final applicant pays',
        decision_cost: 'departmental cost',
        source: 'source',
        granted: 'granted?',
        evidence_checked: 'evidence checked?',
        capital: 'capital band',
        savings_amount: 'savings and investments amount',
        part_payment_outcome: 'part payment outcome',
        case_number: 'case number',
        postcode: 'postcode',
        date_of_birth: 'date of birth',
        date_received: 'date received',
        date_fee_paid: 'date paid',
        date_submitted_online: 'date submitted online',
        statement_signed_by: 'statement signed by',
        partner_ni: 'partner ni entered',
        partner_name: 'partner name entered',
        calculation_scheme: 'HwF Scheme'
      }.freeze

      HEADERS = FIELDS.values
      ATTRIBUTES = FIELDS.keys

      def initialize(start_date, end_date)
        @date_from = format_dates(start_date)
        @date_to = format_dates(end_date).end_of_day

        @csv_file_name = "raw_data-#{start_date.values.join('-')}-#{end_date.values.join('-')}.csv"
        @zipfile_path = "tmp/#{@csv_file_name}.zip"
      end

      def to_csv
        CSV.generate do |csv|
          csv << HEADERS
          data.each do |row|
            csv << ATTRIBUTES.map do |attr|
              process_row(row, attr)
            end
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      def process_row(row, attr)
        if [:estimated_cost, :estimated_amount_to_pay, :reg_number, :income_threshold,
            :final_amount_to_pay].include?(attr)
          send(attr, row)
        elsif [:date_received, :date_fee_paid, :date_of_birth,
               :date_submitted_online].include?(attr)
          row.send(attr).to_fs(:default) if row.send(attr).present?
        elsif [:children_age_band_two, :children_age_band_one].include?(attr)
          children_age_band(row, attr)
        elsif attr == :over_66
          over_66?(row)
        else
          row.send(attr)
        end
      end
      # rubocop:enable Metrics/MethodLength

      def total_count
        data.size
      end

      def tidy_up
        FileUtils.rm_f(zipfile_path)
      end

      private

      def data
        @data ||= build_data
      end

      def build_data
        Application.
          select(simple_columns).
          select(named_columns).
          joins(joins).
          joins(:applicant, :business_entity, detail: :jurisdiction).
          where("offices.name NOT IN ('Digital')").
          where(decision_date: @date_from..@date_to, state: Application.states[:processed])
      end

      def simple_columns
        ['id', 'reference', 'children_age_band', 'details.fee',
         'CASE WHEN oa.form_name IS NOT NULL THEN oa.form_name ELSE details.form_name END AS form_name',
         'CASE WHEN oa.form_type IS NOT NULL THEN oa.form_type ELSE details.form_type END AS form_type',
         'CASE WHEN oa.claim_type IS NOT NULL THEN oa.claim_type ELSE details.claim_type END AS claim_type',
         'details.probate',
         'details.refund', 'details.statement_signed_by', 'application_type', 'income', 'income_period',
         'children', 'decision', 'amount_to_pay', 'decision_cost', 'applicants.married',
         'applicants.partner_ni_number', 'applicants.partner_last_name',
         'income_min_threshold_exceeded', 'income_max_threshold_exceeded']
      end

      def named_columns
        <<~COLUMNS
          offices.name AS name,
          details.emergency_reason IS NOT NULL AS emergency,
          jurisdictions.name AS jurisdiction,
          business_entities.sop_code AS sop_code,
          part_payments.outcome AS pp_outcome,
          CASE WHEN applications.reference LIKE 'HWF%' THEN 'digital' ELSE 'paper' END AS source,
          CASE WHEN de.id IS NULL THEN false ELSE true END AS granted,
          CASE WHEN ec.id IS NULL THEN false ELSE true END AS evidence_checked,
          CASE WHEN savings.max_threshold_exceeded = TRUE then 'High'
               WHEN savings.max_threshold_exceeded = FALSE AND savings.min_threshold_exceeded = TRUE THEN 'Medium'
               WHEN savings.max_threshold_exceeded = FALSE THEN 'Low'
               WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = FALSE THEN 'Low'
               WHEN savings.max_threshold_exceeded IS NULL AND savings.min_threshold_exceeded = TRUE THEN 'High'
               ELSE ''
          END AS capital,
          CASE WHEN part_payments.outcome = 'return' THEN 'return'
               WHEN part_payments.outcome = 'none' THEN 'false'
               WHEN part_payments.outcome = 'part' THEN 'true' ELSE NULL END AS part_payment_outcome,
          CASE WHEN savings.amount >= 16000 THEN NULL
               ELSE savings.amount
          END AS savings_amount,
          savings.over_66 AS over_66,
          details.case_number AS case_number,
          oa.postcode AS postcode,
          applicants.date_of_birth AS date_of_birth,
          details.date_received AS date_received,
          details.date_fee_paid AS date_fee_paid,
          oa.created_at AS date_submitted_online,
          details.statement_signed_by AS statement_signed_by,
          details.calculation_scheme AS calculation_scheme,
          CASE WHEN applicants.partner_ni_number IS NULL THEN 'false'
               WHEN applicants.partner_ni_number = '' THEN 'false'
               WHEN applicants.partner_ni_number IS NOT NULL THEN 'true'
               END AS partner_ni,
          CASE WHEN applicants.partner_last_name IS NULL THEN 'false'
               WHEN applicants.partner_last_name IS NOT NULL THEN 'true'
               END AS partner_name
        COLUMNS
      end

      def joins
        <<~JOINS
          LEFT JOIN offices ON offices.id = applications.office_id
          LEFT JOIN decision_overrides de ON de.application_id = applications.id
          LEFT JOIN evidence_checks ec ON ec.application_id = applications.id
          LEFT JOIN online_applications oa ON oa.id = applications.online_application_id
          LEFT JOIN savings ON savings.application_id = applications.id
          LEFT JOIN part_payments ON part_payments.application_id = applications.id
        JOINS
      end

      def estimated_cost(row)
        (row.fee - row.amount_to_pay.to_f) || 0
      end

      def estimated_amount_to_pay(row)
        row.amount_to_pay || 0
      end

      def final_amount_to_pay(row)
        return row.fee if row.try(:pp_outcome).present? && row.pp_outcome != 'part'
        ec_amount = row.evidence_check.try(:amount_to_pay)
        ec_amount || row.amount_to_pay
      end

      def reg_number(row)
        return 'NI number' if row.applicant.ni_number.present?
        return 'Home Office number' if row.applicant.ho_number.present?
        'None'
      end

      def income_threshold(row)
        return 'under' if row.income_min_threshold_exceeded
        'over' if row.income_max_threshold_exceeded
      end

      def over_66?(row)
        row.send(:over_66) == true ? 'Yes' : 'No'
      end

      def date_for_age_calculation(row)
        row.send(:date_submitted_online) || row.send(:date_received)
      end

      def children_age_band(row, attr_key)
        return nil if age_bands_blank?(row)

        if attr_key == :children_age_band_one
          row.children_age_band[:one] || row.children_age_band['one']
        elsif attr_key == :children_age_band_two
          row.children_age_band[:two] || row.children_age_band['two']
        end
      end

      def age_bands_blank?(row)
        return true if row.children_age_band.blank?

        row.children_age_band.keys.select do |key|
          key.to_s == 'one' || key.to_s == 'two'
        end.blank?
      end

    end
  end
end
# rubocop:enable Metrics/ClassLength
