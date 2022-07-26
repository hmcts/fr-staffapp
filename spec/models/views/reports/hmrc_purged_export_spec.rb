# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::HmrcPurgedExport do
  subject(:hmrc_export) { described_class.new(date_from, date_to) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }

  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  describe 'to_csv' do
    let(:hmrc_check1) { create :hmrc_check, ni_number: 'SN123451', date_of_birth: '01/01/1980', request_params: { date_range: { from: "1/2/2018", to: "1/3/2018" } } }
    let(:hmrc_check2) { create :hmrc_check, ni_number: 'SN123452', date_of_birth: '01/02/1981', request_params: { date_range: { from: "1/2/2019", to: "1/3/2019" } } }
    let(:hmrc_check3) { create :hmrc_check, ni_number: 'SN123453', date_of_birth: '01/03/1982', request_params: { date_range: { from: "1/2/2020", to: "1/3/2020" } } }
    let(:hmrc_check4) { create :hmrc_check, ni_number: 'SN123454', date_of_birth: '01/04/1983', request_params: { date_range: { from: "1/2/2021", to: "1/3/2021" } } }
    let(:hmrc_check5) { create :hmrc_check, ni_number: 'SN123455', date_of_birth: '01/05/1984', request_params: { date_range: { from: "1/2/2022", to: "1/3/2022" } } }

    subject(:data) { hmrc_export.to_csv.split("\n") }

    before do
      Timecop.freeze(date_from + 1.day) { hmrc_check1 }
      Timecop.freeze(date_from + 5.days) { hmrc_check2 }
      Timecop.freeze(date_from + 3.days) { hmrc_check3 }
      Timecop.freeze(date_to + 1.day) { hmrc_check4 }
      Timecop.freeze(date_from - 1.day) { hmrc_check5 }
    end

    it 'return 4 rows csv data' do
      expect(data.count).to be(4)
    end

    it 'first row are keys' do
      keys = "Date created,Date purged,HWF reference,Applicant name,Applicant DOB,Applicant NI number,Date range HMRC data requested for,PAYE data,Child Tax Credit,Work Tax Credit"
      expect(data[0]).to eq(keys)
    end

    context 'order by created at' do
      it { expect(data[1]).to include(hmrc_check1.evidence_check.application.reference) }
      it { expect(data[2]).to include(hmrc_check3.evidence_check.application.reference) }
      it { expect(data[3]).to include(hmrc_check2.evidence_check.application.reference) }
    end

    context 'in given timeframe' do
      it { expect(data.join).not_to include(hmrc_check4.evidence_check.application.reference) }
      it { expect(data.join).not_to include(hmrc_check5.evidence_check.application.reference) }
    end

    context 'hmrc data' do
      let(:applicant) { hmrc_check1.evidence_check.application.applicant }
      let(:expected_line) { "2021-01-02 00:00:00 UTC,,AB001-21-1,#{applicant.first_name} #{applicant.last_name},01/01/1980,SN123451,1/2/2018 to 1/3/2018,present,empty,present" }
      it { expect(data[1]).to eq expected_line }
    end

    context 'hmrc data empty' do
      let(:hmrc_check3) { create :hmrc_check, ni_number: 'SN123453', date_of_birth: '01/03/1982', request_params: nil, tax_credit: nil, income: nil }
      let(:applicant) { hmrc_check3.evidence_check.application.applicant }
      let(:expected_line) { "2021-01-04 00:00:00 UTC,,AB001-21-3,#{applicant.first_name} #{applicant.last_name},01/03/1982,SN123453,,empty,empty,empty" }
      it { expect(data[2]).to eq expected_line }
    end
  end
end
