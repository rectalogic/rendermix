module RenderMix
  # VisualContextManager users (renderers) should implement this module
  module VisualRenderer
    def render_visual(context_manager)
    end

    def visual_context_released
    end
  end
end
