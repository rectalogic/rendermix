module RenderMix
  module Mix
    # Helper for freeze-frame
    class Freezer
      include FrameTime

      def initialize(pre_freeze, post_freeze, duration)
        @render_in = pre_freeze.to_i
        @render_out = (pre_freeze.to_i + duration) - 1
        @duration = duration
      end

      # @return [Boolean] true if frame is in frozen region
      def freezing?(frame)
        frame < @render_in or frame > @render_out
      end

      # @return [Boolean] true if this frame should be rendered
      def render?(frame)
        @current_frame = frame
        if @render_in > 0
          if frame == 0
            # Reset to render_in so current_time will report "0"
            @current_frame = @render_in
            return true
          else
            # Do not render on frame @render_in - we already rendered it
            # instead of frame 0
            return (frame > @render_in and frame <= @render_out)
          end
        end
        frame <= @render_out
      end

      def current_time
        frame_to_time(@current_frame - @render_in, @duration)
      end
    end
  end
end
