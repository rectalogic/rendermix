# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    # Including class must expose a +mixer+ method
    module TextTexture
      # @param [String] text the string to render
      # @param [Hash] opts
      # @option opts [Float] :width width of texture as a percentage of Mixer width
      #   (0..1).
      # @option opts [Rational] :aspect_ratio aspect ratio of image
      #   (width:height). This should be the aspect ratio of the Mesh
      #   that will be textured to avoid distorting the image.
      #   Can be specified as a String (e.g. "4/3") or Float.
      # @option opts [String] :font_name ("Dialog") name of system font.
      #   Ignored if :font_asset specified.
      # @option opts [String] :font_asset asset path to a TrueType font file
      # @option opts [Float] :font_size (0.8) font size as a percentage of
      #   image height (e.g. 0.8 would be 80% of image height).
      # @option opts [Array<Float>] :text_color (\[0,0,0,1\]) color of the text,
      #   \[R,G,B,A\].
      # @option opts [Array<Float>] :background_color (\[0,0,0,0\])
      #   background color, \[R,G,B,A\].
      # @option opts [Array<Float>] :margin (\[0,0\]) space around text as
      #   a percentage of width and height (0..1).
      # @option opts [String] :text_align ("center") horizontal text
      #   alignment, one of "left", "right" or "center".
      # @option opts [String] :text_baseline ("middle") vertical text
      #   alignment of baseline, one of "top", "middle" or "bottom".
      # @option opts [Boolean] :flip_y (false) true if image should be
      #   flipped vertically.
      def create_text_texture(text, opts)
        opts.validate_keys(:width, :aspect_ratio, :font_name, :font_asset, :font_size, :text_color, :background_color, :margin, :text_align, :text_baseline, :flip_y)

        width = opts.fetch(:width).to_f rescue raise(InvalidMixError, "Missing text width key")
        aspect_ratio = Rational(opts.fetch(:aspect_ratio)).to_f rescue raise(InvalidMixError, "Missing text aspect_ratio key")

        image_width = (mixer.width * width).to_i
        image_height = (image_width / aspect_ratio.to_f).to_i
        box_width = image_width
        box_height = image_height
        margin_x = 0
        margin_y = 0
        if opts.has_key?(:margin)
          margin_x, margin_y = opts[:margin]
          margin_x = (margin_x.to_f * image_width).to_i
          margin_y = (margin_y.to_f * image_height).to_i
          box_width -= 2 * margin_x
          box_height -= 2 * margin_y
          raise(InvalidMixError, "Illegal text margin") if box_width <=0 || box_height <= 0
        end

        font_size = (opts.fetch(:font_size, 0.8) * image_height).to_f

        if opts.has_key?(:font_asset)
          font = Asset::FontLoader.load(mixer.asset_manager, opts[:font_asset])
          font = font.deriveFont(font_size)
        else
          font_name = opts.fetch(:font_name, JavaAWT::Font::DIALOG)
          font = JavaAWT::Font.new(font_name, JavaAWT::Font::PLAIN, font_size)
        end

        text_color = opts.has_key?(:text_color) ?
          TextTexture.create_color(opts[:text_color]) :
          JavaAWT::BLACK
        background_color = opts.has_key?(:background_color) ?
          TextTexture.create_color(opts[:background_color]) :
          JavaAWT::Color.new(0.0, 0.0, 0.0, 0.0)

        buffered_image = JavaAWT::Image::BufferedImage.new(image_width,
                                                           image_height,
                                                           JavaAWT::Image::BufferedImage::TYPE_4BYTE_ABGR)

        g2d = buffered_image.createGraphics
        g2d.setRenderingHint(JavaAWT::RenderingHints::KEY_TEXT_ANTIALIASING,
                             JavaAWT::RenderingHints::VALUE_TEXT_ANTIALIAS_ON)
        g2d.setRenderingHint(JavaAWT::RenderingHints::KEY_FRACTIONALMETRICS,
                             JavaAWT::RenderingHints::VALUE_FRACTIONALMETRICS_ON)
        g2d.setRenderingHint(JavaAWT::RenderingHints::KEY_RENDERING,
                             JavaAWT::RenderingHints::VALUE_RENDER_QUALITY)
        g2d.background = background_color
        g2d.color = text_color
        g2d.font = font
        g2d.clearRect(0, 0, image_width, image_height)

        layout = JavaAWT::Fonts::TextLayout.new(text, font, g2d.fontRenderContext)
        text_bounds = layout.bounds

        scale = [box_width / text_bounds.width, box_height / text_bounds.height].min
        scale = scale > 1 ? 1 : scale

        y_scale = opts[:flip_y] ? -scale : scale
        position_scale = 1.0
        if y_scale < 1
          g2d.translate(0, image_height) if y_scale < 0
          g2d.scale(scale, y_scale)
          position_scale = 1.0 / scale
          text_bounds.x *= scale
          text_bounds.y *= scale
          text_bounds.width *= scale
          text_bounds.height *= scale
        end

        #XXX what about alignment of multiple lines of text?
        case opts.fetch(:text_align, "left")
        when "right"
          x = margin_x + box_width - text_bounds.width
        when "center"
          x = margin_x + (box_width - text_bounds.width) / 2.0
        when "left"
          x = margin_x
        else
          raise(InvalidMixError, "Invalid text_align")
        end

        case opts.fetch(:text_baseline, "middle")
        when "bottom"
          y = margin_y + box_height - text_bounds.height
        when "middle"
          y = margin_y + (box_height - text_bounds.height) / 2.0
        when "top"
          y = margin_y
        else
          raise(InvalidMixError, "Invalid text_baseline")
        end

        layout.draw(g2d,
                    (x - text_bounds.x) * position_scale,
                    (y - text_bounds.y) * position_scale)

        loader = Jme::Texture::Plugins::AWTLoader.new
        image = loader.load(buffered_image, false)
        texture = Jme::Texture::Texture2D.new(image)
        texture.magFilter = Jme::Texture::Texture::MagFilter::Bilinear
        # This does mipmapping
        texture.minFilter = Jme::Texture::Texture::MinFilter::Trilinear
        texture.wrap = Jme::Texture::Texture::WrapMode::Clamp
        texture
      end

      def self.create_color(spec)
        JavaAWT::Color.new(spec[0].to_f, spec[1].to_f, spec[2].to_f, spec[3].to_f)
      end
    end
  end
end
