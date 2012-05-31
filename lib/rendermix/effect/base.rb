module RenderMix
  module Effect
    class Base
      # @return [Fixnum] starting frame of this effect
      attr_reader :in_frame
      # @return [Fixnum] ending frame of this effect
      attr_reader :out_frame

      # @param [Effect::Audio, Effect::Video] effect_delegate
      # @param [Array<Mix::Base>] tracks array of mix elements this effect applies to
      def initialize(effect_delegate, tracks, in_frame, out_frame)
        #XXX deal with effect_delegate
        @tracks = tracks.freeze
        @in_frame = in_frame
        @out_frame = out_frame
      end
      
      # @return [Array<Mix::Base>] array of mix tracks this Effect processes
      def rendering_prepare(context_manager)
        # Clone context manager for each track
        @context_managers = Array.new(@tracks.length)
        @context_managers.fill { context_manager.clone }
        @current_contexts = Array.new(@tracks.length)
        #XXX inform delegate?
        @tracks
      end

      def render(context_manager)
        #XXX
        #XXX render our context for each track
        # Render each track into its context manager
        @context_managers.each_with_index do |cm, i|
          cm.render(@tracks[i])
          @current_contexts[i] = cm.current_context
        end
        #XXX need to provide @current_contexts to delegate - it then needs to render into our context_manager
      end

      def context_released(context)
        #XXX
      end

      def rendering_finished
        #XXX
      end
    end
  end
end
