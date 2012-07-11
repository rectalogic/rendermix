# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Asset
    # {Jme::Asset::AssetKey} uses {Jme::Asset::SimpleAssetCache} by default.
    # For cases where we want a weak cache, this key can be used.
    class WeakCachedAssetKey < Jme::Asset::AssetKey
      def initialize(name)
        super
      end

      def getCacheType
        Jme::Asset::Cache::WeakRefAssetCache.java_class
      end
    end
  end
end
