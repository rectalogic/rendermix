require 'spec_helper'

module RenderMix
  module Asset
    describe JSONLoader do
      include_context 'requires render thread'

      it 'should load JSON' do
        on_render_thread do
          register_test_assets
          anim = JSONLoader.load(@mixer.render_system.asset_manager, "animation/animation.json")
          anim.has_key?('camera').should be_true
          anim['camera']["horizontalFOV"].should == 0.6833110451698303
        end
      end

      it 'should load JSON and symbolize names' do
        on_render_thread do
          register_test_assets
          anim = JSONLoader.load(@mixer.render_system.asset_manager, "animation/animation.json", symbolize_names: true)
          anim.has_key?(:camera).should be_true
          anim[:camera][:horizontalFOV].should == 0.6833110451698303
        end
      end

      it 'should load recursively frozen JSON' do
        on_render_thread do
          register_test_assets
          anim = JSONLoader.load(@mixer.render_system.asset_manager, "animation/animation.json")
          expect { anim.delete('camera') }.to raise_error(RuntimeError)
          expect { anim['camera'].delete('horizontalFOV') }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
