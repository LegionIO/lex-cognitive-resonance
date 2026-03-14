# lex-cognitive-resonance

Adaptive Resonance Theory (ART) for brain-modeled agentic AI. Models how input patterns match against stored category prototypes through a bidirectional resonance cycle.

## Installation

Add to your Gemfile:

```ruby
gem 'lex-cognitive-resonance'
```

## Usage

```ruby
client = Legion::Extensions::CognitiveResonance::Client.new

# Present an input pattern — creates or updates a category
result = client.present_input(input: [0.8, 0.6, 0.4])
# => { success: true, outcome: :new_category, category_id: "uuid", quality: 0.0, label: :new, created: true }

# Present again — resonates with existing category
result = client.present_input(input: [0.8, 0.6, 0.4])
# => { success: true, outcome: :resonance, category_id: "uuid", quality: 0.99, label: :perfect, created: false }

# Classify without learning
result = client.classify(input: [0.7, 0.5, 0.3])
# => { success: true, found: true, category_id: "uuid", quality: 0.97, label: :perfect }

# Adjust vigilance (higher = more categories, finer distinctions)
client.adjust_vigilance(amount: 0.1)

# Get a full report
client.resonance_report
```

## License

MIT
