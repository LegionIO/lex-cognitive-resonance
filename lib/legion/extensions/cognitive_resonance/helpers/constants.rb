# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveResonance
      module Helpers
        module Constants
          DEFAULT_VIGILANCE    = 0.7
          MAX_CATEGORIES       = 200
          RESONANCE_THRESHOLD  = 0.6
          DEFAULT_LEARNING_RATE = 0.2

          MATCH_LABELS = [
            { range: (0.9..1.0), label: :perfect },
            { range: (0.75..0.9), label: :strong },
            { range: (0.6..0.75), label: :moderate },
            { range: (0.4..0.6), label: :weak },
            { range: (0.0..0.4), label: :mismatch }
          ].freeze

          VIGILANCE_LABELS = [
            { range: (0.85..1.0), label: :fine },
            { range: (0.65..0.85), label: :medium },
            { range: (0.4..0.65), label: :coarse },
            { range: (0.0..0.4), label: :very_coarse }
          ].freeze

          module_function

          def match_label(quality)
            entry = MATCH_LABELS.find { |e| e[:range].cover?(quality) }
            entry ? entry[:label] : :mismatch
          end

          def vigilance_label(vigilance)
            entry = VIGILANCE_LABELS.find { |e| e[:range].cover?(vigilance) }
            entry ? entry[:label] : :very_coarse
          end
        end
      end
    end
  end
end
