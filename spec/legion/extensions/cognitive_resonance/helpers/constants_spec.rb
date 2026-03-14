# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveResonance::Helpers::Constants do
  describe 'DEFAULT_VIGILANCE' do
    it 'is 0.7' do
      expect(described_class::DEFAULT_VIGILANCE).to eq(0.7)
    end
  end

  describe 'MAX_CATEGORIES' do
    it 'is 200' do
      expect(described_class::MAX_CATEGORIES).to eq(200)
    end
  end

  describe 'RESONANCE_THRESHOLD' do
    it 'is 0.6' do
      expect(described_class::RESONANCE_THRESHOLD).to eq(0.6)
    end
  end

  describe 'DEFAULT_LEARNING_RATE' do
    it 'is 0.2' do
      expect(described_class::DEFAULT_LEARNING_RATE).to eq(0.2)
    end
  end

  describe 'MATCH_LABELS' do
    it 'is a frozen array' do
      expect(described_class::MATCH_LABELS).to be_frozen
    end

    it 'has 5 entries' do
      expect(described_class::MATCH_LABELS.size).to eq(5)
    end

    it 'includes a :perfect entry for high quality' do
      entry = described_class::MATCH_LABELS.find { |e| e[:label] == :perfect }
      expect(entry[:range]).to cover(0.95)
    end
  end

  describe 'VIGILANCE_LABELS' do
    it 'is a frozen array' do
      expect(described_class::VIGILANCE_LABELS).to be_frozen
    end

    it 'has 4 entries' do
      expect(described_class::VIGILANCE_LABELS.size).to eq(4)
    end
  end

  describe '.match_label' do
    it 'returns :perfect for quality >= 0.9' do
      expect(described_class.match_label(0.95)).to eq(:perfect)
    end

    it 'returns :strong for quality in 0.75..0.9' do
      expect(described_class.match_label(0.8)).to eq(:strong)
    end

    it 'returns :moderate for quality in 0.6..0.75' do
      expect(described_class.match_label(0.65)).to eq(:moderate)
    end

    it 'returns :weak for quality in 0.4..0.6' do
      expect(described_class.match_label(0.5)).to eq(:weak)
    end

    it 'returns :mismatch for quality below 0.4' do
      expect(described_class.match_label(0.2)).to eq(:mismatch)
    end

    it 'returns :mismatch for quality = 0.0' do
      expect(described_class.match_label(0.0)).to eq(:mismatch)
    end

    it 'returns :perfect for quality = 1.0' do
      expect(described_class.match_label(1.0)).to eq(:perfect)
    end
  end

  describe '.vigilance_label' do
    it 'returns :fine for vigilance >= 0.85' do
      expect(described_class.vigilance_label(0.9)).to eq(:fine)
    end

    it 'returns :medium for vigilance in 0.65..0.85' do
      expect(described_class.vigilance_label(0.7)).to eq(:medium)
    end

    it 'returns :coarse for vigilance in 0.4..0.65' do
      expect(described_class.vigilance_label(0.5)).to eq(:coarse)
    end

    it 'returns :very_coarse for vigilance below 0.4' do
      expect(described_class.vigilance_label(0.2)).to eq(:very_coarse)
    end

    it 'returns :very_coarse for vigilance = 0.0' do
      expect(described_class.vigilance_label(0.0)).to eq(:very_coarse)
    end
  end
end
