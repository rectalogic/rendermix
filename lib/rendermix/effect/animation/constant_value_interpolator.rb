# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    module Animation
      class ConstantValueInterpolator
        def initialize(value)
          @value = value
        end

        def evaluate(x)
          return @value
        end
      end
    end
  end
end
