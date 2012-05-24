require 'spec_helper'

module RenderMix
  describe OrthoQuad do
    include_context 'requires render thread'

    def image_width
      @app.mixer.width * 2
    end
    def image_height
      @app.mixer.height * 1.5
    end

    def ortho_quad
      context = VisualContext.new(@app.renderManager, @app.mixer.tpf, @app.viewPort, @app.rootNode)
      quad = nil
      # Capture and return the Quad node that is created
      attach_child = context.method(:attach_child)
      context.should_receive(:attach_child) do |q|
        quad = q
        attach_child.call(q)
      end.once
      ortho = OrthoQuad.new(context, @app.assetManager, image_width, image_height)
      return ortho, quad
    end

    it 'should be initialized to meet' do
      on_render_thread do
        ortho, quad = ortho_quad
        quad.localTranslation.should eq(JmeMath::Vector3f.new(0, 60, 0))
        quad.localScale.should eq(JmeMath::Vector3f.new(0.5, 0.5, 1.0))
      end
    end

    it 'should support panzoom fill' do
      on_render_thread do
        ortho, quad = ortho_quad
        ortho.panzoom(1, 0, 0, :fill)

        scale = @app.mixer.height / image_height.to_f
        tx = -(scale * image_width - @app.mixer.width) / 2.0

        quad.localTranslation.should eq(JmeMath::Vector3f.new(tx, 0, 0))
        quad.localScale.should eq(JmeMath::Vector3f.new(scale, scale, 1))
      end
    end
    
  end
end
