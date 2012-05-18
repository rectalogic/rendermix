module RenderMix
  module Mix
    class EffectManager
      # _tracks_ Array of all renderers that an Effect could apply to
      def initialize(tracks)
        @tracks = tracks
        @effects = []
      end

      def add_effect(effect_delegate, track_indexes, in_frame, out_frame)
        renderers = Array.new(track_indexes.length).fill do |i|
          index = track_indexes[i]
          raise(InvalidMixError, "Effect track index #{index} out of range") if index >= @tracks.length
          @tracks[index]
        end
        effect = Effect::Base.new(effect_delegate, renderers, in_frame, out_frame)

        #XXX insertion sort Effect::Base
        #XXX check for time overlap and raise

      end

      # Returns an Array of renderers that were not rendered.
      # i.e. returns what still needs to be rendered.
      def render(context_manager, current_frame)
        if not @active_effect
          @active_effect = @effects.first
          return @tracks if not @active_effect
          prepare_effect(context_manager)
        end

        # Past first effect, get the next one
        if current_frame > @active_effect.out_frame
          @effects.shift
          @active_effect = @effects.first
          return @tracks if not @active_effect
          prepare_effect(context_manager)
        end

        # Too early for effect
        return @tracks if current_frame < @active_effect.in_frame

        # Effect is current
        if current_frame >= @active_effect.in_frame and
            current_frame <= @active_effect.out_frame
          on_render(context_manager)
          return @unrendered_tracks
        end
        @tracks
      end

      def prepare_effect(context_manager)
        # Allow the effect to clone context
        @active_effect.prepare_context(context_manager)
        @unrendered_tracks = @tracks - @active_effect.tracks
      end
      private :prepare_effect

      def active_effect
        @active_effect
      end
      private :active_effect
    end

    class AudioEffectManager < EffectManager
      def on_render(context_manager)
        active_effect.render_audio(context_manager)
      end
    end

    class VisualEffectManager < EffectManager
      def on_render(context_manager)
        active_effect.render_visual(context_manager)
      end
    end
  end
end
