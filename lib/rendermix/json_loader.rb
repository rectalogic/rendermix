# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class JSONLoader
    include Jme::Asset::AssetLoader

    # @param [Jme::Asset::AssetInfo] asset_info
    # @return [Hash] JSON
    def load(asset_info)
      JSON.load(asset_info.openStream)
    end
    add_method_signature :load, [java.lang.Object, Jme::Asset::AssetInfo]
  end
end
