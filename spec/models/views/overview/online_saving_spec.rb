# spec/views/overview/online_saving_spec.rb

require 'rails_helper'

RSpec.describe Views::Overview::OnlineSaving, type: :module do
  let(:online_application) { instance_double(OnlineApplication) }
  let(:dummy_class) { Class.new { include Views::Overview::OnlineSaving }.new }

  before do
    dummy_class.instance_variable_set(:@online_application, online_application)
  end

  describe '#saving_over_66' do
    it 'returns Yes if over 66' do
      allow(online_application).to receive(:over_66).and_return(true)
      expect(dummy_class.saving_over_66).to eq('Yes')
    end

    it 'returns No if not over 66' do
      allow(online_application).to receive(:over_66).and_return(false)
      expect(dummy_class.saving_over_66).to eq('No')
    end
  end

  describe '#less_then' do
    it 'returns Yes if min threshold not exceeded' do
      allow(online_application).to receive(:min_threshold_exceeded).and_return(false)
      expect(dummy_class.less_then).to eq('Yes')
    end

    it 'returns No if min threshold exceeded' do
      allow(online_application).to receive(:min_threshold_exceeded).and_return(true)
      expect(dummy_class.less_then).to eq('No')
    end
  end

  describe '#between' do
    it 'returns Yes if min threshold exceeded and max threshold not exceeded' do
      allow(online_application).to receive_messages(min_threshold_exceeded: true, max_threshold_exceeded: false)
      expect(dummy_class.between).to eq('Yes')
    end

    it 'returns No if min threshold not exceeded' do
      allow(online_application).to receive(:min_threshold_exceeded).and_return(false)
      expect(dummy_class.between).to eq('No')
    end

    it 'returns No if max threshold exceeded' do
      allow(online_application).to receive_messages(min_threshold_exceeded: true, max_threshold_exceeded: true)
      expect(dummy_class.between).to eq('No')
    end
  end

  describe '#more_then' do
    it 'returns Yes if both min and max thresholds exceeded' do
      allow(online_application).to receive_messages(min_threshold_exceeded: true, max_threshold_exceeded: true)
      expect(dummy_class.more_then).to eq('Yes')
    end

    it 'returns No if min threshold not exceeded' do
      allow(online_application).to receive(:min_threshold_exceeded).and_return(false)
      expect(dummy_class.more_then).to eq('No')
    end

    it 'returns No if max threshold not exceeded' do
      allow(online_application).to receive_messages(min_threshold_exceeded: true, max_threshold_exceeded: false)
      expect(dummy_class.more_then).to eq('No')
    end
  end
end
