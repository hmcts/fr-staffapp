require 'rails_helper'

RSpec.describe Applications::Process::SavingsInvestmentsController do
  let(:user)          { create(:user) }
  let(:application) { build_stubbed(:application, office: user.office, detail: detail, saving: saving, income: 1000) }
  let(:detail) { build(:detail, calculation_scheme: scheme, fee: 120) }
  let(:saving) { build_stubbed(:saving, amount: 16000) }
  let(:band_saving) { true }

  let(:scheme) { '' }

  let(:savings_investments_form) { instance_double(Forms::Application::SavingsInvestment) }
  let(:personal_information_form) { instance_double(Forms::Application::Applicant) }
  let(:savings_pass_fail_service) { instance_double(SavingsPassFailService) }
  let(:band_calculation) { instance_double(BandBaseCalculation, remission: 'none') }

  before do
    sign_in user
    allow(Application).to receive(:find).with(application.id.to_s).and_return(application)
    allow(Forms::Application::SavingsInvestment).to receive(:new).with(application.saving).and_return(savings_investments_form)
    allow(SavingsPassFailService).to receive(:new).with(application.saving).and_return(savings_pass_fail_service)
    allow(BandBaseCalculation).to receive(:new).and_return(band_calculation)
    allow(saving).to receive(:update)
    allow(application).to receive(:update)
  end

  describe 'GET #savings_investments' do
    before do
      get :index, params: { application_id: application.id }
    end

    context 'when the application does exist' do
      it 'responds with 200' do
        expect(response).to have_http_status(200)
      end

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(savings_investments_form)
      end

      it 'assigns the application' do
        expect(assigns(:application)).to eql(application)
      end
    end
  end

  describe 'PUT #savings_investments_save' do
    let(:expected_params) { { min_threshold_exceeded: 'false' } }
    let(:band_saving) { false }
    before do
      allow(savings_investments_form).to receive(:update).with(expected_params)
      allow(savings_investments_form).to receive(:save).and_return(form_save)
      allow(savings_pass_fail_service).to receive(:calculate!).and_return(form_save)
      allow(band_calculation).to receive(:saving_passed?).and_return(band_saving)
      post :create, params: { application_id: application.id, application: expected_params }
    end

    context 'when the form can be saved' do
      let(:form_save) { true }

      it 'redirects to benefits' do
        expect(response).to redirect_to(application_benefits_path(application))
      end
    end

    context 'when the form can not be saved' do
      let(:form_save) { false }

      it 'renders the correct template' do
        expect(response).to render_template(:index)
      end

      it 'assigns the correct form' do
        expect(assigns(:form)).to eql(savings_investments_form)
      end

      it 'assigns the application' do
        expect(assigns(:application)).to eql(application)
      end
    end

    context 'UCD' do
      let(:form_save) { true }
      let(:scheme) { FeatureSwitching::CALCULATION_SCHEMAS[1] }

      it 'redirects to summary page if savings fail' do
        expect(response).to redirect_to(application_declaration_path(application))
      end

      it 'update saving with result' do
        expect(saving).to have_received(:update).with(passed: false)
      end

      it 'update application it saving fails with result' do
        expect(application).to have_received(:update).with(outcome: 'none', application_type: 'income', amount_to_pay: 120, income: nil)
        expect(application.income).to eq 1000
      end

      context 'saving passed' do
        let(:band_saving) { true }

        it 'not update to application it saving passes' do
          expect(application).not_to have_received(:update)
        end
      end

    end
  end
end
