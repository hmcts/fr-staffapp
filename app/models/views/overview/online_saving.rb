module Views
  module Overview
    module OnlineSaving
      def saving_over_66
        @online_application.over_66 ? 'Yes' : 'No'
      end

      def less_then
        return 'Yes' if @online_application.min_threshold_exceeded == false
        'No'
      end

      def between
        return 'Yes' if @online_application.min_threshold_exceeded == true &&
                        @online_application.max_threshold_exceeded == false
        'No'
      end

      def more_then
        return 'Yes' if @online_application.min_threshold_exceeded == true &&
                        @online_application.max_threshold_exceeded == true
        'No'
      end
    end
  end
end
