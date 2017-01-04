class NNTrainer
  attr_accessor :nns

  def initialize
    @nns = []
  end

  def run(learning_rate = 1, repeat_cnt)
    a = Picture.all
    ary = Picture.all
    pic_cnt = Picture.count
    (1...repeat_cnt).each do
     ary += a
    end
    puts "Creating NNS"
    prev = nil
    nn = nil
    ary.each_with_index do |picture, i|
      nn = NeuralNetwork.new(ChunkyPNG::Image.from_file(picture.image.path(:thumb)), File.basename(picture.image.path(:thumb), ".*"), learning_rate, 1)
      nn.epoch_act = (i + pic_cnt) / pic_cnt
      if prev != nil
        nn.weights_1 = prev.weights_1
        nn.weights_2 = prev.weights_2
        nn.weights_1_matrix = prev.weights_1_matrix
        nn.weights_2_matrix = prev.weights_2_matrix
      end
      nn.run
      prev = nn
    end
    nn.weights_1
  end

  def run_each(learning_rate = 1, epoch_cnt = 10)
    Picture.all.each do |picture|
      nn = NeuralNetwork.new(ChunkyPNG::Image.from_file(picture.image.path(:thumb)), File.basename(picture.image.path(:thumb), ".*"), learning_rate, epoch_cnt)
      @nns << nn
      nn.run
    end
  end

  def first
    @nns.first
  end

  def run_last
    nn = NeuralNetwork.new(ChunkyPNG::Image.from_file(Picture.last.image.path(:thumb)), File.basename(Picture.last.image.path(:thumb), ".*"), 10, 10)
    @nns << nn
    nn.run
  end

  # TEST
  # Get RGB color, return integer value
  # def color_to_i(rgb)
  #   0.0 + (rgb.first * (16 ** 4)) + (rgb.second * (16 ** 2)) + rgb.third
  # end

  # Get integer value, return RGB array color
  # def i_to_color(number)
  #   r = []
  #   num = number.to_i
  #   while num != 0
  #     r << num % 16
  #     num /= 16
  #   end
  #   r << 0 while r.size < 6 # Fix array size
  #   if r.size > 6
  #     raise "Array size is too large: #{num} -> #{r}, size: #{r.size}"
  #   end
  #   [r[5] * 16 + r[4], r[3] * 16 + r[2], r[1] * 16 + r[0]]
  # rescue TypeError
  #   puts "Problem with number #{num} -> #{r}: #{$!.message}"
  # end

  # 2D to 1D index
  # def transform_index(x, y, col_size)
  #   (x * col_size) + y
  # end

  # def chunky_png_test
  #   @input = []
  #   ChunkyPNG::Image.from_file(Picture.first.image.path(:thumb)).pixels.each do |pixel|
  #     @input.push(color_to_i(ChunkyPNG::Color.to_truecolor_bytes(pixel)))
  #   end
  #   image = Magick::Image.new(Math.sqrt(@input.size), Math.sqrt(@input.size))
  #   pixels = []
  #   (0...Math.sqrt(@input.size)).each do |x|
  #     (0...Math.sqrt(@input.size)).each do |y|
  #       pixel = i_to_color(@input[transform_index(x, y, Math.sqrt(@input.size))])
  #       rgb = ChunkyPNG::Color.rgb(pixel.first, pixel.second, pixel.third)
  #       hsla = ChunkyPNG::Color.to_hsl(rgb, true)
  #       # puts "#{pixel} <-> #{hsla}"
  #       # sleep(1)
  #       pixels << Magick::Pixel.from_hsla(hsla.first.abs, (hsla.second * 255).floor, (hsla.third * 255).floor)
  #     end
  #   end
  #   image.store_pixels(0, 0, Math.sqrt(@input.size), Math.sqrt(@input.size), pixels)
  #   image.write(Rails.root.join('app', 'assets', 'images', "chunky_png_test.png"))
  # end

end