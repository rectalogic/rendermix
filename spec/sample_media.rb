# Default location is one level above the rendermix root directory
SAMPLE_MEDIA = ENV.fetch('RENDERMIX_SAMPLE_MEDIA', File.expand_path('../../../rendermix-sample-media/media', __FILE__))

fail <<EOF unless File.directory?(SAMPLE_MEDIA)
RenderMix sample media not found at #{SAMPLE_MEDIA}
Set the 'RENDERMIX_SAMPLE_MEDIA' environment variable to point to it.
'git clone https://github.com/rectalogic/rendermix-sample-media.git' if needed.
EOF
