# rubocop:disable Metrics/AbcSize
def stub_hmrc_api
  hmrc_api = instance_double(HwfHmrcApi::Connection)
  allow(HwfHmrcApi).to receive(:new).and_return hmrc_api
  allow(hmrc_api).to receive(:match_user)
  allow(hmrc_api).to receive(:child_tax_credits).and_return([])
  allow(hmrc_api).to receive(:working_tax_credits).and_return([])
  authentication = instance_double(HwfHmrcApi::Authentication, access_token: 1, expires_in: 1.second.from_now)
  allow(hmrc_api).to receive(:authentication).and_return(authentication)
  hmrc_api
end
# rubocop:enable Metrics/AbcSize

def hmrc_low_income
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({ 'income' => [{ "taxablePay" => 500 }] })
end

def hmrc_medium_income
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({ 'income' => [{ "taxablePay" => 1200 }] })
end

def hmrc_high_income
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({ 'income' => [{ "taxablePay" => 7000 }] })
end

def hmrc_working_tax_credits
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({ 'income' => [{ "taxablePay" => 2000 }] })
  allow(hmrc_api).to receive(:working_tax_credits).and_return([{ "awards" => ['work test'] }])
end

def hmrc_recalculated_tax_credits
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({ 'income' => [{ "taxablePay" => 2000 }] })
  allow(hmrc_api).to receive(:working_tax_credits).and_return([{ "awards" => work_tax_credit_hash }])
end

def hmrc_child_tax_credits
  hmrc_api = stub_hmrc_api
  allow(hmrc_api).to receive(:paye).and_return({ 'income' => [{ "taxablePay" => 1900 }] })
  allow(hmrc_api).to receive(:child_tax_credits).and_return([{ "awards" => ['child test'] }])
end

def work_tax_credit_hash
  [
    { "payProfCalcDate" => 1.year.from_now.to_s,
      "totalEntitlement" => 1876523,
      "workingTaxCredit" => { "amount" => 73049, "paidYTD" => 897634, "childCareAmount" => 93098 },
      "payments" => [
        { "startDate" => '2021-06-24', "endDate" => '2022-03-31', "frequency" => 1, "postedDate" => "2023-03-15", "amount" => 17059 }
      ] }
  ]
end
