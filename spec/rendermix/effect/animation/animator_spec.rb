require 'spec_helper'

module RenderMix
  module Effect
    module Animation
      describe Animator do
        include_context 'requires render thread'

        it 'should evaluate to correct transform' do
          on_render_thread do
            animator = File.open(File.join(FIXTURES, 'animation', 'animation.json'), 'r') do |f|
              Animator.new(JSON.parse(f.read))
            end

            animator.evaluate_time(0)
            animator.rotation.should eq(Jme::Math::Quaternion.new(-0.6660272, -0.029517177, -0.16841674, 0.7260664))
            animator.translation.should eq(Jme::Math::Vector3f.new(19.921131, 17.970163, 1.2984331))
          end
        end
      end
    end
  end
end
