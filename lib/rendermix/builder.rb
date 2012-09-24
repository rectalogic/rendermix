# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class Builder
    # @param [Fixnum] width
    # @param [Fixnum] height
    def initialize(width, height)
      @width = width
      @height = height
    end

    def load(filename)
      root = File.dirname(File.expand_path(filename))
      case File.extname(filename)
      when ".yml", ".yaml"
        build(YAML::load(File.open(filename)), root)
      when ".js", ".json"
        File.open(filename, "r") do |f|
          build(JSON.load(f), root)
        end
      else
        raise(InvalidMixError, "Unrecognized file type #{filename}")
      end
    end

    # Mix manifest structure:
    # * +assets+ - array of asset paths
    # * +framerate+ - framerate of mix (Rational), defaults to 30/1
    # * +mix+ - (required) root mix element hash
    #
    # An element hash contains the following:
    # * +type+ - (required) element type, one of "blank", "image", "media",
    #   "sequence" or "parallel"
    # * +visual_effects+ - array of effect hashes. Each effect has the
    #   following keys:
    #   * +in+ - (required) in frame number
    #   * +out+ - (required) out frame number
    #   * +type+ - (required) effect type, "cinematic" or "image_processor"
    #     * "cinematic" - contains the following keys:
    #       * +manifest+ - (required) asset path to manifest JSON.
    #         See {Effect::Cinematic#initialize}.
    #       * +textures+ - array of texture names
    #       * +texts+ - hash mapping text names to values
    #     * "image_processor" - contains the following keys:
    #       * +material+ - (required) asset path to material definition.
    #         See {Effect::ImageProcessor#initialize}.
    #       * +textures+ - array of texture uniform names
    # * +audio_effects+ - array of audio mixing effect hashes. Each effect
    #   has the following keys:
    #   * +in+ - (required) in frame number
    #   * +out+ - (required) out frame number
    #
    # Each element type may contain type specific keys:
    # * "blank" - See {Mix::Blank#initialize}
    # * "image", "media" - See {Mix::Image#initialize}
    #   and {Mix::Media#initialize}
    #   * +filename+ - (required) path to image/media file
    #   * +panzoom+ - panzoom timeline, see {PanZoom::Timeline#initialize}
    #     contains:
    #     * "interpolator" - "linear" or "catmull"
    #     * "fit" - "meet", "fill" or "auto"
    #     * "keyframes" - (required) array of panzoom keyframe hashes.
    #       See {PanZoom::Keyframe#initialize} for keyframe key values.
    # * "sequence", "parallel" - see {Mix::Sequence#initialize}
    #   and {Mix::Parallel#initialize}. Also contains:
    #   * +elements+ - (required) array of child mix element hashes.
    #
    # @param [Hash] manifest describes mix structure
    # @param [String] root_directory all paths in manifest will be resolved
    #   relative to this directory if specified.
    # @return [Mixer, Mix::Base] mixer and root of mix
    def build(manifest, root_directory=nil)
      manifest.validate_keys("assets", "framerate", "mix")
      framerate = Rational(manifest.fetch("framerate", 30))
      mixer = Mixer.new(@width, @height, framerate)
      register_assets(manifest["assets"], mixer, root_directory)
      mix = process_mix_element(manifest.fetch("mix"), mixer, root_directory)
      return mixer, mix
    rescue KeyError => e
      raise(InvalidMixError, "Missing manifest key - #{e.message}")
    end

    def register_assets(assets, mixer, root_directory)
      return unless assets
      assets.each do |asset|
        asset_location = File.expand_path(asset, root_directory)
        mixer.register_asset_location(asset_location)
      end
    end
    private :register_assets

    def process_mix_element(element, mixer, root_directory)
      case element.delete("type")
      when "blank"
        process_blank_element(element, mixer)
      when "image"
        process_image_element(element, mixer, root_directory)
      when "media"
        process_media_element(element, mixer, root_directory)
      when "sequence"
        process_sequence_element(element, mixer, root_directory)
      when "parallel"
        process_parallel_element(element, mixer, root_directory)
      when nil
        raise(InvalidMixError, "Mix element type missing")
      else
        raise(InvalidMixError, "Invalid mix element type")
      end
    end
    private :process_mix_element

    def process_blank_element(element, mixer)
      opts = element.dup
      visual_effects = element_visual_effects(opts)
      blank = mixer.new_blank(opts.symbolize_keys!)
      apply_element_visual_effects(blank, visual_effects)
      blank
    end
    private :process_blank_element

    def process_image_element(element, mixer, root_directory)
      filename = element_filename(element, root_directory)
      opts = element.dup
      process_element_panzoom(opts)
      visual_effects = element_visual_effects(opts)
      audio_effects = element_audio_effects(opts)
      opts.symbolize_keys!
      image = mixer.new_image(filename, opts)
      apply_element_visual_effects(image, visual_effects)
      apply_element_audio_effects(image, audio_effects)
      image
    end
    private :process_image_element

    def process_media_element(element, mixer, root_directory)
      filename = element_filename(element, root_directory)
      opts = element.dup
      process_element_panzoom(opts)
      visual_effects = element_visual_effects(opts)
      audio_effects = element_audio_effects(opts)
      opts.symbolize_keys!
      media = mixer.new_media(filename, opts)
      apply_element_visual_effects(media, visual_effects)
      apply_element_audio_effects(media, audio_effects)
      media
    end
    private :process_media_element

    def process_sequence_element(element, mixer, root_directory)
      elements = element.fetch("elements").collect do |e|
        process_mix_element(e, mixer, root_directory)
      end
      sequence = mixer.new_sequence(elements)
      apply_element_visual_effects(sequence, element.fetch("visual_effects", []))
      apply_element_audio_effects(sequence, element.fetch("audio_effects", []))
      sequence
    end
    private :process_sequence_element

    def process_parallel_element(element, mixer, root_directory)
      elements = element.fetch("elements").collect do |e|
        process_mix_element(e, mixer, root_directory)
      end
      parallel = mixer.new_parallel(elements)
      apply_element_visual_effects(parallel, element.fetch("visual_effects", []))
      apply_element_audio_effects(parallel, element.fetch("audio_effects", []))
      parallel
    end
    private :process_parallel_element

    def apply_element_visual_effects(mix, effects)
      effects.each do |e|
        case e.fetch("type")
        when "cinematic"
          e.validate_keys("type", "in", "out", "manifest", "textures", "texts")
          effect = Effect::Cinematic.new(e.fetch("manifest"),
                                         e.fetch("textures", []),
                                         e.fetch("texts", {}))
        when "image_processor"
          e.validate_keys("type", "in", "out", "material", "textures")
          effect = Effect::ImageProcessor.new(e.fetch("material"),
                                              e.fetch("textures", []))
        else
          raise(InvalidMixError, "Invalid visual effect type")
        end
        mix.apply_visual_effect(effect,
                                e.fetch("in").to_i,
                                e.fetch("out").to_i)
      end
    end
    private :apply_element_visual_effects

    def apply_element_audio_effects(mix, effects)
      effects.each do |e|
        mix.apply_audio_effect(Effect::AudioMixer.new,
                               e.fetch("in").to_i,
                               e.fetch("out").to_i)
      end
    end
    private :apply_element_audio_effects

    def element_visual_effects(element)
      element.delete("visual_effects") || []
    end
    private :element_visual_effects

    def element_audio_effects(element)
      element.delete("audio_effects") || []
    end
    private :element_audio_effects

    def process_element_panzoom(element)
      panzoom = element.delete("panzoom")
      return unless panzoom
      panzoom.symbolize_keys!
      panzoom.validate_keys(:keyframes, :interpolator, :fit)
      keyframes = panzoom.fetch(:keyframes).collect do |k|
        PanZoom::Keyframe.new(k.symbolize_keys!)
      end
      panzoom.delete(:keyframes)
      element[:panzoom] = PanZoom::Timeline.new(keyframes, panzoom)
    end
    private :process_element_panzoom

    def element_filename(element, root_directory)
      File.expand_path(element.delete("filename"), root_directory) || raise(InvalidMixError, "Mix element missing filename")
    end
    private :element_filename
  end
end
