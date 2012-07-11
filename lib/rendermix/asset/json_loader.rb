# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Asset
    class JSONLoader
      include Jme::Asset::AssetLoader

      def self.register(asset_manager)
        asset_manager.registerLoader(JSONLoader.become_java!, "js", "json")
      end

      def self.load(asset_manager, name)
        asset_manager.loadAsset(WeakCachedAssetKey.new(name))
      end

      # @param [Jme::Asset::AssetInfo] asset_info
      # @return [Hash] JSON
      def load(asset_info)
        is = asset_info.openStream
        JSON.load(is)
      ensure
        is.close
      end
      add_method_signature :load, [java.lang.Object, Jme::Asset::AssetInfo]
    end
  end
end
