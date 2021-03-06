# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

class Array
  def deep_freeze
    each {|e| e.deep_freeze if e.respond_to? :deep_freeze }
    freeze
  end
end
