# frozen_string_literal: true

require 'legion/extensions/cognitive_resonance/helpers/constants'
require 'legion/extensions/cognitive_resonance/helpers/category'
require 'legion/extensions/cognitive_resonance/helpers/resonance_engine'
require 'legion/extensions/cognitive_resonance/runners/cognitive_resonance'

module Legion
  module Extensions
    module CognitiveResonance
      class Client
        include Runners::CognitiveResonance

        def initialize(**)
          @default_engine = Helpers::ResonanceEngine.new
        end
      end
    end
  end
end
