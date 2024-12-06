module Applications
  module Process
    class SavingsInvestmentsController < Applications::ProcessController
      before_action :authorize_application_update

      def index
        @form = Forms::Application::SavingsInvestment.new(application.saving)
      end

      def create
        @form = Forms::Application::SavingsInvestment.new(application.saving)
        @form.update(form_params(:savings_investments))

        if @form.save
          redirect_to next_page_to_go
        else
          render :index
        end
      end

      private

      def saving_failed
        band = BandBaseCalculation.new(application)

        application.saving.update(passed: band.saving_passed?)
        return false if band.saving_passed?
        application.update(outcome: band.remission, application_type: 'income', amount_to_pay: application.detail.fee,
                           income: nil)

        true
      end

      def next_page_to_go
        if ucd_changes_apply? && saving_failed
          application_declaration_path(application)
        else
          SavingsPassFailService.new(application.saving).calculate!
          application_benefits_path(application)
        end
      end

    end
  end
end
