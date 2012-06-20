require_relative '../lib/rendermix'

module RenderMix
  module Jme
    module Input
      include_package 'com.jme3.input'
      module Controls
        include_package 'com.jme3.input.controls'
      end
    end
  end
end

class SceneViewer < RenderMix::ApplicationBase
  WIDTH = 640
  HEIGHT = 480
  include RenderMix::Jme::Input::Controls::ActionListener

  def initialize(scene_file)
    super([RenderMix::Jme::App::FlyCamAppState.new, RenderMix::Jme::App::DebugKeysAppState.new].to_java(RenderMix::Jme::App::State::AppState))
    settings = default_settings
    settings.setResolution(WIDTH, HEIGHT)
    settings.useInput = true
    self.settings = settings
    @scene_file = scene_file
  end

  def simpleInitApp
    self.flyByCamera.dragToRotate = true
    asset_manager.registerLocator('/', RenderMix::Jme::Asset::Plugins::FileLocator.java_class)
    scene = asset_manager.loadModel(@scene_file)
    rootNode.attachChild(scene)
    init_keys
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

  def onAction(name, is_pressed, tpf)
    return if is_pressed
    puts name
    case name
    when "CameraPosX"
      location = RenderMix::Jme::Math::Vector3f::UNIT_X.multLocal(10)
      direction = RenderMix::Jme::Math::Vector3f::UNIT_X.negateLocal
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    when "CameraNegX"
      location = RenderMix::Jme::Math::Vector3f::UNIT_X.multLocal(-10)
      direction = RenderMix::Jme::Math::Vector3f::UNIT_X
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    when "CameraPosY"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Y.multLocal(10)
      direction = RenderMix::Jme::Math::Vector3f::UNIT_Y.negateLocal
      up = RenderMix::Jme::Math::Vector3f::UNIT_Z
    when "CameraNegY"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Y.multLocal(-10)
      direction = RenderMix::Jme::Math::Vector3f::UNIT_Y
      up = RenderMix::Jme::Math::Vector3f::UNIT_Z
    when "CameraPosZ"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Z.multLocal(10)
      direction = RenderMix::Jme::Math::Vector3f::UNIT_Z.negateLocal
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    when "CameraNegZ"
      location = RenderMix::Jme::Math::Vector3f::UNIT_Z.multLocal(-10)
      direction = RenderMix::Jme::Math::Vector3f::UNIT_Z
      up = RenderMix::Jme::Math::Vector3f::UNIT_Y
    end
    self.camera.setLocation(location)
    self.camera.lookAtDirection(direction, up)
  end

#  def simpleUpdate(tpf)
#  end
end

sv = SceneViewer.new(ARGV.first)
sv.start
