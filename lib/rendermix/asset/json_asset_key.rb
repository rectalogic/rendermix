# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Asset
    class JSONAssetKey < Jme::Asset::AssetKey
      attr_reader :opts
      def initialize(name, opts={})
        super(name)
        opts.validate_keys(:symbolize_names)
        @opts = opts
      end

      def getCacheType
        Jme::Asset::Cache::WeakRefAssetCache.java_class
      end

      # We should override hashCode too, but it's not required
      # and having issues with the result overflowing to a BigInteger
      def equals(other)
        return false if not super(other)
        return self.opts == other.opts
      end
    end
  end
end
