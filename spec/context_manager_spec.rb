require 'spec_helper'

shared_examples 'a context manager' do |render_av_method, av_context_released_method|
  include_context 'requires render thread'
  let(:renderer) { renderer = double('renderer') }

  def should_render(render_method)
    renderer.should_receive(render_method) do |mgr|
      mgr.acquire_context(renderer)
    end.with(manager)
  end

  it 'should not release the context if the renderer renderered' do
    on_render_thread do
      renderer.should_receive(render_av_method) do |mgr|
        mgr.acquire_context(renderer)
      end.with(manager).once

      renderer.should_not_receive(av_context_released_method)
      manager.render(renderer)
    end
  end

  it 'should release the context if nothing rendered' do
    on_render_thread do
      context = nil
      renderer.should_receive(render_av_method) do |mgr|
        context = mgr.acquire_context(renderer) if context.nil?
      end.with(manager).exactly(2).times

      renderer.should_receive(av_context_released_method) do |ctx|
        context.should be ctx
      end.once

      # Render and acquire context, should not release
      manager.render(renderer)

      # Render and do not acquire context, should release
      manager.render(renderer)
    end
  end
end

#XXX test cloning

module RenderMix
  describe AudioContextManager do
    it_should_behave_like 'a context manager', :render_audio, :audio_context_released do
      let!(:manager) { AudioContextManager.new(1024) }
    end

    context 'with initial context' do
      it_should_behave_like 'a context manager', :render_audio, :audio_context_released do
        let!(:manager) do
          AudioContextManager.new(1024, AudioContext.new(1024))
        end
        #XXX
      end
    end
  end

  describe VisualContextManager do
    it_should_behave_like 'a context manager', :render_visual, :visual_context_released do
      let!(:manager) do
        on_render_thread do
          VisualContextManager.new(@app.renderManager, @mixer.width,
                                   @mixer.height, @mixer.tpf)
        end
      end
      #XXX
    end

    context 'with initial context' do
      it_should_behave_like 'a context manager', :render_visual, :visual_context_released do
        let!(:manager) do
          on_render_thread do
            visual_context = VisualContext.new(@app.renderManager, @mixer.tpf,
                                               @app.viewPort, @app.rootNode)
            VisualContextManager.new(@app.renderManager, @mixer.width,
                                     @mixer.height, @mixer.tpf, visual_context)
          end
        end
      end
    end
  end
end
