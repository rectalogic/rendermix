# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Asset
    class JSONLoader
      include Jme::Asset::AssetLoader

      def self.register(asset_manager)
        asset_manager.registerLoader(JSONLoader.become_java!, "js", "json")
      end

      # @param [Hash] opts
      # @option opts [Boolean] :symbolize_names if true, symbolize key names
      def self.load(asset_manager, name, opts={})
        asset_manager.loadAsset(JSONAssetKey.new(name, opts))
      end

      # @param [Jme::Asset::AssetInfo] asset_info
      # @return [Hash] JSON
      def load(asset_info)
        is = asset_info.openStream
        # Freeze since it's cached
        JSON.parse(is.to_io.read, asset_info.key.opts).deep_freeze
      ensure
        is.close
      end
      add_method_signature :load, [java.lang.Object, Jme::Asset::AssetInfo]
    end
  end
end
