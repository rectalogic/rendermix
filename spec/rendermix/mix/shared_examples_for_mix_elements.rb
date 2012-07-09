require 'spec_helper'

shared_examples 'a mix element' do
  include_context 'requires render thread'
  include_context 'should receive invoke'

  it 'should not validate to a different mixer' do
    mixer2 = double('mixer')
    expect { mix_element.validate(mixer2) }.to raise_error(RenderMix::InvalidMixError)
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
    duration = mix_element.duration
    mix_element.should_receive_invoke(:audio_rendering_prepare).once
    mix_element.should_receive_invoke(:on_audio_render).exactly(duration).times
    mix_element.should_receive_invoke(:audio_rendering_finished).once
    (duration + 1).times do
      on_render_thread do
        @app.audio_context_manager.render(mix_element)
      end
    end
  end

  it 'should render visual' do
    duration = mix_element.duration
    mix_element.should_receive_invoke(:visual_rendering_prepare).once
    mix_element.should_receive_invoke(:on_visual_render).exactly(duration).times
    mix_element.should_receive_invoke(:visual_rendering_finished).once
    (duration + 1).times do
      on_render_thread do
        @app.visual_context_manager.render(mix_element)
      end
    end
  end
end
