# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveResonance
      module Helpers
        class ResonanceEngine
          attr_reader :vigilance

          def initialize(vigilance: Constants::DEFAULT_VIGILANCE)
            @vigilance  = vigilance.clamp(0.0, 1.0)
            @categories = {}
          end

          def present_input(input:)
            normalized = input.map { |v| v.to_f.clamp(0.0, 1.0) }

            match = best_match(normalized)

            if match && match[:quality] >= @vigilance
              category = @categories[match[:id]]
              category.update_prototype!(input: normalized)

              Legion::Logging.debug "[cognitive_resonance] resonance with category #{match[:id][0..7]} " \
                                    "quality=#{match[:quality].round(3)} vigilance=#{@vigilance.round(3)}"

              {
                outcome:     :resonance,
                category_id: match[:id],
                quality:     match[:quality],
                label:       Constants.match_label(match[:quality]),
                created:     false
              }
            else
              prune_if_full!
              category = Category.new(prototype: normalized)
              @categories[category.id] = category

              Legion::Logging.debug "[cognitive_resonance] new category #{category.id[0..7]} " \
                                    "total=#{@categories.size} vigilance=#{@vigilance.round(3)}"

              {
                outcome:     :new_category,
                category_id: category.id,
                quality:     match ? match[:quality] : 0.0,
                label:       :new,
                created:     true
              }
            end
          end

          def best_match(input)
            return nil if @categories.empty?

            normalized = input.map { |v| v.to_f.clamp(0.0, 1.0) }
            best = nil

            @categories.each_value do |category|
              quality = category.match_quality(input: normalized)
              next unless best.nil? || quality > best[:quality]

              best = { id: category.id, quality: quality }
            end

            best
          end

          def adjust_vigilance(amount:)
            @vigilance = (@vigilance + amount).clamp(0.0, 1.0)
            Legion::Logging.debug "[cognitive_resonance] vigilance adjusted to #{@vigilance.round(3)}"
            @vigilance
          end

          def category_count
            @categories.size
          end

          def resonance_report
            vigilance_lbl = Constants.vigilance_label(@vigilance)
            {
              category_count:  @categories.size,
              vigilance:       @vigilance,
              vigilance_label: vigilance_lbl,
              categories:      @categories.values.map(&:to_h)
            }
          end

          def to_h
            {
              vigilance:      @vigilance,
              category_count: @categories.size
            }
          end

          private

          def prune_if_full!
            return unless @categories.size >= Constants::MAX_CATEGORIES

            oldest_id = @categories.min_by { |_, cat| cat.last_matched_at || Time.at(0) }.first
            @categories.delete(oldest_id)
            Legion::Logging.debug "[cognitive_resonance] pruned oldest category #{oldest_id[0..7]}"
          end
        end
      end
    end
  end
end
