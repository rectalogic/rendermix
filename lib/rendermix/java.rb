# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module JavaLog
    include_package 'java.util.logging'
  end
  module JavaNIO
    include_package 'java.nio'
  end
  module JavaAWT
    include_package 'java.awt'
    module Image
      include_package 'java.awt.image'
    end
    module Fonts
      include_package 'java.awt.font'
    end
  end
end
