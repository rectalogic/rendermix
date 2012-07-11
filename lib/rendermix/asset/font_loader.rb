# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Asset
    class FontLoader
      include Jme::Asset::AssetLoader

      def self.register(asset_manager)
        asset_manager.registerLoader(FontLoader.become_java!, "ttf")
      end

      def self.load(asset_manager, name)
        # Use AssetKey, it permanently caches
        asset_manager.loadAsset(Jme::Asset::AssetKey.new(name))
      end

      # @param [Jme::Asset::AssetInfo] asset_info
      # @return [JavaAWT::Font] font
      def load(asset_info)
        is = asset_info.openStream
        JavaAWT::Font.createFont(JavaAWT::Font::TRUETYPE_FONT, is)
      ensure
        is.close
      end
      add_method_signature :load, [java.lang.Object, Jme::Asset::AssetInfo]
    end
  end
end
