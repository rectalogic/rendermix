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
  CAMERA_DISTANCE = 10

  include RenderMix::Jme::Input::Controls::ActionListener
  include RenderMix::Jme::Scene::SceneGraphVisitor

  def initialize(scene_file)
    super([RenderMix::Jme::App::FlyCamAppState.new, RenderMix::Jme::App::DebugKeysAppState.new].to_java(RenderMix::Jme::App::State::AppState))
    configure_settings do |settings|
      settings.setResolution(WIDTH, HEIGHT)
      settings.useInput = true
    end
    @scene_file = scene_file
  end

  def simpleInitApp
    self.flyByCamera.dragToRotate = true
    asset_manager.registerLocator('/', RenderMix::Jme::Asset::Plugins::FileLocator.java_class)
    scene = asset_manager.loadModel(@scene_file)
    rootNode.attachChild(scene)
    init_keys

    # Dump scene graph
    puts "Dumping scene graph"
    scene.depthFirstTraversal(self)
  end

  # Implements Jme::Scene::SceneGraphVisitor
  def visit(spatial)
    puts "#{spatial.name} #{spatial.java_class.name}"
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
  sv = SceneViewer.new(ARGV.first)
  sv.start
end
