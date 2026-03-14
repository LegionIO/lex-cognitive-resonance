# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveResonance do
  it 'defines VERSION' do
    expect(described_class::VERSION).to eq('0.1.0')
  end

  it 'provides the Client class' do
    expect(described_class::Client).to be_a(Class)
  end

  it 'provides Helpers::Constants module' do
    expect(described_class::Helpers::Constants).to be_a(Module)
  end

  it 'provides Helpers::Category class' do
    expect(described_class::Helpers::Category).to be_a(Class)
  end

  it 'provides Helpers::ResonanceEngine class' do
    expect(described_class::Helpers::ResonanceEngine).to be_a(Class)
  end

  it 'provides Runners::CognitiveResonance module' do
    expect(described_class::Runners::CognitiveResonance).to be_a(Module)
  end
end
