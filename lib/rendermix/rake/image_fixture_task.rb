# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

require 'rake'
require 'rake/tasklib'

module RenderMix
  module Rake
    # Rake task to generate an image file test fixture
    # Requires ImageMagick
    class ImageFixtureTask < ::Rake::TaskLib

      # @return [String] the output file name, and task name
      attr_accessor :filename

      # @return [Fixnum] the image width
      attr_accessor :width

      # @return [Fixnum] the image height
      attr_accessor :height

      # @return [Fixnum] the corner size
      attr_accessor :corner_size

      # @return [String] the background color
      attr_accessor :background_color

      # @return [String] the circle color
      attr_accessor :circle_color

      # @return [String] the corner color
      attr_accessor :corner_color

      def initialize(filename)
        @filename = filename
        @width = 640
        @height = 480
        @corner_size = 16
        @background_color = 'red'
        @circle_color = 'yellow'
        @corner_color = 'blue'

        yield self if block_given?

        define
      end

      def define
        desc "Generate an image file fixture"
        file filename do
          point = @width > @height ? "#{@width/2},0" : "0,#{@height/2}"
          circle = "#{@width/2},#{@height/2} #{point}"
          fontsize = @height / 10
          sh %(convert -size #{@width}x#{@height} xc:#{@background_color} -draw "#{corners(@width, @height, @corner_color, @corner_size)}" -draw 'fill #{@circle_color} circle #{circle}' -gravity center -font "Helvetica" -pointsize #{fontsize} -draw 'fill #{@background_color} text 0,0 "#{@width}x#{@height}"' -depth 8 "#{filename}")
        end
      end
      protected :define

      def corners(width, height, color, size)
        drawstr = "fill #{color}"
        drawstr << " rectangle 0,0 #{size},#{size}" # Upper left
        drawstr << " rectangle #{width-size},0 #{width},#{size}" # Upper right
        drawstr << " rectangle 0,#{height-size} #{size},#{height}" # Lower left
        drawstr << " rectangle #{width-size},#{height-size} #{width},#{height}" # Lower right
      end
      protected :corners
    end
  end
end
