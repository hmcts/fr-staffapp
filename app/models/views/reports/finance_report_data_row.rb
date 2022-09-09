module Views
  module Reports
    class FinanceReportDataRow

      attr_accessor :office, :jurisdiction, :be_code, :sop_code, :total_count, :total_sum,
                    :full_count, :full_sum, :part_count, :part_sum, :benefit_count,
                    :benefit_sum, :income_count, :income_sum, :none_count, :none_sum

      def initialize(business_entity, date_from, date_to)
        @business_entity = business_entity
        @be_code = business_entity.be_code
        @sop_code = business_entity.sop_code
        @office = business_entity.office.name
        @jurisdiction = business_entity.jurisdiction.name
        @date_from = date_from
        @date_to = date_to
        build_columns
      end

      private

      def build_columns
        build_totals
        build_benefit_income
        build_full_part
      end

      def build_totals
        @total_count = applications.count
        @total_sum = applications.sum(:decision_cost)
      end

      def build_benefit_income
        build_sum_and_count(grouped_application_types)
      end

      def build_full_part
        build_sum_and_count(grouped_decisions)
      end

      def build_sum_and_count(collection)
        count_data = collection.count
        count_data.each do |type|
          try("#{type[0]}_count=", type[1])
        end

        sum_data = collection.sum(:decision_cost)
        sum_data.each do |type|
          try("#{type[0]}_sum=", type[1].to_fs('F'))
        end
      end

      def grouped_application_types
        applications.group(:application_type)
      end

      def grouped_decisions
        applications.group(:decision)
      end

      def applications
        Application.
          select(:decision).
          where(decision: ['part', 'full']).
          where(decision_date: @date_from..@date_to).
          where(business_entity_id: @business_entity.id).
          where(state: Application.states[:processed])
      end
    end
  end
end
