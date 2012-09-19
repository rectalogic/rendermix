require 'spec_helper'

module RenderMix
  describe OrthoQuad do
    include_context 'requires render thread'

    def image_width
      @mixer.width * 2
    end
    def image_height
      @mixer.height * 1.5
    end

    def ortho_quad(opts={})
      OrthoQuad.new(@mixer.render_system.asset_manager,
                    @mixer.width, @mixer.height,
                    image_width, image_height, opts)
    end

    it 'should be initialized to meet' do
      on_render_thread do
        ortho = ortho_quad
        ortho.quad.localTranslation.should eq(Jme::Math::Vector3f.new(0, 60, 0))
        ortho.quad.localScale.should eq(Jme::Math::Vector3f.new(0.5, 0.5, 1.0))
      end
    end

    it 'should support panzoom fill' do
      on_render_thread do
        ortho = ortho_quad(fit: "fill")
        ortho.panzoom(1, 0, 0)

        scale = @mixer.height / image_height.to_f
        tx = -(scale * image_width - @mixer.width) / 2.0

        ortho.quad.localTranslation.should eq(Jme::Math::Vector3f.new(tx, 0, 0))
        ortho.quad.localScale.should eq(Jme::Math::Vector3f.new(scale, scale, 1))
      end
    end

    it 'should support scaled, translated panzoom' do
      on_render_thread do
        ortho = ortho_quad
        ortho.panzoom(2, 0.5, 0.2)
        ortho.quad.localTranslation.should eq(Jme::Math::Vector3f.new(0, -24, 0))
        ortho.quad.localScale.should eq(Jme::Math::Vector3f.new(1, 1, 1))
      end
    end
  end
end
