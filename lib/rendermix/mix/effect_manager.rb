module RenderMix
  module Mix
    class EffectManager
      # @param [Array<Mix::Base>] tracks array of all mix elements an Effect could apply to
      def initialize(tracks)
        @tracks = tracks
        @effects = []
      end

      def add_effect(effect_delegate, track_indexes, in_frame, out_frame)
        mix_elements = Array.new(track_indexes.length).fill do |i|
          index = track_indexes[i]
          raise(InvalidMixError, "Effect track index #{index} out of range") if index >= @tracks.length
          @tracks[index]
        end
        effect = Effect::Base.new(effect_delegate, mix_elements,
                                  in_frame, out_frame)
        insert_effect(effect)
      end

      # Insertion sort effect into array
      def insert_effect(effect)
        if @effects.empty?
          @effects << effect
        else
          # Find first element ahead of us
          index = @effects.find_index {|e| e.in_frame > effect.in_frame }
          if index
            if effect.out_frame >= @effects[index].in_frame ||
                (index > 0 && @effects[index-1].out_frame >= effect.in_frame)
              raise(InvalidMixError, 'Overlapping effects')
            end
            @effects.insert(index, effect)
          else
            # Check for overlap with last element
            if @effects.last.out_frame >= effect.in_frame
              raise(InvalidMixError, 'Overlapping effects')
            end
            @effects << effect
          end
        end
      end
      private :insert_effect

      # Returns an Array of mix elements that were not rendered.
      # i.e. returns what still needs to be rendered.
      def render(context_manager, current_frame)
        if not @active_effect
          @active_effect = @effects.first
          return @tracks if not @active_effect
          @unrendered_tracks = rendering_prepare(context_manager)
        end

        # Past first effect, get the next one
        if current_frame > @active_effect.out_frame
          @active_effect.rendering_finished
          @effects.shift
          @active_effect = @effects.first
          return @tracks if not @active_effect
          @unrendered_tracks = rendering_prepare(context_manager)
        end

        # Too early for effect
        return @tracks if current_frame < @active_effect.in_frame

        # Effect is current
        if current_frame >= @active_effect.in_frame and
            current_frame <= @active_effect.out_frame
          @active_effect.render(context_manager)
          return @unrendered_tracks
        end
        @tracks
      end

      # @return [Array<Mix::Base>] array of mix tracks that still need to be rendered
      def rendering_prepare(context_manager)
        # Allow the effect to clone context manager
        effect_tracks = @active_effect.rendering_prepare(context_manager)
        @tracks - effect_tracks
      end
      private :rendering_prepare
    end
  end
end
