module RenderMix

  class VisualContextManager < ContextManager
    def initialize(render_manager, width, height, tpf, visual_context=nil)
      super(VisualContextPool.new(render_manager, width, height, tpf))
      @render_manager = render_manager
      # Initial non-pooled context
      @initial_visual_context = visual_context
    end

    def initialize_copy(source)
      super
      @initial_visual_context = nil
    end

    def on_render(renderer)
      renderer.render_visual(self)
    end
    private :on_render

    def release_context
      current_renderer.visual_context_released
      # Special handling for non-pooled initial context - just want to reset it
      super(@initial_visual_context.nil?)
      @initial_visual_context.reset if @initial_visual_context
    end
    private :release_context
  end
end
