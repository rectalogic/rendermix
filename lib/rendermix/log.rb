module RenderMix
  module Log
    LEVEL_MAP = {
      JavaLogging::Level::OFF => RawMedia::Log::LEVEL_QUIET,
      JavaLogging::Level::SEVERE => RawMedia::Log::LEVEL_ERROR,
      JavaLogging::Level::WARNING => RawMedia::Log::LEVEL_WARNING,
      JavaLogging::Level::INFO => RawMedia::Log::LEVEL_INFO,
      JavaLogging::Level::CONFIG => RawMedia::Log::LEVEL_VERBOSE,
      JavaLogging::Level::FINE => RawMedia::Log::LEVEL_VERBOSE,
      JavaLogging::Level::FINER => RawMedia::Log::LEVEL_DEBUG,
      JavaLogging::Level::FINEST => RawMedia::Log::LEVEL_DEBUG,
      JavaLogging::Level::ALL => RawMedia::Log::LEVEL_DEBUG,
      nil => RawMedia::Log::LEVEL_INFO,
    }
    # Configure RawMedia logging
    logger = java.util.logging.Logger.getLogger('RawMedia')
    until logger.nil? or (level = logger.level)
      logger = logger.parent
    end
    RawMedia::Log.set_callback(LEVEL_MAP[level],
                               Proc.new {|msg| logger.info(msg) })
  end
end
