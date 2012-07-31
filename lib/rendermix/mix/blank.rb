# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Blank < Base
      # @param [Hash] opts options
      # @option opts [Fixnum] :duration set blank duration (required)
      def initialize(mixer, opts)
        opts.validate_keys(:duration)
        super(mixer, opts.fetch(:duration)) rescue raise(InvalidMixError, "Blank requires duration")
      end
    end
  end
end
