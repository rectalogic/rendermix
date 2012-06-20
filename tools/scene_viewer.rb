require_relative '../lib/rendermix'

class SceneViewer < RenderMix::Jme::App::SimpleApplication
  WIDTH = 640
  HEIGHT = 480

  def initialize(scene_file)
    super([RenderMix::Jme::App::FlyCamAppState.new].to_java(RenderMix::Jme::AppState::AppState))
    self.showSettings = false
    settings = RenderMix::Jme::System::AppSettings.new(false)
    settings.renderer = RenderMix::Jme::System::AppSettings::LWJGL_OPENGL3
    settings.setResolution(WIDTH, HEIGHT)
    settings.setSamples(4) # MSAA
    settings.useInput = true
    settings.useJoysticks = false
    settings.audioRenderer = nil
    self.settings = settings
    @scene_file = scene_file
  end

  def simpleInitApp
    self.flyByCamera.dragToRotate = true
    asset_manager.registerLocator('/', RenderMix::Jme::Asset::Plugins::FileLocator.java_class)
    scene = asset_manager.loadModel(@scene_file)
    rootNode.attachChild(scene)
  end

#  def simpleUpdate(tpf)
#  end
end

sv = SceneViewer.new(ARGV.first)
sv.start
