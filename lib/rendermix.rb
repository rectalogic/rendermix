$LOAD_PATH.unshift(File.expand_path('..', __FILE__)).uniq!

require 'rubygems'
require 'java'
require 'thread'

require 'bundler'
Bundler.setup(:default)

require 'rawmedia'
require_relative '../jme3/jMonkeyEngine3.jar'

require 'rendermix/java'
require 'rendermix/jme'
require 'rendermix/errors'
require 'rendermix/timer'
require 'rendermix/log'
require 'rendermix/mixer'
require 'rendermix/command'

require 'rendermix/audio_context'
require 'rendermix/audio_context_pool'
require 'rendermix/visual_context'
require 'rendermix/visual_context_pool'
require 'rendermix/context_manager'
require 'rendermix/ortho_quad'

require 'rendermix/effect/base'
require 'rendermix/effect/audio'
require 'rendermix/effect/visual'

require 'rendermix/mix/effect_manager'
require 'rendermix/mix/render_manager'
require 'rendermix/mix/base'
require 'rendermix/mix/parallel'
require 'rendermix/mix/sequence'
require 'rendermix/mix/blank'
require 'rendermix/mix/image'
require 'rendermix/mix/media'
