require 'spec_helper'

shared_examples 'a mix element' do
  include_context 'requires render thread'
  let(:mixer) { RenderMix::Mixer.new(640, 480) }

  it 'should not add to a different mixer' do
    mixer2 = double('mixer')
    expect { mix_element.add(mixer2) }.to raise_error(RenderMix::InvalidMixError)
  end

  it 'should apply audio effects' do
    effect = RenderMix::Effect::AudioBase.new
    mix_element.apply_audio_effect(effect, 0, mix_element.duration - 1)
    mix_element.has_effects?.should be true
    effect.out_frame.should be mix_element.duration - 1
  end

  it 'should apply visual effects' do
    effect = RenderMix::Effect::VisualBase.new
    mix_element.apply_visual_effect(effect, 0, mix_element.duration - 1)
    mix_element.has_effects?.should be true
    effect.out_frame.should be mix_element.duration - 1
  end
end
