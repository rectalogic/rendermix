# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test)

PKG = File.expand_path('../pkg', __FILE__)
directory PKG

FIXTURES = File.expand_path('../spec/fixtures', __FILE__)

task 'rendermix:media' do
  require_relative 'spec/sample_media'
end

load File.expand_path('../lib/tasks/doc.rake', __FILE__)
load File.expand_path('../lib/tasks/test.rake', __FILE__)
load File.expand_path('../lib/tasks/coverage.rake', __FILE__)
load File.expand_path('../lib/tasks/render.rake', __FILE__)
