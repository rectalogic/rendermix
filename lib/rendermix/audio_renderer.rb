module RenderMix
  # AudioContextManager users (renderers) should implement this module
  module AudioRenderer
    def render_audio(context_manager)
    end

    def audio_context_released
    end
  end
end
