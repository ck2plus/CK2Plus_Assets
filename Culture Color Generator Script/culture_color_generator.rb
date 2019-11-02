#!/usr/bin/env ruby

require 'rmagick'
require 'optparse'

def create_image(colors)
    pixels = colors.map{|h, s, l| Magick::Pixel.from_hsla(h, s, l, 1.0)}
    square_size = 50
    image_size = 50 * (pixels.size + 1)
    image = Magick::Image.new(image_size, image_size) do
      self.background_color = 'white'
    end
    drawer = Magick::Draw.new.tap do |d|
      d.text_align(Magick::CenterAlign)
      d.pointsize(square_size / 4.0)
      d.font_weight(Magick::BoldWeight)
    end

    color_max = ((1 << 16) - 1).to_f
    pixels.each.with_index do |pixel_a, i|
      min_a = square_size * (i + 1)
      max_a = min_a + square_size
      min_a.upto(max_a) do |y|
        0.upto(square_size) do |x|
          image.pixel_color(x, y, pixel_a)
          image.pixel_color(y, x, pixel_a)
        end
      end
      
      pixels.each.with_index do |pixel_b, j|
        min_b = square_size * (j + 1)
        max_b = min_b + square_size
        min_b.upto(max_b).with_index do |offset, k|
          y = min_a + k
          min_b.upto(offset) do |x|
            image.pixel_color(x, y, pixel_a)
          end
          offset.upto(max_b) do |x|
            image.pixel_color(x, y, pixel_b)
          end
        end
      end
      
      rgb = [pixel_a.red, pixel_a.green, pixel_a.blue].map{|c| (c / color_max).round(2).to_s}
      increment = square_size / 3.0
      offset = increment
      rgb.each do |c|
        drawer.text(min_a + square_size / 2.0, min_a + offset, c)
        offset += increment
      end
      drawer.text(min_a + square_size / 2.0, square_size / 2.0, i.to_s)
      drawer.text(square_size / 2.0, min_a + square_size / 2.0, i.to_s)
      puts "#{i}: { #{rgb.join(' ')} }"
    end
    drawer.draw(image)
    
    image
end

def get_colors(min_lightness:, max_lightness:, n_lightness:, n_hue:, saturation:, hue:, hue_variation:, **options)
  max_lightness = max_lightness.clamp(0.0, 1.0)
  min_lightness = min_lightness.clamp(0.0, 1.0)
  lightness_diff = (max_lightness - min_lightness)
  lightness_diff /= (n_lightness - 1).to_f unless n_lightness <= 1
  lightnesses = n_lightness.times.map{|i| min_lightness + lightness_diff * i}

  hue = hue.abs % 360
  hue_variation = hue_variation.abs
  hues = []
  hues += (-(n_hue / 2).floor).upto(-1).map{|i| ((i - 1) * hue_variation + hue) % 360.0}
  hues << hue
  hues += 1.upto((n_hue / 2).floor).map{|i| ((i + 1) * hue_variation + hue) % 360.0}
  
  saturation = saturation.abs.clamp(0.0, 1.0)
  
  hues.product(lightnesses).map{|h, l| [h, saturation * 255, l * 255]}
end

def get_options
  options = {
    n_hue: 1,
    n_lightness: 13,
    saturation: 0.5,
    hue: 0.0,
    hue_variation: 10.0,
    min_lightness: 0.2,
    max_lightness: 0.8,
    filename: 'out.png'
  }
  OptionParser.new do |opts|
    [
      ['hue',             'base hue',                         :to_f],
      ['n_lightness',     'number of lightness levels',       :to_i],
      ['n_hue',           'number of hue levels',             :to_i],
      ['saturation',      'saturation',                       :to_f],
      ['hue_variation',   'variation in hue between levels',  :to_f],
      ['min_lightness',   'minimum lightness',                :to_f],
      ['max_lightness',   'maximum lightness',                :to_f],
      ['filename',        'filename',                         :to_s]
    ].each do |long_name, desc, method|
      opts.on("--#{long_name}=#{long_name.upcase}", desc) do |val|
        options[long_name.to_sym] = val.send(method)
      end
    end
  end.parse!
  options
end

if __FILE__ == $0
  options = get_options
  colors = get_colors(options)
  image = create_image(colors)
  image.write(options[:filename])
end
