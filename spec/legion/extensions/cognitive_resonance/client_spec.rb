# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveResonance::Client do
  let(:client) { described_class.new }

  it 'responds to present_input' do
    expect(client).to respond_to(:present_input)
  end

  it 'responds to classify' do
    expect(client).to respond_to(:classify)
  end

  it 'responds to adjust_vigilance' do
    expect(client).to respond_to(:adjust_vigilance)
  end

  it 'responds to resonance_report' do
    expect(client).to respond_to(:resonance_report)
  end

  it 'responds to category_count' do
    expect(client).to respond_to(:category_count)
  end

  it 'responds to reset_engine' do
    expect(client).to respond_to(:reset_engine)
  end

  it 'round-trips a full resonance cycle' do
    # Present a pattern and create a category
    r1 = client.present_input(input: [0.9, 0.8, 0.7])
    expect(r1[:outcome]).to eq(:new_category)

    # Present same pattern — should resonate
    r2 = client.present_input(input: [0.9, 0.8, 0.7])
    expect(r2[:outcome]).to eq(:resonance)

    # Classify the same pattern
    c = client.classify(input: [0.9, 0.8, 0.7])
    expect(c[:found]).to be(true)
    expect(c[:quality]).to be > 0.9

    # Get a report
    report = client.resonance_report
    expect(report[:category_count]).to be >= 1

    # Adjust vigilance
    v = client.adjust_vigilance(amount: 0.05)
    expect(v[:success]).to be(true)
  end

  it 'each client instance has its own engine' do
    c1 = described_class.new
    c2 = described_class.new
    c1.present_input(input: [0.5, 0.5])
    expect(c1.category_count[:count]).to eq(1)
    expect(c2.category_count[:count]).to eq(0)
  end

  it 'reset_engine clears categories' do
    client.present_input(input: [0.5, 0.5])
    client.reset_engine
    expect(client.category_count[:count]).to eq(0)
  end
end
