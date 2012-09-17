# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

$LOAD_PATH.unshift(File.expand_path('..', __FILE__)).uniq!

require 'rubygems'
require 'java'
require 'jruby/core_ext'
require 'thread'

require 'bundler'
Bundler.setup(:default)

require 'json'
require 'yaml'
require 'optparse'
require 'ostruct'
require 'rawmedia'
require_relative '../jme3/jMonkeyEngine3.jar'

require 'rendermix/java'
require 'rendermix/jme'
require 'rendermix/core_ext/array'
require 'rendermix/core_ext/hash'
require 'rendermix/errors'
require 'rendermix/timer'
require 'rendermix/log'
require 'rendermix/frame_time'
require 'rendermix/encoder'
require 'rendermix/mixer'
require 'rendermix/builder'
require 'rendermix/command'

require 'rendermix/audio_buffer'
require 'rendermix/audio_context'
require 'rendermix/scene_renderer'
require 'rendermix/visual_context'
require 'rendermix/context_manager'
require 'rendermix/ortho_quad'

require 'rendermix/asset/font_loader'
require 'rendermix/asset/json_loader'
require 'rendermix/asset/json_asset_key'

require 'rendermix/pan_zoom/timeline'
require 'rendermix/pan_zoom/keyframe'
require 'rendermix/pan_zoom/interpolator'
require 'rendermix/pan_zoom/linear'
require 'rendermix/pan_zoom/catmull_rom'

require 'rendermix/effect/text_texture'
require 'rendermix/effect/base'
require 'rendermix/effect/audio_base'
require 'rendermix/effect/visual_base'
require 'rendermix/effect/audio_mixer'
require 'rendermix/effect/image_processor'
require 'rendermix/effect/cinematic'

require 'rendermix/effect/animation/bezier_segment'
require 'rendermix/effect/animation/bezier_curve_interpolator'
require 'rendermix/effect/animation/constant_value_interpolator'
require 'rendermix/effect/animation/animator'
require 'rendermix/effect/animation/camera_data'

require 'rendermix/mix/effect_manager'
require 'rendermix/mix/render_manager'
require 'rendermix/mix/freezer'
require 'rendermix/mix/base'
require 'rendermix/mix/parallel'
require 'rendermix/mix/sequence'
require 'rendermix/mix/blank'
require 'rendermix/mix/image'
require 'rendermix/mix/media'
