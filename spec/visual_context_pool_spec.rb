require 'spec_helper'

module RenderMix
  describe VisualContextPool do
    include_context 'requires render thread'

    before(:each) do
      @pool = VisualContextPool.new(@app.renderManager, @mixer.width, @mixer.height, @mixer.framerate.denominator / @mixer.framerate.numerator.to_f)
    end

    it 'should create a new context' do
      on_render_thread do
        context = @pool.acquire_context
        context.should_not be(@pool.acquire_context)
      end
    end
  end
end
