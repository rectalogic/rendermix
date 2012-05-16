module RenderMix

  class AudioContextManager < ContextManager
    def initialize(audio_framebuffer_size)
      super(AudioContextPool.new(audio_framebuffer_size))
    end

    def on_render(renderer)
      renderer.render_audio(self)
    end
    private :on_render

    def release_context
      current_renderer.audio_context_released
      super
    end
    private :release_context
  end
end
