require 'spec_helper'

module RenderMix
  describe JSONLoader do
    include_context 'requires render thread'

    it 'should load JSON' do
      on_render_thread do
        register_test_assets
        anim = @app.mixer.asset_manager.loadAsset("animation/animation.json")
        anim.has_key?('camera').should be_true
        anim['camera']["horizontalFOV"].should == 0.6833110451698303
      end
    end
  end
end
