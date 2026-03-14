# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_resonance/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-resonance'
  spec.version       = Legion::Extensions::CognitiveResonance::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Resonance'
  spec.description   = 'Adaptive Resonance Theory for brain-modeled agentic AI — bidirectional resonance cycle with vigilance-controlled category learning'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-resonance'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-resonance'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-resonance'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-resonance'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-resonance/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-cognitive-resonance.gemspec Gemfile LICENSE README.md]
  end
  spec.require_paths = ['lib']
end
