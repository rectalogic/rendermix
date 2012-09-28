# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Log
    LEVEL_MAP = {
      JavaLog::Level::OFF => RawMedia::Log::LEVEL_QUIET,
      JavaLog::Level::SEVERE => RawMedia::Log::LEVEL_ERROR,
      JavaLog::Level::WARNING => RawMedia::Log::LEVEL_WARNING,
      JavaLog::Level::INFO => RawMedia::Log::LEVEL_INFO,
      JavaLog::Level::CONFIG => RawMedia::Log::LEVEL_VERBOSE,
      JavaLog::Level::FINE => RawMedia::Log::LEVEL_VERBOSE,
      JavaLog::Level::FINER => RawMedia::Log::LEVEL_DEBUG,
      JavaLog::Level::FINEST => RawMedia::Log::LEVEL_DEBUG,
      JavaLog::Level::ALL => RawMedia::Log::LEVEL_DEBUG,
      nil => RawMedia::Log::LEVEL_INFO,
    }

    RENDERMIX_NAME = 'com.rendermix.RenderMix'
    RAWMEDIA_NAME = 'com.rendermix.RawMedia'

    # Configure RawMedia logging
    rmlogger = JavaLog::Logger.getLogger(RAWMEDIA_NAME)
    current = rmlogger
    until current.nil? or (level = current.level)
      current = current.parent
    end
    logproc = Proc.new do |msg|
      rmlogger.logp(level, RAWMEDIA_NAME, 'log', msg)
    end
    RawMedia::Log.set_callback(LEVEL_MAP[level], logproc)

    @@logger = JavaLog::Logger.getLogger(RENDERMIX_NAME)
    def self.log(level, msg, ex=nil)
      if ex
        @@logger.logp(level, RENDERMIX_NAME, 'log', msg, ex)
      else
        @@logger.logp(level, RENDERMIX_NAME, 'log', msg)
      end
    end
  end
end
