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

    # Configure RawMedia logging
    logger = JavaLog::Logger.getLogger('RawMedia')
    current = logger
    until current.nil? or (level = current.level)
      current = current.parent
    end
    log = Proc.new do |msg|
      logger.logp(level, 'RawMedia', 'log', msg)
    end
    RawMedia::Log.set_callback(LEVEL_MAP[level], log)
  end
end
