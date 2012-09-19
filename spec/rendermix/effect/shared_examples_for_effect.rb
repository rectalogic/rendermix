require 'spec_helper'

def sym(format)
  (format % effect_type).to_sym
end

shared_examples 'a transition effect' do
  include_context 'requires render thread'
  include_context 'should receive invoke'

  it 'should apply to overlapping Sequences in Parallel' do
    seq1_dur = 5*4
    seq1 = @mixer.new_sequence(@mixer.new_image(FIXTURE_IMAGE, duration: seq1_dur))

    seq2_start = 5*2
    seq2 = @mixer.new_sequence(@mixer.new_blank(duration: seq2_start),
                               @mixer.new_media(FIXTURE_MEDIA, duration: 5*8))

    par = @mixer.new_parallel(seq1, seq2)

    par.method(sym("apply_%s_effect")).call(effect, seq2_start, seq1_dur - 1)

    par.should_receive_invoke(sym("%s_rendering_prepare")).once
    par.should_receive_invoke(sym("on_%s_render")).exactly(par.duration - effect.duration).times
    par.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("on_rendering_finished")).once

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @mixer.render_system.method(sym("%s_context_manager")).call
    end

    (par.duration + 1).times do
      on_render_thread do
        context_manager.render(par)
      end
    end
  end

  it 'should apply to Sequence overlapping Image in Parallel' do
    image = @mixer.new_image(FIXTURE_IMAGE, duration: 5*4)

    seq_start = 5*2
    seq = @mixer.new_sequence(@mixer.new_blank(duration: seq_start),
                              @mixer.new_media(FIXTURE_MEDIA, duration: 5*4))

    par = @mixer.new_parallel(image, seq)

    par.method(sym("apply_%s_effect")).call(effect, seq_start, image.duration - 1)

    par.should_receive_invoke(sym("%s_rendering_prepare")).once
    par.should_receive_invoke(sym("on_%s_render")).exactly(par.duration - effect.duration).times
    par.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("on_rendering_finished")).once

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @mixer.render_system.method(sym("%s_context_manager")).call
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

  def filter_media(effect_start)
    media = @mixer.new_media(FIXTURE_MEDIA, duration: 5*4)

    media.method(sym("apply_%s_effect")).call(effect, effect_start, media.duration - 1)

    media.should_receive_invoke(sym("%s_rendering_prepare")).once
    # Since the effect is directly on the media, media is rendered
    # every frame (either directly or by the effect)
    media.should_receive_invoke(sym("on_%s_render")).exactly(media.duration).times
    media.should_receive_invoke(sym("%s_rendering_finished")).once

    effect.should_receive_invoke(sym("on_rendering_prepare")).once
    effect.should_receive_invoke(sym("on_%s_render")).exactly(effect.duration).times
    effect.should_receive_invoke(sym("on_rendering_finished")).once

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @mixer.render_system.method(sym("%s_context_manager")).call
    end
    (media.duration + 1).times do
      on_render_thread do
        context_manager.render(media)
      end
    end
  end

  it 'should apply as a filter with no offset on Media' do
    filter_media(0)
  end

  it 'should apply as a filter offset on Media' do
    filter_media(5*1)
  end

  it 'should apply as a filter to Sequence' do
    media = @mixer.new_media(FIXTURE_MEDIA, duration: 5*4)
    seq = @mixer.new_sequence(media)

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
    effect.should_receive_invoke(sym("on_rendering_finished")).once

    context_manager = nil
    on_render_thread do
      register_test_assets
      context_manager = @mixer.render_system.method(sym("%s_context_manager")).call
    end
    (seq.duration + 1).times do
      on_render_thread do
        context_manager.render(seq)
      end
    end
  end

end
