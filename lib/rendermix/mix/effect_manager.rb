module RenderMix
  module Mix
    class EffectManager
      # @param [Mix::Base] mix_element
      def initialize(mix_element)
        @mix_element = mix_element
        @effects = []
      end

      def apply_effect(effect, in_frame, out_frame)
        effect.apply(@mix_element.mixer, @mix_element.tracks, in_frame, out_frame)
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

      # @return [Boolean] true if effect rendered
      def render(context_manager, current_frame)
        # No effects, no tracks rendered
        return false if @effects.empty?

        # Past first effect, get the next one
        if current_frame > @effects.first.out_frame
          @effects.first.rendering_finished
          @effects.shift
          return false if @effects.empty?
        end

        effect = @effects.first

        # Too early for this effect
        return false if current_frame < effect.in_frame

        # First frame for effect, prepare it
        effect.rendering_prepare(context_manager) if effect.in_frame == current_frame

        # Effect is current
        if current_frame >= effect.in_frame and current_frame <= effect.out_frame
          context_manager.render(effect)
          return true
        end
        return false
      end
    end
  end
end
