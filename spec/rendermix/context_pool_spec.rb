require 'spec_helper'

shared_examples 'a context pool' do
  include_context 'requires render thread'

  it 'should create a new context' do
    on_render_thread do
      context = pool.acquire_context
      context.should_not be(pool.acquire_context)
    end
  end

  it 'should reuse a released context' do
    on_render_thread do
      context = pool.acquire_context
      pool.release_context(context)
      context.should be(pool.acquire_context)
    end
  end

  it 'should create multiple contexts' do
    on_render_thread do
      context1 = pool.acquire_context
      context2 = pool.acquire_context
      context3 = pool.acquire_context
      context1.should_not be(context2)
      context2.should_not be(context3)
    end
  end
end

module RenderMix
  describe AudioContextPool do
    it_behaves_like 'a context pool' do
      let!(:pool) { AudioContextPool.new(1024) }
    end
  end

  describe VisualContextPool do
    it_behaves_like 'a context pool' do
      let!(:pool) do
        on_render_thread do
          VisualContextPool.new(@app.renderManager, @app.mixer.width,
                                @app.mixer.height, @app.mixer.tpf)
        end
      end

      it 'should reset a released context' do
        on_render_thread do
          context = pool.acquire_context

          bucket = context.render_bucket
          context.render_bucket = :gui

          node = JmeScene::Node.new('test')
          context.attach_child(node)

          pool.release_context(context)

          node.parent.should be_nil
          context.render_bucket.should_not be(:gui)
        end
      end
    end

  end
end
