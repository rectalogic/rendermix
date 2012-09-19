#!/usr/bin/env jruby

require_relative '../lib/rendermix'

module RenderMix
  module Jme
    module Input
      include_package 'com.jme3.input'
      module Controls
        include_package 'com.jme3.input.controls'
      end
    end
    module Animation
      include_package 'com.jme3.animation'
    end
  end
end

class SceneViewer < RenderMix::Jme::App::SimpleApplication
  WIDTH = 640
  HEIGHT = 480
  CAMERA_DISTANCE = 10

  include RenderMix::Jme::Input::Controls::ActionListener
  include RenderMix::Jme::Scene::SceneGraphVisitor

  def initialize(model_key)
    super([RenderMix::Jme::App::FlyCamAppState.new, RenderMix::Jme::App::DebugKeysAppState.new].to_java(RenderMix::Jme::App::State::AppState))
    settings = RenderMix::Jme::System::AppSettings.new(true)
    settings.setResolution(WIDTH, HEIGHT)
    settings.setSamples(1)
    settings.frameRate = 30
    settings.useInput = true
    settings.useJoysticks = false
    settings.audioRenderer = nil
    self.settings = settings
    self.showSettings = false
    @model_key = model_key
  end

  def simpleInitApp
    self.flyByCamera.dragToRotate = true
    asset_manager.registerLocator('/', RenderMix::Jme::Asset::Plugins::FileLocator.java_class)
    scene = asset_manager.loadModel(@model_key)
    rootNode.attachChild(scene)
    init_keys

    # Dump scene graph
    puts "Dumping scene graph"
    scene.depthFirstTraversal(self)

    # Add antialiasing
    fpp = RenderMix::Jme::Post::FilterPostProcessor.new(asset_manager)
    fxaa = RenderMix::Jme::Post::Filters::FXAAFilter.new
    # Higher quality, but blurrier
    fxaa.subPixelShift = 0
    fxaa.reduceMul = 0
    fpp.addFilter(fxaa)
    self.viewPort.addProcessor(fpp)
  end

  # Implements Jme::Scene::SceneGraphVisitor
  def visit(spatial)
    puts "#{spatial.name} #{spatial.java_class.name}"
    control = spatial.getControl(RenderMix::Jme::Animation::AnimControl.java_class)
    if control
      names = control.getAnimationNames
      puts "animations #{names}" unless names.isEmpty
    end
  end

  def init_keys
    inputManager.addMapping("CameraPosX", RenderMix::Jme::Input::Controls::KeyTrigger.new(RenderMix::Jme::Input::KeyInput.KEY_1));
    inputManager.addMapping("CameraNegX", RenderMix::Jme::Input::Controls::KeyTrigger.new(RenderMix::Jme::Input::KeyInput.KEY_2));
    inputManager.addMapping("CameraPosY", RenderMix::Jme::Input::Controls::KeyTrigger.new(RenderMix::Jme::Input::KeyInput.KEY_3));
    inputManager.addMapping("CameraNegY", RenderMix::Jme::Input::Controls::KeyTrigger.new(RenderMix::Jme::Input::KeyInput.KEY_4));
    inputManager.addMapping("CameraPosZ", RenderMix::Jme::Input::Controls::KeyTrigger.new(RenderMix::Jme::Input::KeyInput.KEY_5));
    inputManager.addMapping("CameraNegZ", RenderMix::Jme::Input::Controls::KeyTrigger.new(RenderMix::Jme::Input::KeyInput.KEY_6));

    inputManager.addListener(self, "CameraPosX", "CameraNegX",
                             "CameraPosY", "CameraNegY", "CameraPosZ",
                             "CameraNegZ")
  end

  # Implements Jme::Input::Controls::ActionListener
  def onAction(name, is_pressed, tpf)
    return if is_pressed
    puts name
    case name
    when "CameraPosX"
      location = RenderMix::Jme::Math::Vector3f::UNIT_X.mult(CAMERA_DISTANCE)
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    when "CameraNegX"
      location = RenderMix::Jme::Math::Vector3f::UNIT_X.mult(-CAMERA_DISTANCE)
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    when "CameraPosY"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Y.mult(CAMERA_DISTANCE)
      up = RenderMix::Jme::Math::Vector3f::UNIT_Z
    when "CameraNegY"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Y.mult(-CAMERA_DISTANCE)
      up = RenderMix::Jme::Math::Vector3f::UNIT_Z
    when "CameraPosZ"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Z.mult(CAMERA_DISTANCE)
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    when "CameraNegZ"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Z.mult(-CAMERA_DISTANCE)
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    end
    self.camera.setLocation(location)
    self.camera.lookAt(RenderMix::Jme::Math::Vector3f::ZERO, up)
  end

#  def simpleUpdate(tpf)
#  end
end

if __FILE__== $0
  sv = SceneViewer.new(RenderMix::Jme::Asset::ModelKey.new(ARGV.first))
  sv.start
end
