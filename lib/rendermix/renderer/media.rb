module RenderMix
  module Renderer
    class Media < Base
      def initialize(rawmedia_session, filename, start_frame=0, duration=nil)
        #XXX init rawmedia and use duration if none specified
        super(duration)
      end

    end
  end
end
