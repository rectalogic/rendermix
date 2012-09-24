# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Command
    def self.run(args)
      options = parse(args)
      builder = Builder.new(options.width, options.height)
      mixer, mix = builder.load(options.manifest)
      if options.progress
        progress = lambda {|p| puts p }
      end
      mixer.mix(mix, options.output, &progress)
    end

    def self.parse(args)
      options = OpenStruct.new
      options.width = 320
      options.height = 240
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] <manifest-file>"
        opts.on("-w", "--width W", Integer, "Width of mix") do |w|
          options.width = w
        end
        opts.on("-h", "--height H", Integer, "Height of mix") do |h|
          options.height = h
        end
        opts.on("-o", "--output FILENAME", "File to encode") do |f|
          options.output = f
        end
        opts.on("-p", "--progress", "Report progress (frames rendered)") do |p|
          options.progress = p
        end
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
      opts.parse!(args)
      options.manifest = args.first
      unless options.manifest
        puts opts
        exit 1
      end
      options
    end
  end
end
