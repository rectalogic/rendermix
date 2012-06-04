# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class AudioContextPool
    def initialize(size)
      @contexts = []
      @size = size
    end

    def acquire_context
      return @contexts.pop unless @contexts.empty?
      AudioContext.new(@size)
    end

    def release_context(context)
      @contexts << context if context
      reset_context(context)
    end

    def reset_context(context)
      #XXX should we zero buffer?
    end
  end
end
