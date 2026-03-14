# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveResonance::Helpers::Category do
  let(:prototype) { [0.8, 0.6, 0.4] }
  subject(:category) { described_class.new(prototype: prototype) }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(category.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'normalizes prototype values to [0, 1]' do
      cat = described_class.new(prototype: [1.5, -0.2, 0.5])
      expect(cat.prototype).to eq([1.0, 0.0, 0.5])
    end

    it 'starts with match_count of 0' do
      expect(category.match_count).to eq(0)
    end

    it 'starts with last_matched_at nil' do
      expect(category.last_matched_at).to be_nil
    end

    it 'stores prototype as floats' do
      expect(category.prototype).to all(be_a(Float))
    end
  end

  describe '#match_quality' do
    it 'returns 1.0 for identical input' do
      quality = category.match_quality(input: prototype)
      expect(quality).to be_within(0.001).of(1.0)
    end

    it 'returns 0.0 for empty prototype' do
      cat = described_class.new(prototype: [])
      expect(cat.match_quality(input: [0.5, 0.5])).to eq(0.0)
    end

    it 'returns 0.0 for empty input' do
      expect(category.match_quality(input: [])).to eq(0.0)
    end

    it 'returns a value between 0 and 1 for partial matches' do
      quality = category.match_quality(input: [0.2, 0.1, 0.9])
      expect(quality).to be_between(0.0, 1.0)
    end

    it 'returns lower quality for orthogonal vectors' do
      cat = described_class.new(prototype: [1.0, 0.0])
      quality = cat.match_quality(input: [0.0, 1.0])
      expect(quality).to be < 0.3
    end

    it 'handles inputs shorter than prototype' do
      quality = category.match_quality(input: [0.8])
      expect(quality).to be_between(0.0, 1.0)
    end

    it 'handles inputs longer than prototype' do
      quality = category.match_quality(input: [0.8, 0.6, 0.4, 0.9])
      expect(quality).to be_within(0.001).of(1.0)
    end

    it 'clamps input values before computing' do
      quality_normal = category.match_quality(input: [0.8, 0.6, 0.4])
      quality_clamped = category.match_quality(input: [2.0, 1.5, 0.4])
      expect(quality_clamped).to be_between(0.0, 1.0)
      expect(quality_normal).to be_within(0.001).of(1.0)
    end
  end

  describe '#update_prototype!' do
    it 'returns self' do
      result = category.update_prototype!(input: [0.9, 0.7, 0.5])
      expect(result).to be(category)
    end

    it 'increments match_count' do
      category.update_prototype!(input: [0.9, 0.7, 0.5])
      expect(category.match_count).to eq(1)
    end

    it 'sets last_matched_at' do
      before = Time.now.utc
      category.update_prototype!(input: [0.9, 0.7, 0.5])
      expect(category.last_matched_at).to be >= before
    end

    it 'moves prototype toward input with default learning rate' do
      original = category.prototype.dup
      category.update_prototype!(input: [1.0, 1.0, 1.0])
      expect(category.prototype[0]).to be > original[0]
    end

    it 'uses provided learning rate' do
      category.update_prototype!(input: [1.0, 1.0, 1.0], learning_rate: 1.0)
      expect(category.prototype).to eq([1.0, 1.0, 1.0])
    end

    it 'clamps learning rate to [0, 1]' do
      expect { category.update_prototype!(input: [0.5, 0.5, 0.5], learning_rate: 2.0) }.not_to raise_error
      expect(category.prototype).to all(be_between(0.0, 1.0))
    end

    it 'clamps prototype values to [0, 1] after update' do
      cat = described_class.new(prototype: [0.95, 0.95])
      cat.update_prototype!(input: [1.5, 1.5], learning_rate: 1.0)
      expect(cat.prototype).to all(be <= 1.0)
    end

    it 'expands prototype if input is longer' do
      cat = described_class.new(prototype: [0.5, 0.5])
      cat.update_prototype!(input: [0.5, 0.5, 0.8])
      expect(cat.prototype.size).to eq(3)
    end
  end

  describe '#to_h' do
    it 'includes id' do
      expect(category.to_h[:id]).to eq(category.id)
    end

    it 'includes prototype' do
      expect(category.to_h[:prototype]).to eq(category.prototype)
    end

    it 'includes match_count' do
      expect(category.to_h[:match_count]).to eq(0)
    end

    it 'includes last_matched_at' do
      expect(category.to_h).to have_key(:last_matched_at)
    end

    it 'includes dimensions' do
      expect(category.to_h[:dimensions]).to eq(3)
    end

    it 'reflects updated match_count after update' do
      category.update_prototype!(input: [0.5, 0.5, 0.5])
      expect(category.to_h[:match_count]).to eq(1)
    end
  end
end
