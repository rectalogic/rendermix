# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class Mixer
    attr_reader :width
    attr_reader :height
    attr_reader :framerate
    attr_reader :rawmedia_session
    # @return [RenderSystem]
    attr_reader :render_system

    def initialize(width, height, framerate=Rational(30))
      @width = width
      @height = height
      @framerate = framerate
      @rawmedia_session = RawMedia::Session.new(framerate)
      @asset_locations = []
      @render_system = create_render_system(@asset_locations)
    end

    # @param [String] location filesystem path to an asset root.
    #  Root directory or zip file.
    def register_asset_location(location)
      raise(InvalidMixError, "Asset location does not exist") unless File.exist?(location)
      @asset_locations.push(location) unless @asset_locations.include?(location)
    end

    # @param [Hash] opts (see {Mix::Blank#initialize})
    def new_blank(opts)
      Mix::Blank.new(self, opts)
    end

    # @param [Array<Mix::Base>] mix_elements
    def new_sequence(*mix_elements)
      Mix::Sequence.new(self, mix_elements.flatten)
    end

    # @param [Array<Mix::Base>] mix_elements
    def new_parallel(*mix_elements)
      Mix::Parallel.new(self, mix_elements.flatten)
    end

    # @param [String] filename
    # @param [Hash] opts (see {Mix::Image#initialize})
    def new_image(filename, opts={})
      Mix::Image.new(self, filename, opts)
    end

    # @param [String] filename
    # @param [Hash] opts (see {Mix::Media#initialize})
    def new_media(filename, opts={})
      Mix::Media.new(self, filename, opts)
    end

    # @param [Mix::Base] mix root element of the mix
    # @param [String] filename the output video filename to encode into
    # @yieldparam [Fixnum] frame number being rendered
    def mix(mix, filename=nil, &progress_block)
      mix.validate(self)
      @render_system.mix(mix, filename, &progress_block)
    end

    # @return [MixRenderSystem]
    def create_render_system(asset_locations)
      MixRenderSystem.new(self, asset_locations)
    end
    protected :create_render_system
  end
end
