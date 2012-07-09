require 'spec_helper'
require 'rendermix/effect/shared_examples_for_effect'

module RenderMix
  module Effect
    describe ImageProcessor do
      it_should_behave_like 'a transition effect' do
        let(:effect_type) { 'visual' }
        let(:effect) { ImageProcessor.new('TestEffects/ImageProcessor/ImageProcessor.j3m', %w(SourceTex TargetTex)) }
      end

      it_should_behave_like 'a filter effect' do
        let(:effect_type) { 'visual' }
        let(:effect) { ImageProcessor.new('TestEffects/ImageProcessor/ImageProcessor.j3m', %w(SourceTex)) }
      end
    end
  end
end

