# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Command
    def self.run(args)
      #XXX make size an option
      mixer = Mixer.new(320, 240, Rational(30))
      builder = Builder.new(mixer)
      #XXX manifest option
      mix = builder.load(args.first)
      #XXX option to encode
      mixer.mix(mix)
    end
  end
end
