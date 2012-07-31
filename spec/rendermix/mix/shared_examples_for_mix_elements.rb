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

shared_examples 'an image/media element' do
  include_context 'requires render thread'
  include_context 'should receive invoke'

  it 'should freeze during a transition' do
    media1_dur = 5*8
    media2_dur = 6*8
    effect_dur = 5*4
    freeze_dur = effect_dur / 2
    effect_in = (media1_dur + freeze_dur) - effect_dur
    effect_out = effect_in + effect_dur - 1

    panzoom1 = double("panzoom1")
    media1 = @app.mixer.new_media(FIXTURE_MEDIA, duration: media1_dur, post_freeze: freeze_dur, panzoom: panzoom1)
    seq1 = @app.mixer.new_sequence(media1)

    panzoom2 = double("panzoom2")
    media2 = @app.mixer.new_media(FIXTURE_MEDIA, duration: media2_dur, pre_freeze: freeze_dur, panzoom: panzoom2)
    seq2 = @app.mixer.new_sequence(@app.mixer.new_blank(duration: effect_in),
                                   media2)

    par = @app.mixer.new_parallel(seq1, seq2)

    media1.duration.should == media1_dur + freeze_dur
    media2.duration.should == media2_dur + freeze_dur

    effect = RenderMix::Effect::Cinematic.new('TestEffects/Cinematic/manifest.json', %w(SourceVideo TargetVideo), "Title" => "the transition title")
    par.apply_visual_effect(effect, effect_in, effect_out)

    par.should_receive_invoke(:audio_rendering_prepare).once
    par.should_receive_invoke(:visual_rendering_prepare).once
    par.should_receive_invoke(:on_audio_render).exactly(par.duration).times
    par.should_receive_invoke(:on_visual_render).exactly(par.duration - effect.duration).times
    par.should_receive_invoke(:audio_rendering_finished).once
    par.should_receive_invoke(:visual_rendering_finished).once

    effect.should_receive_invoke(:on_rendering_prepare).once
    effect.should_receive_invoke(:on_visual_render).exactly(effect.duration).times
    effect.should_receive_invoke(:visual_context_released).once
    effect.should_receive_invoke(:on_rendering_finished).once

    panzoom1.should_receive(:panzoom).exactly(media1_dur).times
    panzoom2.should_receive(:panzoom).exactly(media2_dur).times

    on_render_thread do
      register_test_assets
    end

    (par.duration + 1).times do
      on_render_thread do
        @app.audio_context_manager.render(par)
        @app.visual_context_manager.render(par)
      end
    end
  end

end
