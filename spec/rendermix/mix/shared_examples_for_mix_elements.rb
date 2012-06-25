require 'spec_helper'

shared_examples 'a mix element' do
  include_context 'requires render thread'

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

  it 'should render audio' do
    on_render_thread do
      original_method = mix_element.method(:on_audio_render)
      mix_element.should_receive(:on_audio_render).exactly(1).times do |*args|
        original_method.call(*args)
      end
      @app.audio_context_manager.render(mix_element)
    end
  end

  it 'should render visual' do
    on_render_thread do
      original_method = mix_element.method(:on_visual_render)
      mix_element.should_receive(:on_visual_render).exactly(1).times do |*args|
        original_method.call(*args)
      end
      @app.visual_context_manager.render(mix_element)
    end
  end
end
