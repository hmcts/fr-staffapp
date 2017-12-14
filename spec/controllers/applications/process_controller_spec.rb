require 'rails_helper'

RSpec.describe Applications::ProcessController, type: :controller do
  let(:user)          { create :user }
  let(:application) { build_stubbed(:application, office: user.office) }
  let(:benefit_form) { instance_double('Forms::Application::Benefit') }
  let(:income_form) { instance_double('Forms::Application::Income') }
  let(:income_calculation_runner) { instance_double(IncomeCalculationRunner, run: nil) }
  let(:dwp_monitor) { instance_double('DwpMonitor') }
  let(:dwp_state) { 'online' }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::Benefit).to receive(:new).with(application).and_return(benefit_form)
    allow(Forms::Application::Income).to receive(:new).with(application).and_return(income_form)
    allow(IncomeCalculationRunner).to receive(:new).with(application).and_return(income_calculation_runner)
    allow(dwp_monitor).to receive(:state).and_return(dwp_state)
    allow(DwpMonitor).to receive(:new).and_return(dwp_monitor)
  end

  describe 'POST create' do
    let(:builder) { instance_double(ApplicationBuilder, build: application) }

    before do
      allow(ApplicationBuilder).to receive(:new).with(user).and_return(builder)
      allow(application).to receive(:save)

      post :create
    end

    it 'creates a new application' do
      expect(application).to have_received(:save)
    end

    it 'redirects to the personal information page for that application' do
      expect(response).to redirect_to(application_personal_informations_path(application))
    end
  end

  describe 'GET #benefits' do
    let(:saving) { double }

    before do
      allow(application).to receive(:saving).and_return(saving)
      allow(saving).to receive(:passed?).and_return(savings_valid)

      get :benefits, application_id: application.id
    end

    context 'when application failed savings and investments' do
      let(:savings_valid) { false }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when savings and investments passed' do
      let(:savings_valid) { true }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:benefits)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end

      describe '@status' do
        subject { assigns(:state) }

        context 'when the dwp is up' do
          it { is_expected.to eql(dwp_state) }
        end

        context 'when the dwp is down' do
          let(:dwp_state) { 'offline' }

          it { is_expected.to eql(dwp_state) }
        end
      end
    end
  end

  describe 'PUT #benefits_save' do
    let(:expected_params) { { benefits: false } }
    let(:benefit_form) { instance_double(Forms::Application::Benefit, benefits: user_says_on_benefits) }
    let(:user_says_on_benefits) { false }
    let(:can_override) { false }
    let(:benefit_check_runner) { instance_double(BenefitCheckRunner, run: nil, can_override?: can_override) }

    before do
      allow(benefit_form).to receive(:update_attributes).with(expected_params)
      allow(benefit_form).to receive(:save).and_return(form_save)
      allow(BenefitCheckRunner).to receive(:new).with(application).and_return(benefit_check_runner)

      put :benefits_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      context 'when the applicant says they are on benefits' do
        let(:user_says_on_benefits) { true }

        it 'runs the benefit check on the application' do
          expect(benefit_check_runner).to have_received(:run)
        end

        context 'when the result can be overridden' do
          let(:can_override) { true }

          it 'redirects to the benefits override page' do
            expect(response).to redirect_to(application_benefit_override_paper_evidence_path(application))
          end
        end

        context 'when the result can not be overridden' do
          it 'redirects to the summary override page' do
            expect(response).to redirect_to(application_summary_path(application))
          end
        end
      end

      context 'when the applicant says they are not on benefits' do
        let(:user_says_on_benefits) { false }

        it 'does not run benefit check on the application' do
          expect(benefit_check_runner).not_to have_received(:run)
        end

        it 'redirects to the income page' do
          expect(response).to redirect_to(application_income_path(application))
        end

        context "it's refund" do
          let(:detail) { build_stubbed(:detail, refund: true) }

          it "still goes to income page" do
            expect(response).to redirect_to(application_income_path(application))
          end
        end
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:benefits)
      end

      it 'assigns the benefits form' do
        expect(assigns(:form)).to eql(benefit_form)
      end
    end
  end

  describe 'GET #income' do
    let(:application) { build_stubbed(:application, office: user.office, benefits: benefits) }

    before do
      get :income, application_id: application.id
    end

    context 'when application is on benefits' do
      let(:benefits) { true }

      it 'redirects to the summary' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when application is not on benefits' do
      let(:benefits) { false }

      it 'returns 200 response' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:income)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'PUT #income_save' do
    let(:expected_params) { { dependents: false } }

    before do
      allow(income_form).to receive(:update_attributes).with(expected_params)
      allow(income_form).to receive(:save).and_return(form_save)

      put :income_save, application_id: application.id, application: expected_params
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'runs the income calculation on the application' do
        expect(income_calculation_runner).to have_received(:run)
      end

      it 'redirects to the summary page' do
        expect(response).to redirect_to(application_summary_path(application))
      end
    end

    context 'when the form can\'t be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:income)
      end

      it 'assigns the income form' do
        expect(assigns(:form)).to eql(income_form)
      end
    end
  end

  describe 'GET #summary' do
    before do
      get :summary, application_id: application.id
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:summary)
      end

      it 'assigns application' do
        expect(assigns(:application)).to eql(application)
      end

      it 'assigns applicant' do
        expect(assigns(:applicant)).to be_a_kind_of(Views::Overview::Applicant)
      end

      it 'assigns details' do
        expect(assigns(:details)).to be_a_kind_of(Views::Overview::Details)
      end

      it 'assigns savings' do
        expect(assigns(:savings)).to be_a_kind_of(Views::Overview::SavingsAndInvestments)
      end

      it 'assigns benefits' do
        expect(assigns(:benefits)).to be_a_kind_of(Views::Overview::Benefits)
      end

      it 'assigns income' do
        expect(assigns(:income)).to be_a_kind_of(Views::Overview::Income)
      end
    end
  end

  describe 'POST #summary_save' do
    let(:current_time) { Time.zone.now }
    let(:user) { create :user }
    let(:application) { create :application_full_remission, office: user.office }
    let(:resolver) { instance_double(ResolverService, complete: nil) }

    context 'success' do
      before do
        allow(ResolverService).to receive(:new).with(application, user).and_return(resolver)

        Timecop.freeze(current_time) do
          sign_in user
          post :summary_save, application_id: application.id
        end
      end

      it 'returns the correct status code' do
        expect(response).to have_http_status(302)
      end

      it 'redirects to the confirmation page' do
        expect(response).to redirect_to(application_confirmation_path(application.id))
      end

      it 'completes the application using the ResolverService' do
        expect(resolver).to have_received(:complete)
      end
    end

    context 'exception' do
      let(:exception) { ActiveRecord::RecordInvalid.new(application) }

      before do
        allow(ResolverService).to receive(:new).and_raise(exception)
      end

      def post_summary_save
        Timecop.freeze(current_time) do
          sign_in user
          post :summary_save, application_id: application.id
        end
      end

      it 'catch exception and return error' do
        post_summary_save
        expect(flash[:alert]).to include('There was an issue creating the new record')
      end

      it 'redirect to previous page' do
        post_summary_save
        expect(response).to redirect_to(application_summary_path(application))
      end

      it 'catch exception and notify sentry' do
        allow(Raven).to receive(:capture_exception).with(exception, application_id: application.id)
        post_summary_save
      end
    end
  end

  describe 'PUT #override' do
    let!(:application) { create(:application, office: user.office) }
    let(:override_reason) { nil }
    let(:params) { { value: override_value, reason: override_reason, created_by_id: user.id } }

    before { put :override, application_id: application.id, application: params }

    context 'when the parameters are valid' do
      context 'by selecting a radio button' do
        let(:override_value) { 1 }

        it 'redirects to the confirmation page' do
          expect(response).to redirect_to(application_confirmation_path(application))
        end
      end

      context 'by selecting `other` and providing a reason' do
        let(:override_value) { 'other' }
        let(:override_reason) { 'foo bar' }

        it 'redirects to the confirmation page' do
          expect(response).to redirect_to(application_confirmation_path(application))
        end
      end
    end

    context 'when the parameters are invalid' do
      context 'because they are missing' do
        let(:override_value) { nil }

        it 're-renders the confirmation page' do
          expect(response).to render_template(:confirmation)
        end
      end

      context 'because a reason is not supplied' do
        let(:override_value) { 'other' }

        it 're-renders the confirmation page' do
          expect(response).to render_template(:confirmation)
        end
      end
    end
  end

  context 'GET #confirmation' do
    before { get :confirmation, application_id: application.id }

    it 'displays the confirmation view' do
      expect(response).to render_template :confirmation
    end

    it 'assigns application' do
      expect(assigns(:application)).to eql(application)
    end

    it 'assigns confirm' do
      expect(assigns(:confirm)).to be_a_kind_of(Views::Confirmation::Result)
    end
  end

end
