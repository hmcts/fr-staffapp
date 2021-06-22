require 'rails_helper'

RSpec.describe NotifyMailer, type: :mailer do
  let(:application) { build :online_application_with_all_details, :with_reference, date_received: DateTime.parse('1 June 2021') }

  describe '#submission_confirmation' do
    let(:mail) { described_class.submission_confirmation(application) }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_TEMPLATE_ID']

    it 'has the right keys with form_name' do
      application.form_name = ''
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        form_name_case_number: '234567',
                                                        application_submitted_date: DateTime.parse('1 June 2021'),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it 'has the right keys with case number' do
      application.form_name = 'FGDH122'
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        form_name_case_number: 'FGDH122',
                                                        application_submitted_date: DateTime.parse('1 June 2021'),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }
  end

  describe '#submission_confirmation_refund' do
    let(:mail) { described_class.submission_confirmation_refund(application) }

    it_behaves_like 'a Notify mail', template_id: ENV['NOTIFY_COMPLETED_REFUND_TEMPLATE_ID']

    it 'has the right keys' do
      expect(mail.govuk_notify_personalisation).to eq({
                                                        application_reference_code: application.reference,
                                                        application_submitted_date: DateTime.parse('1 June 2021'),
                                                        applicant_name: 'Peter Smith'
                                                      })
    end

    it { expect(mail.to).to eq(['peter.smith@example.com']) }
  end
end
