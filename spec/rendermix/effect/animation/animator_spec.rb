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
              0.2 => transform([19.451479, 18.460268, 2.9768667],
                               [-0.6409292, -0.05308895, -0.17066166, 0.74650234]),
              0.4 => transform([18.63121, 19.316257, 5.9175453],
                               [-0.5124039, -0.1292011, -0.17199494, 0.8313646]),
              0.5 => transform([18.365543, 19.593494, 6.8793726],
                               [-0.42153442, -0.1894191, -0.16526468, 0.87127304]),
              0.8 => transform([20.079536, 17.097565, 3.7155933],
                               [-0.096785046, -0.47170252, -0.066354595, 0.8739144]),
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
