module Applications
  module Process
    class IncomesController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        if application.benefits?
          redirect_to application_summary_path(application)
        else
          @form = Forms::Application::Income.new(application)
          render :index
        end
      end

      def create
        @form = Forms::Application::Income.new(application)
        @form.update(form_params(:income))

        if @form.save
          IncomeCalculationRunner.new(application).run
          redirect_to path_to_next_page
        else
          render :index
        end
      end

      private

      def path_to_next_page
        if FeatureSwitching.subject_to_new_legislation?(received_and_refund_data)
          application_declaration_path(application)
        else
          application_summary_path(application)
        end
      end

      def received_and_refund_data
        detail = application.detail
        { date_received: detail.date_received, date_fee_paid: detail.date_fee_paid, refund: detail.refund }
      end
    end
  end
end
