require 'spec_helper'

module RenderMix
  describe JSONLoader do
    include_context 'requires render thread'

    it 'should load JSON' do
      on_render_thread do
        @app.mixer.asset_manager.registerLocator(FIXTURES, Jme::Asset::Plugins::FileLocator.java_class)
        anim = @app.mixer.asset_manager.loadAsset("animation/animation.json")
        anim["horizontalFOV"].should == 0.6833110451698303
      end
    end
  end
end
