#!/usr/bin/env ruby

require 'rmagick'
require 'optparse'
require 'tinct'

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

def get_colors(target_color:, lightness_levels:, lightness_variance:, hue_levels:, hue_variance:, **options)
  target_color = Tinct.from_s(target_color)
  saturation = target_color.saturation
  hue = target_color.hue * 350
  lightness = target_color.lightness

  min_lightness = lightness_levels <= 1 ? lightness : (lightness - (lightness_variance * ((lightness_levels - 1) / 2.0).ceil)).clamp(0.0, 1.0)
  min_hue = hue_levels <= 1 ? hue : (hue - (hue_variance * ((hue_levels - 1) / 2.0).ceil)) % 360
  
  lightnesses = lightness_levels.times.map{|i| (min_lightness + lightness_variance * i).clamp(0.0, 1.0)}
  hues = hue_levels.times.map{|i| (min_hue + hue_variance * i) % 360 }
  saturation = saturation.abs.clamp(0.0, 1.0)
  
  hues.product(lightnesses).map{|h, l| [h, saturation * 255, l * 255]}
end

def get_options
  options = {
    hue_levels: 1,
    lightness_levels: 10,
    saturation: 0.5,
    hue: 0.0,
    hue_variance: 5.0,
    lightness: 0.5,
    lightness_variance: 0.1,
    filename: 'out'
  }
  OptionParser.new do |opts|
    [
      ['target_color',        'color to base the output around',        :to_s],
      ['hue_levels',          'number of hue levels',                   :to_i],
      ['hue_variance',        'variation in hue between levels',        :to_f],
      ['lightness_levels',    'number of lightness levels',             :to_i],
      ['lightness_variance',  'variation in lightness between levels',  :to_f],
      ['filename',            'filename',                               :to_s]
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
  image.write(options[:filename] + '.png')
end
