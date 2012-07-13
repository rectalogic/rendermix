require 'spec_helper'
require 'rendermix/effect/shared_examples_for_effect'

module RenderMix
  module Effect
    describe Cinematic do
      it_should_behave_like 'a transition effect' do
        let(:effect_type) { 'visual' }
        let(:effect) { Cinematic.new('TestEffects/Cinematic/manifest.json', %w(SourceVideo TargetVideo), "Title" => "the transition title" ) }
      end

      it_should_behave_like 'a filter effect' do
        let(:effect_type) { 'visual' }
        let(:effect) { Cinematic.new('TestEffects/Cinematic/manifest.json', %w(SourceVideo), "Title" => "the filter title") }
      end
    end
  end
end
