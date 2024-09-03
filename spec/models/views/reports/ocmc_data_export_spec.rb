# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::OcmcDataExport do
  subject(:ocmc_export) { described_class.new(from_date, to_date, office_id) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }
  let(:office_id) { office.id }

  let(:office) { create(:office) }
  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  describe 'to_csv' do
    let(:application1) {
      create(:application, :processed_state, office: office, detail: app1_detail,
                                             children_age_band: { one: 7, two: 8 }, income_period: 'last_month')
    }
    let(:application2) { create(:application, :waiting_for_evidence_state, office: office) }
    let(:application3) {
      create(:application, :waiting_for_part_payment_state, office: office, detail: app3_detail,
                                                            children_age_band: { one: 1, two: 1 }, income_period: 'average')
    }
    let(:application4) { create(:application, :deleted_state, office: office, detail: app2_detail, children_age_band: { one: 0, two: 1 }) }
    let(:application5) { create(:application, office: office) }
    let(:application6) { create(:application, :processed_state, office: office) }
    let(:application7) { create(:application, :processed_state) }

    let(:app1_detail) { create(:complete_detail, :legal_representative, calculation_scheme: 'post_ucd') }
    let(:app2_detail) { create(:complete_detail, :litigation_friend, calculation_scheme: 'pre_ucd') }
    let(:app3_detail) { create(:complete_detail, :applicant) }

    subject(:data) { ocmc_export.to_csv.split("\n") }

    before do
      Timecop.freeze(date_from + 1.day) { application1 }
      Timecop.freeze(date_from + 2.days) { application2 }
      Timecop.freeze(date_from + 3.days) { application3 }
      Timecop.freeze(date_from + 4.days) { application4 }
      Timecop.freeze(date_from + 5.days) { application5 }
      Timecop.freeze(date_from + 36.days) { application6 }
      Timecop.freeze(date_from + 6.days) { application7 }

      application1.applicant.update(partner_ni_number: 'SN789654C')
      application3.applicant.update(partner_ni_number: 'SN789654C', partner_last_name: 'Jones')
      application4.applicant.update(partner_ni_number: '', partner_last_name: 'Jones')
    end

    it 'return 5 rows csv data' do
      expect(data.count).to be(5)
    end

    it 'first row are keys' do
      keys = "Office,HwF reference number,Fee,Application type,Form Type,Claim Type,Form Name,Refund,Income,Income period,Children,Age band under 14," \
             "Age band 14+,Married,Decision,Applicant pays estimate,Applicant pays,Departmental cost estimate,Departmental cost," \
             "Source,Granted?,Evidence checked?,Capital Band,Saving and Investments,Case number,Date received,Statement signed by," \
             "Partner NI entered,Partner name entered,HwF Scheme"

      expect(data[0]).to eq(keys)
    end

    context 'order by created at' do
      it { expect(data[1]).to include(application4.reference) }
      it { expect(data[2]).to include(application3.reference) }
      it { expect(data[3]).to include(application2.reference) }
      it { expect(data[4]).to include(application1.reference) }
    end

    context 'in given timeframe' do
      it { expect(data.join).not_to include(application6.reference) }
    end

    context 'for given office' do
      it { expect(data.join).not_to include(application7.reference) }
    end

    context 'signed by values and partner data' do
      it {
        expect(data[4]).to include('legal_representative,true,false,post_ucd')
      }

      it {
        expect(data[1]).to include('litigation_friend,false,true,pre_ucd')
      }

      it {
        expect(data[2]).to include('applicant,true,true')
      }
    end
    context 'children age bands' do
      it {
        expect(data[4]).to include('500,last_month,1,7,8')
      }

      it {
        expect(data[1]).to include('500,,1,0,1')
      }

      it {
        expect(data[2]).to include('500,average,1,1,1')
      }
    end

  end
end
