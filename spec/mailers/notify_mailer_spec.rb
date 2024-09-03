require 'rails_helper'

RSpec.describe NotifyMailer do
  let(:application) { build(:online_application_with_all_details, :with_reference, date_received: DateTime.parse('1 June 2021')) }
  let(:user) { build(:user, name: 'John Jones', invitation_token: '123456abcd', email: 'petr@test.gov.uk') }

  describe '#password_reset' do
    let(:mail) { described_class.reset_password_instructions(user, 'token134', []) }
    let(:link) { edit_user_password_url(reset_password_token: 'token134') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_PASSWORD_RESET_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: 'John Jones',
                                                        password_link: 'http://localhost:3000/users/password/edit?reset_password_token=token134'
                                                      })
    end

  end

  describe '#dwp_is_down_notifier' do
    let(:mail) { described_class.dwp_is_down_notifier }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_DWP_DOWN_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        environment: 'test'
                                                      })
      expect(mail.to).to eq(['dan@test.com', 'petr@test.gov.uk'])
    end

  end

  describe '#user_invite' do
    let(:mail) { described_class.user_invite(user) }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_USER_INVITE_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: 'John Jones',
                                                        invite_url: "http://localhost:3000/users/invitation/accept"
                                                      })
      expect(mail.to).to eq(['petr@test.gov.uk'])
    end
  end

  describe '#submission_confirmation_online' do
    let(:mail) { described_class.submission_confirmation_online(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID', nil)

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'when case and name of form is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }

    context 'litigation application' do
      let(:application) { build(:online_application_with_all_details, :with_reference, legal_representative_email: 'tom@work.com') }
      it { expect(mail.to).to eq(['tom@work.com']) }
    end

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation_online(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID', nil)
    end
  end

  describe '#submission_confirmation_paper' do
    let(:mail) { described_class.submission_confirmation_paper(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_PAPER_TEMPLATE_ID', nil)

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'when case and form number is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }

    context 'litigation application' do
      let(:application) { build(:online_application_with_all_details, :with_reference, legal_representative_email: 'tom@work.com') }
      it { expect(mail.to).to eq(['tom@work.com']) }
    end

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation_online(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID', nil)
    end
  end

  describe '#submission_confirmation_refund' do
    let(:mail) { described_class.submission_confirmation_refund(application, 'en') }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID', nil)

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    it 'when case and name of form is empty' do
      application.form_name = ''
      application.case_number = ''
      expect(mail.govuk_notify_personalisation).to eq({ application_reference_code: application.reference })
    end

    context 'litigation application' do
      let(:application) { build(:online_application_with_all_details, :with_reference, legal_representative_email: 'tom@work.com') }
      it { expect(mail.to).to eq(['tom@work.com']) }
    end

    context 'applicant' do
      it { expect(mail.to).to eq(['peter.smith@example.com']) }
    end

    context 'welsh' do
      let(:mail) { described_class.submission_confirmation_refund(application, 'cy') }
      it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID', nil)
    end
  end

  describe '#file_report_ready' do
    let(:user) { create(:user) }
    let(:mail) { described_class.file_report_ready(user, 1) }

    it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_RAW_DATA_READY_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: user.name,
                                                        link_to_download_page: user_export_file_url(user.id, 1)
                                                      })
      expect(mail.to).to eq([user.email])
      mail.govuk_notify_personalisation[:link_to_download_page]
    end

    it 'has the right domain' do
      allow(ENV).to receive(:fetch).with("NOTIFY_RAW_DATA_READY_TEMPLATE_ID", nil).
        and_return("template")
      allow(ENV).to receive(:fetch).with("URL_HELPER_DOMAIN", nil).
        and_return("testdomain")

      link = mail.govuk_notify_personalisation[:link_to_download_page]
      expect(link).to eq("http://testdomain:3000/users/#{user.id}/export_file/1")
    end

  end

  describe '#confirmation_instructions' do
    let(:user) { create(:user, unconfirmed_email: 'new_email@test.com') }
    let(:mail) { described_class.confirmation_instructions(user, 'token123') }

    # it_behaves_like 'a Notify mail', template_id: ENV.fetch('NOTIFY_CONFIRMATION_EMAIL_TEMPLATE_ID', nil)

    it 'has the right values' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        name: user.name,
                                                        confirmation_link: user_confirmation_url(confirmation_token: 'token123')
                                                      })
      expect(mail.to).to eq(['new_email@test.com'])
      mail.govuk_notify_personalisation[:link_to_download_page]
    end

    it 'has the right domain' do
      allow(ENV).to receive(:fetch).with("NOTIFY_CONFIRMATION_EMAIL_TEMPLATE_ID", nil).
        and_return("template")
      allow(ENV).to receive(:fetch).with("URL_HELPER_DOMAIN", nil).
        and_return("testdomain")

      link = mail.govuk_notify_personalisation[:confirmation_link]
      expect(link).to eq("http://testdomain:3000/users/confirmation?confirmation_token=token123")
    end

  end

end
