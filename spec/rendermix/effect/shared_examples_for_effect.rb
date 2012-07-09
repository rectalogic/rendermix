require 'spec_helper'

def sym(format)
  (format % effect_type).to_sym
end

shared_examples 'a transition effect' do
  include_context 'requires render thread'
  include_context 'should receive invoke'

  it 'should apply to overlapping Sequences in Parallel' do
    seq1_dur = 5*4
    seq1 = @app.mixer.new_sequence(@app.mixer.new_image(FIXTURE_IMAGE, seq1_dur))

    seq2_start = 5*2
    seq2 = @app.mixer.new_sequence(@app.mixer.new_blank(seq2_start),
                                   @app.mixer.new_media(FIXTURE_MEDIA, duration: 5*8))

    par = @app.mixer.new_parallel(seq1, seq2)

    par.method(sym("apply_%s_effect")).call(effect, seq2_start, seq1_dur - 1)

    par.should_receive_invoke(sym("%s_rendering_prepare")).once
    par.should_receive_invoke(sym("on_%s_render")).exactly(par.duration - effect.duration).times
    par.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("%s_context_released")).once
    effect.should_receive_invoke(sym("on_rendering_finished")).once

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @app.method(sym("%s_context_manager")).call
    end

    (par.duration + 1).times do
      on_render_thread do
        context_manager.render(par)
      end
    end
  end

  it 'should apply to Sequence overlapping Image in Parallel' do
    image = @app.mixer.new_image(FIXTURE_IMAGE, 5*4)

    seq_start = 5*2
    seq = @app.mixer.new_sequence(@app.mixer.new_blank(seq_start),
                                  @app.mixer.new_media(FIXTURE_MEDIA, duration: 5*4))

    par = @app.mixer.new_parallel(image, seq)

    par.method(sym("apply_%s_effect")).call(effect, seq_start, image.duration - 1)

    par.should_receive_invoke(sym("%s_rendering_prepare")).once
    par.should_receive_invoke(sym("on_%s_render")).exactly(par.duration - effect.duration).times
    par.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("%s_context_released")).once
    effect.should_receive_invoke(sym("on_rendering_finished")).once

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @app.method(sym("%s_context_manager")).call
    end

    (par.duration + 1).times do
      on_render_thread do
        context_manager.render(par)
      end
    end
  end
end

shared_examples 'a filter effect' do
  include_context 'requires render thread'
  include_context 'should receive invoke'

  it 'should apply as a filter to Media' do
    media = @app.mixer.new_media(FIXTURE_MEDIA, duration: 5*4)

    effect_start = 5*1
    media.method(sym("apply_%s_effect")).call(effect, effect_start, media.duration - 1)

    media.should_receive_invoke(sym("%s_rendering_prepare")).once
    # Since the effect is directly on the media, media is rendered
    # every frame (either directly or by the effect)
    media.should_receive_invoke(sym("on_%s_render")).exactly(media.duration).times
    media.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("%s_context_released")).once
    effect.should_not_receive(sym("on_rendering_finished"))

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @app.method(sym("%s_context_manager")).call
    end
    (media.duration + 1).times do
      on_render_thread do
        context_manager.render(media)
      end
    end
  end

  it 'should apply as a filter to Sequence' do
    media = @app.mixer.new_media(FIXTURE_MEDIA, duration: 5*4)
    seq = @app.mixer.new_sequence(media)

    effect_start = 5*1
    seq.method(sym("apply_%s_effect")).call(effect, effect_start, seq.duration - 1)

    seq.should_receive_invoke(sym("%s_rendering_prepare")).once
    seq.should_receive_invoke(sym("on_%s_render")).exactly(seq.duration).times
    seq.should_receive_invoke(sym("%s_rendering_finished")).once

    media.should_receive_invoke(sym("%s_rendering_prepare")).once
    media.should_receive_invoke(sym("on_%s_render")).exactly(media.duration).times
    media.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("%s_context_released")).once
    effect.should_not_receive(sym("on_rendering_finished"))

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @app.method(sym("%s_context_manager")).call
    end
    (seq.duration + 1).times do
      on_render_thread do
        context_manager.render(seq)
      end
    end
  end

end
