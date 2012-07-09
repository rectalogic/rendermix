require 'spec_helper'
require 'rendermix/effect/shared_examples_for_effect'

module RenderMix
  module Effect
    describe AudioMixer do
      it_should_behave_like 'a transition effect' do
        let(:effect_type) { 'audio' }
        let(:effect) { AudioMixer.new }
      end

      it_should_behave_like 'a filter effect' do
        let(:effect_type) { 'audio' }
        let(:effect) { AudioMixer.new }
      end
    end
  end
end

