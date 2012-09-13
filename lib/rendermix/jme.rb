# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Jme
    module App
      include_package 'com.jme3.app'
      module State
        include_package 'com.jme3.app.state'
      end
    end
    module Animation
      include_package 'com.jme3.animation'
    end
    module Asset
      include_package 'com.jme3.asset'
      module Cache
        include_package 'com.jme3.asset.cache'
      end
      module Plugins
        include_package 'com.jme3.asset.plugins'
      end
    end
    module Material
      include_package 'com.jme3.material'
    end
    module Math
      include_package 'com.jme3.math'
    end
    module Post
      include_package 'com.jme3.post'
      module Filters
        include_package 'com.jme3.post.filters'
      end
    end
    module Renderer
      include_package 'com.jme3.renderer'
      module Queue
        include_package 'com.jme3.renderer.queue'
      end
    end
    module Scene
      include_package 'com.jme3.scene'
      module Shape
        include_package 'com.jme3.scene.shape'
      end
    end
    module Shader
      include_package 'com.jme3.shader'
    end
    module System
      include_package 'com.jme3.system'
    end
    module Texture
      include_package 'com.jme3.texture'
      module Plugins
        include_package 'com.jme3.texture.plugins'
      end
    end
  end
end
