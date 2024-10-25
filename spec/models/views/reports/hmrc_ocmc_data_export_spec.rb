# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Reports::HmrcOcmcDataExport do
  subject(:ocmc_export) { described_class.new(from_date, to_date, office_id) }
  let(:from_date) { { day: date_from.day, month: date_from.month, year: date_from.year } }
  let(:to_date) { { day: date_to.day, month: date_to.month, year: date_to.year } }
  let(:office_id) { office.id }

  let(:office) { create(:office) }
  let(:date_from) { Date.parse('1/1/2021') }
  let(:date_to) { Date.parse('1/2/2021') }

  describe 'to_csv' do
    let(:application1) {
      create(:application, :processed_state, office: office, income_kind: {},
                                             detail: app1_detail, children_age_band: { one: 7, two: 8 }, income_period: 'last_month')
    }
    let(:application2) { create(:application, :waiting_for_evidence_state, office: office) }
    let(:application3) {
      create(:application, :waiting_for_part_payment_state, office: office,
                                                            detail: app3_detail, children_age_band: { one: 1, two: 1 }, income_period: 'average')
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

    context 'data fields' do
      let(:application2) {
        create(:application, :waiting_for_evidence_state,
               office: office, income_kind: income_kind)
      }
      let(:evidence_check) { application2.evidence_check }
      let(:hmrc_check) {
        create(:hmrc_check, evidence_check: evidence_check,
                            created_at: 2.days.ago, income: nil, tax_credit: nil, request_params: date_range)
        create(:hmrc_check, evidence_check: evidence_check,
                            created_at: 1.day.ago, income: paye_income, tax_credit: tax_credit, request_params: date_range)
      }
      let(:income_kind) { {} }
      let(:tax_credit) { {} }
      let(:paye_income) { {} }
      let(:date_range) { { date_range: { from: "1/7/2022", to: "31/7/2022" } } }

      before { hmrc_check }

      context 'paye income' do
        let(:paye_income) { [{ "taxablePay" => 120.04 }] }
        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('120.04')
        end
      end

      context 'paye and tax credit income' do
        let(:paye_income) { [{ "taxablePay" => 120.04 }] }
        let(:tax_credit) {
          {
            child:
            [
              { "payProfCalcDate" => "2022-07-30",
                "totalEntitlement" => 7432.23,
                "childTaxCredit" => { "childCareAmount" => 1310.41, "ctcChildAmount" => 5321.05, "familyAmount" => 547.5, "babyAmount" => 0, "paidYTD" => 2634.71 },
                "payments" =>
               [{ "startDate" => "2022-07-05", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 165.26 },
                { "startDate" => "2022-04-19", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 165.26 },
                { "startDate" => "2022-04-19", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 147.74 },
                { "startDate" => "2022-04-26", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 155.17 },
                { "startDate" => "2022-05-10", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 155.2 }] }
            ],
            work:
             [
               { "payProfCalcDate" => "2022-07-30",
                 "totalEntitlement" => 7432.23,
                 "childTaxCredit" => { "childCareAmount" => 1310.41, "ctcChildAmount" => 5321.05, "familyAmount" => 547.5, "babyAmount" => 0, "paidYTD" => 2634.71 },
                 "payments" =>
                [{ "startDate" => "2022-07-05", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 165.26 },
                 { "startDate" => "2022-04-19", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 165.26 },
                 { "startDate" => "2022-04-19", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 147.74 },
                 { "startDate" => "2022-04-26", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 155.17 },
                 { "startDate" => "2022-05-10", "endDate" => "2022-08-30", "frequency" => 7, "tcType" => "ICC", "amount" => 155.2 }] }
             ]
          }
        }

        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('5044.46')
        end

        it 'displays formatted date range' do
          data_row = data[3]
          expect(data_row).to include('1/7/2022 - 31/7/2022')
        end

        context 'no fail from tax_credit' do
          let(:paye_income) { [{ "taxablePay" => 120.04 }] }
          let(:tax_credit) {
            { child: nil, work: [] }
          }
          it "calculates correct value" do
            data_row = data[3]
            expect(data_row).to include('120.04')
          end

          context 'no date' do
            let(:date_range) { nil }
            it "calculates correct value" do
              data_row = data[3]
              expect(data_row).to include('120.04')
            end
          end
        end
      end

      context 'income_kind' do
        let(:income_kind) { { applicant: [:wage, :working_credit] } }
        it "calculates correct value" do
          data_row = data[3]
          expect(data_row).to include('Wages before tax and National Insurance are taken off,Working Tax Credit')
        end
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
end
