module RenderMix

  class AudioContextManager < ContextManager
    def initialize(audio_framebuffer_size, initial_context=nil)
      super(AudioContextPool.new(audio_framebuffer_size), initial_context)
    end

    def on_render(renderer)
      renderer.render_audio(self)
    end
    private :on_render

    def on_release_context(renderer, context)
      renderer.audio_context_released(context)
    end
    private :on_release_context
  end
end
