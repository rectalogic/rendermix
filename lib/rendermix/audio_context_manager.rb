module RenderMix

  class AudioContextManager < ContextManager
    def initialize(audio_framebuffer_size)
      super(AudioContextPool.new(audio_framebuffer_size))
    end

    # _renderer_ AudioRenderer
    def on_render(renderer)
      renderer.render_audio(self)
    end
    private :on_render

    # _renderer_ AudioRenderer
    def on_release_context(renderer)
      renderer.audio_context_released
    end
    private :on_release_context
  end
end
