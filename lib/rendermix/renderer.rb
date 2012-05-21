module RenderMix
  # ContextManager users (renderers) should implement this module
  module Renderer
    # Prepare for rendering audio. Called once before first render_audio.
    def audio_rendering_prepare(context_manager)
    end

    # Renderer should acquire the context if it has any audio to render.
    def render_audio(context_manager)
    end

    # Renderer should revert any changes made when it initially acquired
    # context, and prepare itself to make those changes again on the next render.
    def audio_context_released(context)
    end

    # Called when audio rendering finished, render_audio will not be called again
    def audio_rendering_finished
    end

    # Prepare for rendering visual. Called once before first render_visual.
    def visual_rendering_prepare(context_manager)
    end

    # Renderer should acquire the context if it has any visual to render.
    def render_visual(context_manager)
    end

    # Renderer should revert any changes made when it initially acquired
    # context, and prepare itself to make those changes again on the next render.
    def visual_context_released(context)
    end

    # Called when visual rendering finished, render_visual will not be called again
    def visual_rendering_finished
    end
  end
end
