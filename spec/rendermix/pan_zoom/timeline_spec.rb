require 'spec_helper'

module RenderMix
  module PanZoom
    describe Timeline do
      def panzoom(interpolator, results)
        keyframes = [ Keyframe.new(time: 0, scale: 2, tx: 0, ty: 0),
                      Keyframe.new(time: 0.5, scale: 3, tx: 0.5, ty: 0.5),
                      Keyframe.new(time: 0.75, scale: 3, tx: 1, ty: 0),
                      Keyframe.new(time: 1, scale: 1, tx: 0, ty: 0) ]
        timeline = Timeline.new(keyframes, interpolator: interpolator)

        quad = double('quad')
        results.each do |result|
          quad.should_receive(:panzoom).with(result[:scale], result[:tx], result[:ty]).ordered
        end

        (0..10).step do |time|
          time /= 10.0
          timeline.panzoom(time, quad)
        end
      end

      it 'should perform linear interpolation' do
        results = [
                   { scale: 2.0, tx: 0.0, ty: 0.0 },
                   { scale: 2.200000047683716, tx: 0.10000000149011612, ty: 0.10000000149011612 },
                   { scale: 2.4000000953674316, tx: 0.20000000298023224, ty: 0.20000000298023224 },
                   { scale: 2.5999999046325684, tx: 0.30000001192092896, ty: 0.30000001192092896 },
                   { scale: 2.8000001907348633, tx: 0.4000000059604645, ty: 0.4000000059604645 },
                   { scale: 3.0, tx: 0.5, ty: 0.5 },
                   { scale: 3.0, tx: 0.7000000476837158, ty: 0.30000001192092896 },
                   { scale: 3.0, tx: 0.8999999761581421, ty: 0.09999999403953552 },
                   { scale: 2.6000001430511475, tx: 0.800000011920929, ty: 0.0 },
                   { scale: 1.7999999523162842, tx: 0.3999999761581421, ty: 0.0 },
                   { scale: 1.0, tx: 0.0, ty: 0.0 },
                  ]
        panzoom("linear", results)
      end

      it 'should perform catmull-rom interpolation' do
        results = [
                   { scale: 2.0, tx: 0.0, ty: 0.0 },
                   { scale: 2.1519999504089355, tx: 0.06800000369548798, ty: 0.08400000631809235 },
                   { scale: 2.375999927520752, tx: 0.1640000194311142, ty: 0.21199999749660492 },
                   { scale: 2.624000072479248, tx: 0.2760000228881836, ty: 0.3479999899864197 },
                   { scale: 2.8480000495910645, tx: 0.3920000195503235, ty: 0.4560000002384186 },
                   { scale: 3.0, tx: 0.5, ty: 0.5 },
                   { scale: 3.1679999828338623, tx: 0.7720000147819519, ty: 0.3479999899864197 },
                   { scale: 3.1440000534057617, tx: 0.9960000514984131, ty: 0.08400002121925354 },
                   { scale: 2.696000099182129, tx: 0.8799999952316284, ty: -0.03200000151991844 },
                   { scale: 1.7519999742507935, tx: 0.3999999761581421, ty: -0.023999996483325958 },
                   { scale: 1.0, tx: 0.0, ty: 0.0 },
                  ]
        panzoom("catmull", results)
      end
    end
  end
end
