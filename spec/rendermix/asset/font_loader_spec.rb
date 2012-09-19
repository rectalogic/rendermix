require 'spec_helper'

module RenderMix
  module Asset
    describe FontLoader do
      include_context 'requires render thread'

      it 'should load a Font' do
        on_render_thread do
          register_test_assets
          font = FontLoader.load(@mixer.render_system.asset_manager, "fonts/MarkerSD.ttf")
          font.family.should eq "MarkerSD"
          font.numGlyphs.should eq 221
        end
      end
    end
  end
end
