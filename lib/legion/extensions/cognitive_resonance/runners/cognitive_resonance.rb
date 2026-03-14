# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveResonance
      module Runners
        module CognitiveResonance
          include Helpers::Constants
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def present_input(input:, engine: nil, **)
            resonance_engine = engine || default_engine
            return { success: false, error: :empty_input } if input.nil? || input.empty?

            result = resonance_engine.present_input(input: input)
            Legion::Logging.debug "[cognitive_resonance] present_input outcome=#{result[:outcome]} " \
                                  "category=#{result[:category_id][0..7]}"
            { success: true }.merge(result)
          end

          def classify(input:, engine: nil, **)
            resonance_engine = engine || default_engine
            return { success: false, error: :empty_input } if input.nil? || input.empty?

            normalized = input.map { |v| v.to_f.clamp(0.0, 1.0) }
            match = resonance_engine.best_match(normalized)

            if match
              quality_label = Constants.match_label(match[:quality])
              Legion::Logging.debug "[cognitive_resonance] classify category=#{match[:id][0..7]} " \
                                    "quality=#{match[:quality].round(3)} label=#{quality_label}"
              {
                success:     true,
                found:       true,
                category_id: match[:id],
                quality:     match[:quality],
                label:       quality_label
              }
            else
              Legion::Logging.debug '[cognitive_resonance] classify found=false (no categories)'
              { success: true, found: false, category_id: nil, quality: 0.0, label: :none }
            end
          end

          def adjust_vigilance(amount:, engine: nil, **)
            resonance_engine = engine || default_engine
            clamped_amount   = amount.to_f.clamp(-1.0, 1.0)
            new_vigilance    = resonance_engine.adjust_vigilance(amount: clamped_amount)
            vigilance_label  = Constants.vigilance_label(new_vigilance)

            Legion::Logging.debug "[cognitive_resonance] vigilance=#{new_vigilance.round(3)} label=#{vigilance_label}"
            {
              success:         true,
              vigilance:       new_vigilance,
              vigilance_label: vigilance_label,
              adjustment:      clamped_amount
            }
          end

          def resonance_report(engine: nil, **)
            resonance_engine = engine || default_engine
            report = resonance_engine.resonance_report
            Legion::Logging.debug "[cognitive_resonance] report categories=#{report[:category_count]} " \
                                  "vigilance=#{report[:vigilance].round(3)}"
            { success: true }.merge(report)
          end

          def category_count(engine: nil, **)
            resonance_engine = engine || default_engine
            count = resonance_engine.category_count
            Legion::Logging.debug "[cognitive_resonance] category_count=#{count}"
            { success: true, count: count }
          end

          def reset_engine(**)
            @default_engine = nil
            Legion::Logging.debug '[cognitive_resonance] engine reset'
            { success: true, reset: true }
          end

          private

          def default_engine
            @default_engine ||= Helpers::ResonanceEngine.new
          end
        end
      end
    end
  end
end
