# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveResonance::Helpers::ResonanceEngine do
  subject(:engine) { described_class.new }

  describe '#initialize' do
    it 'starts with default vigilance' do
      expect(engine.vigilance).to eq(Legion::Extensions::CognitiveResonance::Helpers::Constants::DEFAULT_VIGILANCE)
    end

    it 'starts with zero categories' do
      expect(engine.category_count).to eq(0)
    end

    it 'accepts custom vigilance' do
      e = described_class.new(vigilance: 0.9)
      expect(e.vigilance).to eq(0.9)
    end

    it 'clamps vigilance to [0, 1]' do
      e = described_class.new(vigilance: 1.5)
      expect(e.vigilance).to eq(1.0)
    end
  end

  describe '#present_input' do
    let(:input) { [0.8, 0.6, 0.4] }

    it 'creates a new category for the first input' do
      result = engine.present_input(input: input)
      expect(result[:outcome]).to eq(:new_category)
      expect(result[:created]).to be(true)
      expect(result[:category_id]).to be_a(String)
    end

    it 'increments category count after first input' do
      engine.present_input(input: input)
      expect(engine.category_count).to eq(1)
    end

    it 'resonates with an identical second input' do
      engine.present_input(input: input)
      result = engine.present_input(input: input)
      expect(result[:outcome]).to eq(:resonance)
      expect(result[:created]).to be(false)
    end

    it 'creates a new category for dissimilar input at high vigilance' do
      high_engine = described_class.new(vigilance: 0.99)
      high_engine.present_input(input: [1.0, 0.0, 0.0])
      result = high_engine.present_input(input: [0.0, 1.0, 0.0])
      expect(result[:outcome]).to eq(:new_category)
    end

    it 'resonates with similar input at low vigilance' do
      low_engine = described_class.new(vigilance: 0.1)
      low_engine.present_input(input: [0.8, 0.6, 0.4])
      result = low_engine.present_input(input: [0.7, 0.5, 0.3])
      expect(result[:outcome]).to eq(:resonance)
    end

    it 'returns a quality score' do
      engine.present_input(input: input)
      result = engine.present_input(input: input)
      expect(result[:quality]).to be_between(0.0, 1.0)
    end

    it 'returns a match label' do
      engine.present_input(input: input)
      result = engine.present_input(input: input)
      expect(result[:label]).to be_a(Symbol)
    end

    it 'returns :new for label when creating a category' do
      result = engine.present_input(input: input)
      expect(result[:label]).to eq(:new)
    end
  end

  describe '#best_match' do
    it 'returns nil when no categories exist' do
      expect(engine.best_match([0.5, 0.5])).to be_nil
    end

    it 'returns a match hash with id and quality' do
      engine.present_input(input: [0.8, 0.6])
      match = engine.best_match([0.8, 0.6])
      expect(match).to include(:id, :quality)
    end

    it 'returns best quality match when multiple categories exist' do
      engine.present_input(input: [1.0, 0.0])
      engine.present_input(input: [0.0, 1.0])
      match = engine.best_match([1.0, 0.0])
      expect(match[:quality]).to be_within(0.01).of(1.0)
    end
  end

  describe '#adjust_vigilance' do
    it 'increases vigilance' do
      original = engine.vigilance
      engine.adjust_vigilance(amount: 0.1)
      expect(engine.vigilance).to be_within(0.001).of(original + 0.1)
    end

    it 'decreases vigilance' do
      original = engine.vigilance
      engine.adjust_vigilance(amount: -0.1)
      expect(engine.vigilance).to be_within(0.001).of(original - 0.1)
    end

    it 'clamps vigilance at 1.0' do
      engine.adjust_vigilance(amount: 999.0)
      expect(engine.vigilance).to eq(1.0)
    end

    it 'clamps vigilance at 0.0' do
      engine.adjust_vigilance(amount: -999.0)
      expect(engine.vigilance).to eq(0.0)
    end

    it 'returns the new vigilance value' do
      result = engine.adjust_vigilance(amount: 0.05)
      expect(result).to eq(engine.vigilance)
    end
  end

  describe '#category_count' do
    it 'returns 0 initially' do
      expect(engine.category_count).to eq(0)
    end

    it 'increments when new categories are created' do
      engine.present_input(input: [1.0, 0.0])
      engine.present_input(input: [0.0, 1.0])
      expect(engine.category_count).to eq(2)
    end
  end

  describe '#resonance_report' do
    before do
      engine.present_input(input: [0.8, 0.6])
      engine.present_input(input: [0.2, 0.4])
    end

    it 'includes category_count' do
      expect(engine.resonance_report[:category_count]).to eq(engine.category_count)
    end

    it 'includes vigilance' do
      expect(engine.resonance_report[:vigilance]).to eq(engine.vigilance)
    end

    it 'includes vigilance_label' do
      expect(engine.resonance_report[:vigilance_label]).to be_a(Symbol)
    end

    it 'includes categories array' do
      report = engine.resonance_report
      expect(report[:categories]).to be_an(Array)
      expect(report[:categories].size).to eq(engine.category_count)
    end

    it 'returns each category as a hash with id and prototype' do
      report = engine.resonance_report
      report[:categories].each do |cat|
        expect(cat).to include(:id, :prototype, :match_count)
      end
    end
  end

  describe '#to_h' do
    it 'includes vigilance and category_count' do
      expect(engine.to_h).to include(:vigilance, :category_count)
    end
  end

  describe 'MAX_CATEGORIES pruning' do
    let(:max) { Legion::Extensions::CognitiveResonance::Helpers::Constants::MAX_CATEGORIES }

    it 'does not exceed MAX_CATEGORIES' do
      high_engine = described_class.new(vigilance: 1.0)
      (max + 10).times do |i|
        high_engine.present_input(input: [i.to_f / (max + 10), 0.0])
      end
      expect(high_engine.category_count).to be <= max
    end
  end
end
