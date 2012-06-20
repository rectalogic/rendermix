require_relative '../lib/rendermix'

class SceneViewer < RenderMix::JmeApp::SimpleApplication
  WIDTH = 640
  HEIGHT = 480

  def initialize(scene_file)
    super([RenderMix::JmeApp::FlyCamAppState.new].to_java(RenderMix::JmeAppState::AppState))
    self.showSettings = false
    settings = RenderMix::JmeSystem::AppSettings.new(false)
    settings.renderer = RenderMix::JmeSystem::AppSettings::LWJGL_OPENGL3
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
    asset_manager.registerLocator('/', RenderMix::JmeAssetPlugins::FileLocator.java_class)
    scene = asset_manager.loadModel(@scene_file)
    rootNode.attachChild(scene)
  end

#  def simpleUpdate(tpf)
#  end
end

sv = SceneViewer.new(ARGV.first)
sv.start
