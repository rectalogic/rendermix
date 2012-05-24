require 'spec_helper'

shared_examples 'a context manager' do |render_av_method, av_context_released_method, has_initial_context|
  include_context 'requires render thread'
  let(:renderer) { renderer = double('renderer') }

  it 'should not release the context if the renderer renderered' do
    on_render_thread do
      renderer.should_receive(render_av_method) do |mgr|
        mgr.acquire_context(renderer)
      end.with(manager).once

      renderer.should_not_receive(av_context_released_method)
      manager.render(renderer)
    end
  end

  it 'should release the context if nothing rendered after a render' do
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

  it 'should not release the context if nothing ever rendered' do
    on_render_thread do
      renderer.should_receive(render_av_method).exactly(3).times
      renderer.should_not_receive(av_context_released_method)

      manager.render(renderer)
      manager.render(renderer)
      manager.render(renderer)
    end
  end

  it 'should not reuse the context' do
    on_render_thread do
      # Acquire the context so when we render and don't acquire, we'll release
      context = manager.acquire_context(renderer)
      renderer.should_receive(render_av_method).once
      renderer.should_receive(av_context_released_method).once
      manager.render(renderer)

      # Should still be the same context
      context.should be manager.acquire_context(renderer)
    end
  end

  it 'should not clone the current context' do
    on_render_thread do
      context = manager.acquire_context(renderer)
      manager.clone.acquire_context(renderer).should_not be context
    end
  end

  it 'should clone the context pool' do
    on_render_thread do
      # Acquire the context so when we render and don't acquire, we'll release
      context = manager.acquire_context(renderer)
      renderer.should_receive(render_av_method).once
      renderer.should_receive(av_context_released_method).once
      manager.render(renderer)

      # The clone should acquire the pooled context, unless we have an initial context
      if has_initial_context
        manager.clone.acquire_context(renderer).should_not be context
      else
        manager.clone.acquire_context(renderer).should be context
      end
    end
  end
end

module RenderMix
  describe AudioContextManager do
    it_should_behave_like 'a context manager', :render_audio, :audio_context_released, false do
      let!(:manager) { AudioContextManager.new(1024) }
    end

    context 'with initial context' do
      it_should_behave_like 'a context manager', :render_audio, :audio_context_released, true do
        let!(:manager) do
          AudioContextManager.new(1024, AudioContext.new(1024))
        end
      end
    end
  end

  describe VisualContextManager do
    it_should_behave_like 'a context manager', :render_visual, :visual_context_released, false do
      let!(:manager) do
        on_render_thread do
          VisualContextManager.new(@app.renderManager, @app.mixer.width,
                                   @app.mixer.height, @app.mixer.tpf)
        end
      end
      #XXX
    end

    context 'with initial context' do
      it_should_behave_like 'a context manager', :render_visual, :visual_context_released, true do
        let!(:manager) do
          on_render_thread do
            visual_context = VisualContext.new(@app.renderManager,
                                               @app.mixer.tpf, @app.viewPort,
                                               @app.rootNode)
            VisualContextManager.new(@app.renderManager, @app.mixer.width,
                                     @app.mixer.height, @app.mixer.tpf,
                                     visual_context)
          end
        end
      end
    end
  end
end
