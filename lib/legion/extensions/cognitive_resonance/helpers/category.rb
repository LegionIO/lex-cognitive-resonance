# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveResonance
      module Helpers
        class Category
          attr_reader :id, :prototype, :match_count, :last_matched_at

          def initialize(prototype:)
            @id              = SecureRandom.uuid
            @prototype       = prototype.map { |v| v.to_f.clamp(0.0, 1.0) }
            @match_count     = 0
            @last_matched_at = nil
          end

          def match_quality(input:)
            return 0.0 if @prototype.empty? || input.empty?

            len          = [@prototype.size, input.size].min
            proto_slice  = @prototype.first(len)
            input_slice  = input.first(len).map { |v| v.to_f.clamp(0.0, 1.0) }
            cosine_similarity(proto_slice, input_slice)
          end

          def update_prototype!(input:, learning_rate: Constants::DEFAULT_LEARNING_RATE)
            rate = learning_rate.clamp(0.0, 1.0)
            input_normalized = input.map { |v| v.to_f.clamp(0.0, 1.0) }

            len = [@prototype.size, input_normalized.size].max
            updated = Array.new(len) do |i|
              proto_val = @prototype[i] || 0.0
              input_val = input_normalized[i] || 0.0
              (proto_val + (rate * (input_val - proto_val))).round(10).clamp(0.0, 1.0)
            end

            @prototype = updated
            @match_count += 1
            @last_matched_at = Time.now.utc
            self
          end

          private

          def cosine_similarity(proto_slice, input_slice)
            dot       = proto_slice.zip(input_slice).sum { |a, b| (a * b).round(10) }
            mag_proto = Math.sqrt(proto_slice.sum { |v| (v**2).round(10) })
            mag_input = Math.sqrt(input_slice.sum { |v| (v**2).round(10) })
            return 0.0 if mag_proto.zero? || mag_input.zero?

            (dot / (mag_proto * mag_input)).clamp(0.0, 1.0).round(10)
          end

          public

          def to_h
            {
              id:              @id,
              prototype:       @prototype,
              match_count:     @match_count,
              last_matched_at: @last_matched_at,
              dimensions:      @prototype.size
            }
          end
        end
      end
    end
  end
end
