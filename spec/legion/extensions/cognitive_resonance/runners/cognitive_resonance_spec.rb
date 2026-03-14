# frozen_string_literal: true

require 'legion/extensions/cognitive_resonance/client'

RSpec.describe Legion::Extensions::CognitiveResonance::Runners::CognitiveResonance do
  let(:client) { Legion::Extensions::CognitiveResonance::Client.new }
  let(:engine) { Legion::Extensions::CognitiveResonance::Helpers::ResonanceEngine.new }

  describe '#present_input' do
    it 'returns success: true for valid input' do
      result = client.present_input(input: [0.8, 0.6, 0.4])
      expect(result[:success]).to be(true)
    end

    it 'returns the outcome' do
      result = client.present_input(input: [0.8, 0.6, 0.4])
      expect(result[:outcome]).to be_a(Symbol)
    end

    it 'returns a category_id' do
      result = client.present_input(input: [0.8, 0.6, 0.4])
      expect(result[:category_id]).to be_a(String)
    end

    it 'returns a quality score' do
      result = client.present_input(input: [0.8, 0.6, 0.4])
      expect(result[:quality]).to be_between(0.0, 1.0)
    end

    it 'returns success: false for empty input' do
      result = client.present_input(input: [])
      expect(result[:success]).to be(false)
      expect(result[:error]).to eq(:empty_input)
    end

    it 'returns success: false for nil input' do
      result = client.present_input(input: nil)
      expect(result[:success]).to be(false)
    end

    it 'uses injected engine when provided' do
      result = client.present_input(input: [0.5, 0.5], engine: engine)
      expect(result[:success]).to be(true)
      expect(engine.category_count).to be >= 1
    end

    it 'resonates on second identical input' do
      client.present_input(input: [0.8, 0.6, 0.4])
      result = client.present_input(input: [0.8, 0.6, 0.4])
      expect(result[:outcome]).to eq(:resonance)
    end

    it 'creates new category on first input' do
      result = client.present_input(input: [0.8, 0.6, 0.4])
      expect(result[:outcome]).to eq(:new_category)
    end
  end

  describe '#classify' do
    it 'returns success: false for empty input' do
      result = client.classify(input: [])
      expect(result[:success]).to be(false)
    end

    it 'returns found: false when no categories exist' do
      result = client.classify(input: [0.5, 0.5], engine: engine)
      expect(result[:found]).to be(false)
    end

    it 'returns found: true when a category exists' do
      client.present_input(input: [0.8, 0.6], engine: engine)
      result = client.classify(input: [0.8, 0.6], engine: engine)
      expect(result[:found]).to be(true)
    end

    it 'returns category_id and quality when found' do
      client.present_input(input: [0.8, 0.6], engine: engine)
      result = client.classify(input: [0.8, 0.6], engine: engine)
      expect(result[:category_id]).to be_a(String)
      expect(result[:quality]).to be_between(0.0, 1.0)
    end

    it 'returns a label' do
      client.present_input(input: [0.8, 0.6], engine: engine)
      result = client.classify(input: [0.8, 0.6], engine: engine)
      expect(result[:label]).to be_a(Symbol)
    end

    it 'returns :none label when not found' do
      result = client.classify(input: [0.5, 0.5], engine: engine)
      expect(result[:label]).to eq(:none)
    end

    it 'returns quality: 0.0 and category_id: nil when not found' do
      result = client.classify(input: [0.5, 0.5], engine: engine)
      expect(result[:quality]).to eq(0.0)
      expect(result[:category_id]).to be_nil
    end
  end

  describe '#adjust_vigilance' do
    it 'returns success: true' do
      result = client.adjust_vigilance(amount: 0.1)
      expect(result[:success]).to be(true)
    end

    it 'returns the new vigilance value' do
      result = client.adjust_vigilance(amount: 0.1, engine: engine)
      expect(result[:vigilance]).to be_between(0.0, 1.0)
    end

    it 'returns the vigilance_label' do
      result = client.adjust_vigilance(amount: 0.0, engine: engine)
      expect(result[:vigilance_label]).to be_a(Symbol)
    end

    it 'returns the clamped adjustment amount' do
      result = client.adjust_vigilance(amount: 0.05, engine: engine)
      expect(result[:adjustment]).to eq(0.05)
    end

    it 'clamps amount to [-1.0, 1.0]' do
      result = client.adjust_vigilance(amount: 999.0, engine: engine)
      expect(result[:adjustment]).to eq(1.0)
    end

    it 'increases vigilance' do
      original = engine.vigilance
      client.adjust_vigilance(amount: 0.1, engine: engine)
      expect(engine.vigilance).to be > original
    end

    it 'decreases vigilance' do
      original = engine.vigilance
      client.adjust_vigilance(amount: -0.1, engine: engine)
      expect(engine.vigilance).to be < original
    end
  end

  describe '#resonance_report' do
    before { client.present_input(input: [0.8, 0.6, 0.4]) }

    it 'returns success: true' do
      expect(client.resonance_report[:success]).to be(true)
    end

    it 'includes category_count' do
      expect(client.resonance_report[:category_count]).to be >= 1
    end

    it 'includes vigilance' do
      expect(client.resonance_report[:vigilance]).to be_between(0.0, 1.0)
    end

    it 'includes vigilance_label' do
      expect(client.resonance_report[:vigilance_label]).to be_a(Symbol)
    end

    it 'includes categories array' do
      expect(client.resonance_report[:categories]).to be_an(Array)
    end

    it 'uses injected engine' do
      engine2 = Legion::Extensions::CognitiveResonance::Helpers::ResonanceEngine.new
      report = client.resonance_report(engine: engine2)
      expect(report[:category_count]).to eq(0)
    end
  end

  describe '#category_count' do
    it 'returns success: true' do
      expect(client.category_count[:success]).to be(true)
    end

    it 'returns 0 for fresh engine' do
      expect(client.category_count(engine: engine)[:count]).to eq(0)
    end

    it 'returns the correct count after adding categories' do
      client.present_input(input: [0.8, 0.6], engine: engine)
      client.present_input(input: [0.1, 0.9], engine: engine)
      expect(client.category_count(engine: engine)[:count]).to eq(2)
    end
  end

  describe '#reset_engine' do
    it 'returns success: true' do
      expect(client.reset_engine[:success]).to be(true)
    end

    it 'resets the default engine' do
      client.present_input(input: [0.8, 0.6, 0.4])
      client.reset_engine
      expect(client.category_count[:count]).to eq(0)
    end
  end
end
