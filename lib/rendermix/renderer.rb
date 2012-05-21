module RenderMix
  # ContextManager users (renderers) should implement this module
  module Renderer
    # Renderer should acquire the context if it has any audio to render.
    def render_audio(context_manager)
    end

    # Renderer should revert any changes made when it initially acquired
    # context, and prepare itself to make those changes again on the next render.
    def audio_context_released(context)
    end

    # Renderer should acquire the context if it has any visual to render.
    def render_visual(context_manager)
    end

    # Renderer should revert any changes made when it initially acquired
    # context, and prepare itself to make those changes again on the next render.
    def visual_context_released(context)
    end
  end
end
