# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

# Based on/copied from ActiveSupport

class Hash
  # Validate all keys in a hash match valid_keys,
  # raising ArgumentError on a mismatch.
  def validate_keys(*valid_keys)
    unknown_keys = keys - valid_keys
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end
end
