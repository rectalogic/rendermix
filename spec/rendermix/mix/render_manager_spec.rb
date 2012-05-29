require 'spec_helper'

shared_examples 'a render manager' do |av_rendering_prepare, on_render_av, av_rendering_finished|
  include_context 'requires render thread'

  it 'should initially not have effects' do
    on_render_thread do
      manager = described_class.new(double('renderer'))
      manager.has_effects?.should be false
    end
  end

  it 'should have effects when added' do
    on_render_thread do
      renderer = double('renderer')
      renderer.should_receive(:tracks).and_return [renderer]
      manager = described_class.new(renderer)
      manager.add_effect(double('delegate'), [0], 0, 1)
      manager.has_effects?.should be true
    end
  end

  it 'should not reentrantly render effects' do
=begin
XXX need to flesh out effects more
    on_render_thread do
      context_manager = double('context manager')
      renderer = double('renderer')
      tracks = [ renderer ]
      renderer.should_receive(:tracks).and_return tracks
      renderer.should_receive(on_render_av).with(context_manager, 0, tracks).once
      manager = described_class.new(renderer)
      delegate = double('delegate')
      delegate.should_receive(av_rendering_prepare).with(context_manager).once
      #XXXdelegate.should_receive(on_render_av).with(context_manager).once
      manager.add_effect(delegate, [0], 0, 1)
      manager.render(context_manager)
    end
=end
  end

  it 'should prepare and render the renderer' do
    on_render_thread do
      context_manager = double('context manager')
      renderer = double('renderer')
      tracks = [ renderer ]
      renderer.should_receive(:tracks).and_return tracks
      renderer.should_receive(av_rendering_prepare).with(context_manager).once
      renderer.should_receive(on_render_av).with(context_manager, 0, tracks).once
      renderer.should_not_receive(av_rendering_finished)
      manager = described_class.new(renderer)
      manager.render(context_manager)
    end
  end

  it 'should finish the renderer' do
    on_render_thread do
      context_manager = double('context manager')
      renderer = double('renderer', duration: 2)
      tracks = [ renderer ]
      renderer.should_receive(:tracks).exactly(2).times.and_return tracks
      renderer.should_receive(av_rendering_prepare).with(context_manager).once
      renderer.should_receive(on_render_av).with(context_manager, 0, tracks).once
      renderer.should_receive(on_render_av).with(context_manager, 1, tracks).once
      renderer.should_not_receive(on_render_av).with(context_manager, 2, tracks)
      renderer.should_receive(av_rendering_finished).once
      manager = described_class.new(renderer)
      manager.render(context_manager)
      manager.render(context_manager)
      manager.render(context_manager)
    end
  end
end

module RenderMix
  module Mix
    describe AudioRenderManager do 
      it_should_behave_like 'a render manager', :audio_rendering_prepare, :on_render_audio, :audio_rendering_finished
    end

    describe VisualRenderManager do
      it_should_behave_like 'a render manager', :visual_rendering_prepare, :on_render_visual, :visual_rendering_finished
    end
  end
end
