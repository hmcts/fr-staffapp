# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Confirmation::Result do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application, detail: detail) }
  let(:string_passed) { '✓ Passed' }
  let(:string_failed) { '✗ Failed' }
  let(:string_waiting_evidence) { 'Waiting for evidence' }
  let(:string_part_payment) { 'Waiting for part-payment' }
  let(:scope) { 'convert_pass_fail' }
  let(:saving) { double }
  let(:detail) { build_stubbed(:detail) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['discretion_applied?', 'savings_passed?', 'benefits_passed?', 'income_passed?'] }
  end

  describe '#discretion_applied?' do
    subject { view.discretion_applied? }

    context "when discretion is denied" do
      let(:detail) { build_stubbed(:detail, discretion_applied: false) }

      it { is_expected.to eq I18n.t(false.to_s, scope: scope) }
    end

    context "when discretion is granted" do
      let(:detail) { build_stubbed(:detail, discretion_applied: true) }

      it { is_expected.to eq I18n.t(true.to_s, scope: scope) }
    end

    context "when discretion is nil" do
      let(:detail) { build_stubbed(:detail, discretion_applied: nil) }

      it { is_expected.to be false }
    end

  end

  describe '#savings_passed?' do
    subject { view.savings_passed? }

    context "is true " do
      before do
        allow(application).to receive(:saving).and_return(saving)
        allow(saving).to receive(:passed?).and_return(true)
        allow(saving).to receive(:passed).and_return(true)
      end

      it { is_expected.to eq I18n.t(true.to_s, scope: scope) }

      context 'override exists' do
        let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: 5) }
        let(:application) { build_stubbed(:application, :benefit_type) }

        before { decision_override }

        it { is_expected.to eq I18n.t(true.to_s, scope: scope) }
      end
    end

    context "is false" do
      before do
        allow(application).to receive(:saving).and_return(saving)
        allow(saving).to receive(:passed?).and_return(false)
        allow(saving).to receive(:passed).and_return(false)
      end

      it { is_expected.to eq I18n.t(false.to_s, scope: scope) }
    end

    context 'and there is no saving' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: 5) }
      let(:application) { build_stubbed(:application, :income_type, benefits: nil) }

      before do
        allow(application).to receive(:saving).and_return(saving)
        allow(saving).to receive(:passed).and_return(nil)
        decision_override
      end

      it { is_expected.to be nil }
    end

  end

  describe '#benefits_passed?' do
    subject { view.benefits_passed? }
    context 'when benefits is false' do
      let(:application) { build_stubbed(:application, :benefit_type, benefits: false) }

      it { is_expected.to eq string_failed }
    end

    context 'when benefits is true' do
      context 'and benefit_check returned yes' do
        let!(:benefit_check) { build_stubbed(:benefit_check, application: application, dwp_result: 'Yes') }
        let!(:application) { build_stubbed(:application, :benefit_type) }
        before { allow(application).to receive(:last_benefit_check).and_return(benefit_check) }

        it { is_expected.to eq string_passed }
      end

      ['No', 'Undetermined'].each do |result|
        context "benefit_check returned #{result}" do
          let(:benefit_check) { build_stubbed(:benefit_check, application: application, dwp_result: result) }
          let(:application) { build_stubbed(:application, :benefit_type) }
          before { allow(application).to receive(:last_benefit_check).and_return(benefit_check) }

          it { is_expected.to eq string_failed }
        end
      end
    end

    context 'when a benefit_override exists' do
      before { build_stubbed(:benefit_override, application: application, correct: value) }

      context 'and the evidence is correct' do
        let(:value) { true }

        it { is_expected.to eq I18n.t('activemodel.attributes.forms/application/summary.passed_with_evidence') }
      end

      context 'and the evidence is incorrect' do
        let(:value) { false }

        it { is_expected.to eq I18n.t('activemodel.attributes.forms/application/summary.failed_with_evidence') }
      end
    end

    context 'when a decision override exists' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: id) }
      before { decision_override }

      context 'but it is not saved' do
        let(:id) { nil }
        it { is_expected.not_to eq "✓ Passed (by manager's decision)" }
      end

      context 'and it is saved' do
        let(:id) { 5 }
        it { is_expected.to eq "✓ Passed (by manager's decision)" }
      end

      context 'but there is no benefit' do
        let(:application) { build_stubbed(:application, :income_type, benefits: nil) }
        let(:id) { 5 }
        it { is_expected.to be nil }
      end
    end
  end

  describe '#income_passed?' do
    subject { view.income_passed? }

    let(:application) { build_stubbed(:application, :income_type, state: state, outcome: outcome) }

    context 'when the application is a full remission' do
      let(:state) { 3 }
      let(:outcome) { 'full' }

      it { is_expected.to eq string_passed }
    end

    context 'when the application is a part remission' do
      let(:state) { 2 }
      let(:outcome) { 'part' }

      it { is_expected.to eq string_part_payment }
    end

    context 'when the application is a non remission' do
      let(:state) { 3 }
      let(:outcome) { 'none' }

      it { is_expected.to eq string_failed }
    end
  end

  describe '#result' do
    subject { view.result }

    context 'when an application has an evidence_check' do
      before { build_stubbed(:evidence_check, application: application) }

      it { is_expected.to eql 'callout' }
    end

    context 'when an application has had benefits overridden' do
      before { build_stubbed :benefit_override, application: application, correct: evidence_correct }

      context 'and the correct evidence was provided' do
        let(:evidence_correct) { true }

        it { is_expected.to eql 'full' }
      end
    end

    context 'when outcome is nil' do
      before { application.outcome = nil }

      it { is_expected.to eql 'none' }
    end

    context 'when a decision override exists' do
      let(:decision_override) { build(:decision_override, application: application, reason: 'foo bar', id: id) }
      before { decision_override }

      context 'but it is not saved' do
        let(:id) { nil }
        it { is_expected.to eql 'none' }
      end

      context 'and it is valid' do
        let(:id) { 8 }
        it { is_expected.to eql 'granted' }
      end
    end

  end
end
