module RenderMix
  # ContextManager users (renderers) should implement this module
  module Renderer
    def render_audio(context_manager)
    end

    def audio_context_released
    end

    def render_visual(context_manager)
    end

    def visual_context_released
    end
  end
end
