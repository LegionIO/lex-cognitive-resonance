# frozen_string_literal: true

require 'legion/extensions/cognitive_resonance/version'
require 'legion/extensions/cognitive_resonance/helpers/constants'
require 'legion/extensions/cognitive_resonance/helpers/category'
require 'legion/extensions/cognitive_resonance/helpers/resonance_engine'
require 'legion/extensions/cognitive_resonance/runners/cognitive_resonance'
require 'legion/extensions/cognitive_resonance/client'

module Legion
  module Extensions
    module CognitiveResonance
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
