require 'spec_helper'

shared_examples 'a render manager' do |av_rendering_prepare, on_render_av, av_rendering_finished|
  include_context 'requires render thread'

  it 'should initially not have effects' do
    on_render_thread do
      manager = described_class.new(double('mix element'))
      manager.has_effects?.should be false
    end
  end

  it 'should have effects when added' do
    on_render_thread do
      mixer = double('mixer')
      mix_element = double('mix element', :mixer => mixer)
      tracks = [mix_element]
      mix_element.should_receive(:tracks).at_least(:once).and_return(tracks)
      mix_element.should_receive(:duration).at_least(:once).and_return 5
      manager = described_class.new(mix_element)
      effect = double('effect')
      effect.should_receive(:apply).with(mixer, tracks, 0, 1)
      manager.apply_effect(effect, 0, 1)
      manager.has_effects?.should be true
    end
  end

  it 'should not reentrantly render effects' do
=begin
XXX need to flesh out effects more
    on_render_thread do
      context_manager = double('context manager')
      mix_element = double('mix_element')
      tracks = [ mix_element ]
      mix_element.should_receive(:tracks).and_return tracks
      mix_element.should_receive(on_render_av).with(context_manager, 0, tracks).once
      manager = described_class.new(mix_element)
      delegate = double('delegate')
      delegate.should_receive(av_rendering_prepare).with(context_manager).once
      #XXXdelegate.should_receive(on_render_av).with(context_manager).once
      manager.add_effect(delegate, [0], 0, 1)
      manager.render(context_manager)
    end
=end
  end

  it 'should prepare and render the mix element' do
    on_render_thread do
      context_manager = double('context manager')
      mix_element = double('mix element')
      tracks = [ mix_element ]
      mix_element.should_receive(av_rendering_prepare).with(context_manager).once
      mix_element.should_receive(on_render_av).with(context_manager, 0).once
      mix_element.should_not_receive(av_rendering_finished)
      manager = described_class.new(mix_element)
      manager.render(context_manager)
    end
  end

  it 'should finish the mix element' do
    on_render_thread do
      context_manager = double('context manager')
      mix_element = double('mix element', duration: 2)
      tracks = [ mix_element ]
      mix_element.should_receive(av_rendering_prepare).with(context_manager).once
      mix_element.should_receive(on_render_av).with(context_manager, 0).once
      mix_element.should_receive(on_render_av).with(context_manager, 1).once
      mix_element.should_not_receive(on_render_av).with(context_manager, 2)
      mix_element.should_receive(av_rendering_finished).once
      manager = described_class.new(mix_element)
      manager.render(context_manager)
      manager.render(context_manager)
      manager.render(context_manager)
    end
  end
end

module RenderMix
  module Mix
    describe AudioRenderManager do 
      it_should_behave_like 'a render manager', :audio_rendering_prepare, :on_audio_render, :audio_rendering_finished
    end

    describe VisualRenderManager do
      it_should_behave_like 'a render manager', :visual_rendering_prepare, :on_visual_render, :visual_rendering_finished
    end
  end
end
