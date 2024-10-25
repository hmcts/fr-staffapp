# coding: utf-8

require 'rails_helper'

RSpec.describe Views::Overview::Income do
  subject(:view) { described_class.new(application) }

  let(:application) { build_stubbed(:application) }

  describe '#all_fields' do
    subject { view.all_fields }

    it { is_expected.to eql ['children?', 'children', 'income'] }
  end

  describe '#children??' do
    subject { view.children? }

    let(:application) { build_stubbed(:application, dependents: dependents) }

    [true, false].each do |value|
      context "when dependents is #{value}" do
        let(:dependents) { value }

        it { is_expected.to eq I18n.t("convert_boolean.#{value}") }
      end
    end
  end

  describe '#children' do
    subject { view.children }

    let(:application) { build_stubbed(:application, dependents: dependents, children: children) }

    context 'when the applicant has dependants' do
      let(:dependents) { true }
      let(:children) { 2 }

      it { is_expected.to eq 2 }
    end

    context 'when the applicant no dependants' do
      let(:dependents) { false }

      context 'children = 0' do
        let(:children) { 0 }

        it { is_expected.to eq 0 }
      end

      context 'children = 2' do
        let(:children) { 2 }

        it { is_expected.to eq 0 }
      end
    end
  end

  describe '#income' do
    subject { view.income }

    let(:application) { build_stubbed(:application, income: 300) }

    it { is_expected.to eq '£300' }

    context 'blank' do
      let(:application) { build_stubbed(:application, income: nil) }
      it { is_expected.to be_nil }
    end
  end

  describe '#income_period' do
    subject { view.income_period }

    let(:application) { build_stubbed(:application, income: 300, income_period: 'last_month') }

    it { is_expected.to eq 'Last calendar month' }

    context 'blank' do
      let(:application) { build_stubbed(:application, income: nil) }
      it { is_expected.to be_nil }
    end
  end

  context 'income kind applicant' do
    subject { view.income_kind_applicant }

    let(:application) { build_stubbed(:application, income_kind: { applicant: [:wage, :net_profit] }) }

    it { is_expected.to eq 'Wages before tax and National Insurance are taken off, Net profits from self employment' }
  end

  context 'income kind partner' do
    subject { view.income_kind_partner }

    let(:application) { build_stubbed(:application, income_kind: { applicant: [:wage, :net_profit], partner: [:child_benefit, :working_credit] }) }

    it { is_expected.to eq 'Child Benefit, Working Tax Credit' }
  end
end
