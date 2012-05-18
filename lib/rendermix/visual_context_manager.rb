module RenderMix

  class VisualContextManager < ContextManager
    def initialize(render_manager, width, height, tpf, initial_context=nil)
      super(VisualContextPool.new(render_manager, width, height, tpf), initial_context)
      @render_manager = render_manager
    end

    def on_render(renderer)
      renderer.render_visual(self)
    end
    private :on_render

    def on_release_context(renderer)
      renderer.visual_context_released
    end
    private :on_release_context
  end
end
