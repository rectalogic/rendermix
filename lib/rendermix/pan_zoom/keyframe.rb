# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class Keyframe
      attr_accessor :time
      attr_reader :scale
      attr_reader :tx
      attr_reader :ty
      # @param [Hash] opts
      # @option opts [Float] :time
      # @option opts [Float] :scale (1.0)
      # @option opts [Float] :tx (0.0)
      # @option opts [Float] :ty (0.0)
      def initialize(opts)
        opts.validate_keys(:time, :scale, :tx, :ty)
        @time = opts.fetch(:time).to_f
        @scale = opts.fetch(:scale, 1.0).to_f
        @tx = opts.fetch(:tx, 0.0).to_f
        @ty = opts.fetch(:ty, 0.0).to_f
      rescue KeyError => e
        raise(InvalidMixError, "Missing keyframe value - #{e.message}")
      end
    end
  end
end
