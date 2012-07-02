require 'spec_helper'

module RenderMix
  module Effect
    module Animation
      describe Animator do
        include_context 'requires render thread'

        def transform(translation, rotation)
          Jme::Math::Transform.new(Jme::Math::Vector3f.new(*translation),
                                   Jme::Math::Quaternion.new(*rotation))
        end

        it 'should evaluate to correct transform' do
          on_render_thread do
            animator = File.open(File.join(FIXTURES, 'animation', 'animation.json'), 'r') do |f|
              Animator.new(JSON.load(f))
            end

            expected = {
              0.0 => transform([19.921131, 17.970163, 1.2984331],
                               [-0.6867049, -0.029517174, -0.16841672, 0.70654154]),
              0.2 => transform([19.477676, 18.432915, 2.8934274],
                               [-0.63683355, -0.053759832, -0.16994369, 0.7501147]),
              0.4 => transform([18.601229, 19.34752, 6.0424194],
                               [-0.4905827, -0.13792343, -0.16901927, 0.8436458]),
              0.5 => transform([18.35538, 19.604097, 6.9256077],
                               [-0.40689248, -0.19601262, -0.16245441, 0.8772834]),
              0.8 => transform([19.988829, 17.228533, 3.8785667],
                               [-0.11478704, -0.46236038, -0.07639749, 0.8759054]),
              1.0 => transform([21.369244, 15.234458, 1.2472537],
                               [0.0026692138, -0.5700356, 7.42584E-4, 0.82161534]),
            }

            expected.each_pair do |time, tx|
              animator.evaluate_time(time)
              animator.transform.translation.should eq(tx.translation), "translation does not match for time #{time}"
              animator.transform.rotation.should eq(tx.rotation), "rotation does not match for time #{time}"
            end
          end
        end
      end
    end
  end
end
