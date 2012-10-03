namespace 'render' do

  task :mix, [:manifest, :media] => 'rendermix:media' do |t, args|
    fail "Must specify :manifest and output :media args" unless args[:manifest] and args[:media]
    rendermix = File.expand_path('../../../bin/rendermix', __FILE__)
    # Disable UI when invoking on Mac
    #XXX pass root, check it exists and allow env override
    ruby %{-J-Dapple.awt.UIElement=true "#{rendermix}" -p -w 320 -h 240 -r "#{SAMPLE_MEDIA}" -o "#{args[:media]}" "#{args[:manifest]}"}
  end

  task :crc, [:media, :crc] do |t, args|
    fail "Must specify input :media and output :crc args" unless args[:media] and args[:crc]
    ffmpeg = ENV.fetch('FFMPEG', 'ffmpeg')
    sh %{"#{ffmpeg}" -i "#{args[:media]}" -codec:a copy -codec:v copy -f framecrc -y "#{args[:crc]}"}
  end

  task :manifest_crc, [:manifest_dir, :media_dir, :crc_dir] do |t, args|
    args.with_defaults(manifest_dir: File.join(FIXTURES, 'manifests'),
                       media_dir: MEDIA_DEFAULT, crc_dir: CRC_DEFAULT)
    FileList.new("#{args[:manifest_dir]}/*.json").each do |manifest|
      media = File.join(args[:media_dir], manifest.pathmap('%n.mov'))
      crc = File.join(args[:crc_dir], manifest.pathmap('%n.crc'))
      task('render:mix').reenable
      task('render:mix').invoke(manifest, media)
      task('render:crc').reenable
      task('render:crc').invoke(media, crc)
    end
  end

  task :compare_crc, [:crc_dir, :reference_dir] do |t, args|
    args.with_defaults(crc_dir: CRC_DEFAULT,
                       reference_dir: File.expand_path('../../../spec/fixtures/crc', __FILE__))

    crc = FileList.new("#{args[:crc_dir]}/*.crc")
    reference = FileList.new("#{args[:reference_dir]}/*.crc")
    missing = reference.pathmap('%f') - crc.pathmap('%f')
    extra = crc.pathmap('%f') - reference.pathmap('%f')
    different = []
    reference.each do |ref|
      c = ref.pathmap("#{args[:crc_dir]}/%f")
      next unless File.exist?(c)
      different << c.pathmap('%f') unless FileUtils.compare_file(c, ref)
    end

    puts "\n\nRegression finished."
    warn "CRC files have no reference: #{extra.join(', ')}" unless extra.empty?
    msg = []
    msg << "Missing CRC files: #{missing.join(', ')}" unless missing.empty?
    msg << "CRC files not identical: #{different.join(', ')}" unless different.empty?
    fail %(Regression tests failed:\n#{msg.join("\n")}) unless msg.empty?
  end

  desc "Regression test manifest and compare mix CRCs"
  task :regression, [:manifest_dir, :media_dir, :crc_dir, :reference_dir] => ['render:manifest_crc', 'render:compare_crc']

  CRC_DEFAULT = File.join(PKG, 'crc')
  MEDIA_DEFAULT = File.join(PKG, 'render')
  directory CRC_DEFAULT
  directory MEDIA_DEFAULT

  desc "Run local mix manifest fixture regression tests"
  task :test => [CRC_DEFAULT, MEDIA_DEFAULT, 'render:regression']
end
