# lex-cognitive-resonance

A LegionIO cognitive architecture extension that models pattern recognition using Adaptive Resonance Theory (ART). Input vectors either resonate with known categories or create new ones, controlled by a vigilance parameter that sets the discrimination threshold.

## What It Does

Maintains a registry of **categories**, each represented as a prototype float vector. When a new input is presented:

- If it matches an existing category above the vigilance threshold, the prototype is updated toward the input (learning)
- If no category meets the threshold, a new category is created (novelty detection)

The vigilance parameter controls granularity: high vigilance produces many narrow categories; low vigilance produces fewer, broader ones.

## Usage

```ruby
require 'lex-cognitive-resonance'

client = Legion::Extensions::CognitiveResonance::Client.new

# Present an input vector (normalized 0.0..1.0 floats)
result = client.present_input(input: [0.8, 0.6, 0.4, 0.9])
# => { success: true, outcome: :new_category, category_id: "uuid...", quality: 0.0, label: :new, created: true }

# Present a similar input — resonates with the existing category
result = client.present_input(input: [0.75, 0.65, 0.45, 0.85])
# => { success: true, outcome: :resonance, category_id: "uuid...", quality: 0.94, label: :perfect, created: false }

# Classify without modifying state
result = client.classify(input: [0.8, 0.6, 0.4, 0.9])
# => { success: true, found: true, category_id: "uuid...", quality: 0.99, label: :perfect }

# Tighten vigilance for finer discrimination
client.adjust_vigilance(amount: 0.1)
# => { success: true, vigilance: 0.8, vigilance_label: :medium, adjustment: 0.1 }

# Full report
client.resonance_report
# => { success: true, category_count: 3, vigilance: 0.8, vigilance_label: :medium, categories: [...] }

# How many categories exist
client.category_count
# => { success: true, count: 3 }

# Reset the engine (clears all categories)
client.reset_engine
# => { success: true, reset: true }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
