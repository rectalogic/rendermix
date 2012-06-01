module RenderMix
  module Mix
    class EffectManager
      # @param [Mix::Base] mix_element
      def initialize(mix_element)
        @mix_element = mix_element
        @effects = []
      end

      def apply_effect(effect, track_indexes, in_frame, out_frame)
        tracks = @mix_element.tracks
        effect_tracks = Array.new(track_indexes.length).fill do |i|
          index = track_indexes[i]
          raise(InvalidMixError, "Effect track index #{index} out of range") if index < 0 || index >= @mix_element.tracks.length
          tracks[index]
        end

        effect.apply(@mix_element.mixer, effect_tracks, in_frame, out_frame)
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

      # @return [Array<Mix::Base>] array of mix elements that were not rendered.
      #  i.e. returns what still needs to be rendered.
      def render(context_manager, current_frame)
        # No effects, no tracks rendered
        return @mix_element.tracks if @effects.empty?

        # Past first effect, get the next one
        if current_frame > @effects.first.out_frame
          @effects.first.rendering_finished
          @effects.shift
          return @mix_element.tracks if @effects.empty?
        end

        effect = @effects.first

        # Too early for this effect
        if current_frame < effect.in_frame
          return @mix_element.tracks
        end

        # First frame for effect, prepare it
        if effect.in_frame == current_frame
          # Allow the effect to clone context manager
          effect_tracks = effect.rendering_prepare(context_manager)
          # Cache tracks the effect won't be rendering
          @unrendered_tracks = @mix_element.tracks - effect_tracks
        end

        # Effect is current
        if current_frame >= effect.in_frame and current_frame <= effect.out_frame
          context_manager.render(effect)
          return @unrendered_tracks
        else
          @mix_element.tracks
        end
      end
    end
  end
end
