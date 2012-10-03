# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Command
    def self.run(args)
      options = parse(args)

      setup_logging(options.loglevel)

      builder = Builder.new(options.width, options.height)
      manifest_root = File.dirname(File.expand_path(options.manifest))
      mixer, mix = builder.load(options.manifest, manifest_root,
                                options.mediaroot)
      if options.progress
        progress = lambda {|p| puts "f: #{p}" }
      end
      mixer.mix(mix, options.output, &progress)
    rescue Exception => e
      Log.log(JavaLog::Level::SEVERE,
              "Exception raised #{e.class} (#{e.message}):\n    " +
              e.backtrace.join("\n    "))
      exit 1
    rescue java.lang.Throwable => e
      Log.log(JavaLog::Level::SEVERE, 'Java exception raised', e)
      exit 1
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
        opts.on("-r", "--mediaroot DIRECTORY", "Directory to resolve relative media/image filenames against. Defaults to manifest directory.") do |r|
          options.mediaroot = r
        end
        opts.on("-p", "--progress", "Report progress (frames rendered)") do |p|
          options.progress = p
        end
        levels = %w(OFF SEVERE WARNING INFO CONFIG FINE FINER FINEST ALL)
        opts.on("-l", "--loglevel LEVEL", levels, "Set logging level") do |l|
          options.loglevel = l
        end
        opts.on_tail("-e", "--help", "Show this message") do
          puts opts
          exit
        end
      end

      begin
        opts.parse!(args)
      rescue OptionParser::InvalidArgument => e
        puts opts
        puts e.message
        exit 1
      end

      options.manifest = args.first
      unless options.manifest
        puts opts
        exit 1
      end

      options
    end

    def self.setup_logging(level_name)
      JavaLog::LogManager.getLogManager().reset
      handler = JavaLog::ConsoleHandler.new
      logger = JavaLog::Logger.getLogger('')
      logger.setLevel(JavaLog::Level::parse(level_name)) if level_name
      logger.addHandler(handler)
    end
  end
end
