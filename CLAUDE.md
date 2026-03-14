# lex-cognitive-resonance

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-resonance`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveResonance`

## Purpose

Models cognitive pattern recognition using Adaptive Resonance Theory (ART). Inputs (normalized float vectors) are presented to the engine, which either resonates with an existing category (if match quality meets vigilance) or creates a new one. Categories are prototype vectors updated incrementally via a learning rate. This models how biological recognition systems balance plasticity (learning new patterns) against stability (not overwriting existing ones).

## Gem Info

- **Gemspec**: `lex-cognitive-resonance.gemspec`
- **Require**: `lex-cognitive-resonance`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-resonance

## File Structure

```
lib/legion/extensions/cognitive_resonance/
  version.rb
  helpers/
    constants.rb         # Vigilance defaults, match/vigilance label tables
    category.rb          # Category class — prototype vector with cosine similarity matching
    resonance_engine.rb  # ResonanceEngine — manages categories, vigilance, ART cycle
  runners/
    cognitive_resonance.rb  # Runner module — public API
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `DEFAULT_VIGILANCE` | 0.7 | Minimum match quality to resonate with an existing category |
| `MAX_CATEGORIES` | 200 | Hard cap; oldest (by `last_matched_at`) is pruned when full |
| `RESONANCE_THRESHOLD` | 0.6 | Reference threshold (used for match label boundary) |
| `DEFAULT_LEARNING_RATE` | 0.2 | How much a matching input shifts the prototype toward itself |

Match quality labels (from `Constants.match_label`):
- `0.9+` = `:perfect`, `0.75..0.9` = `:strong`, `0.6..0.75` = `:moderate`, `0.4..0.6` = `:weak`, `<0.4` = `:mismatch`

Vigilance labels (from `Constants.vigilance_label`):
- `0.85+` = `:fine`, `0.65..0.85` = `:medium`, `0.4..0.65` = `:coarse`, `<0.4` = `:very_coarse`

## Key Classes

### `Helpers::Category`

A single recognized pattern stored as a prototype float vector.

- `initialize(prototype:)` — clamps all values to `[0.0, 1.0]`; generates UUID id
- `match_quality(input:)` — cosine similarity between prototype and input; returns `0.0..1.0`
- `update_prototype!(input:, learning_rate:)` — Hebbian-style interpolation: `proto += rate * (input - proto)`; increments `match_count`, sets `last_matched_at`
- `to_h` — includes `id`, `prototype`, `match_count`, `last_matched_at`, `dimensions`

Vectors of different lengths are handled by truncating to the shorter length for similarity, and extending to the longer length during prototype update.

### `Helpers::ResonanceEngine`

Manages the full ART cycle — category registry, vigilance, resonance vs. novelty decisions.

- `present_input(input:)` — normalizes input, finds `best_match`, resonates if quality >= vigilance, else creates new category; calls `prune_if_full!` before creation
- `best_match(input)` — scans all categories, returns `{ id:, quality: }` for highest cosine similarity; returns `nil` if no categories exist
- `adjust_vigilance(amount:)` — adds amount (clamped to `[-1.0, 1.0]`) to current vigilance
- `category_count` — integer count of registered categories
- `resonance_report` — full report with `category_count`, `vigilance`, `vigilance_label`, `categories` array
- `prune_if_full!` (private) — evicts category with oldest `last_matched_at` when at `MAX_CATEGORIES`

`present_input` returns:
- On resonance: `{ outcome: :resonance, category_id:, quality:, label:, created: false }`
- On new category: `{ outcome: :new_category, category_id:, quality: (prior match or 0.0), label: :new, created: true }`

## Runners

Module: `Legion::Extensions::CognitiveResonance::Runners::CognitiveResonance`

| Runner | Key Args | Returns |
|---|---|---|
| `present_input` | `input:` (float array) | `{ success:, outcome:, category_id:, quality:, label:, created: }` |
| `classify` | `input:` (float array) | `{ success:, found:, category_id:, quality:, label: }` |
| `adjust_vigilance` | `amount:` (float) | `{ success:, vigilance:, vigilance_label:, adjustment: }` |
| `resonance_report` | — | `{ success:, category_count:, vigilance:, vigilance_label:, categories: }` |
| `category_count` | — | `{ success:, count: }` |
| `reset_engine` | — | `{ success:, reset: true }` |

`classify` differs from `present_input`: it looks up the best match without updating the prototype or creating a new category. `present_input` always modifies state (either updates or creates). All runners accept optional `engine:` keyword for test injection.

## Integration Points

- No actors defined; driven entirely by external calls
- Inputs are float arrays (normalized `0.0..1.0`); the embedding format is caller-defined
- Vigilance adjustment enables dynamic sensitivity: tighten for fine-grained discrimination, loosen for generalization
- Can be paired with `lex-cortex` phase handlers to classify sensory or memory embeddings each tick
- All state is in-memory per `ResonanceEngine` instance; reset via `reset_engine`

## Development Notes

- `classify` does NOT update prototypes; it is read-only. Use `present_input` for learning
- Cosine similarity truncates to shorter vector length; inputs must use consistent dimensionality for reliable matching
- When at `MAX_CATEGORIES`, the oldest-by-last_matched_at category is evicted, not the lowest-quality one — recency wins over quality in the pruning heuristic
- `present_input` with `input: []` returns `{ success: false, error: :empty_input }` before touching the engine
- `adjust_vigilance(amount:)` in the runner clamps `amount` to `[-1.0, 1.0]` before delegating to the engine
