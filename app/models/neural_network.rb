require 'matrix'
require 'rmagick'

class NeuralNetwork
  attr_accessor :input, :input_matrix, :hidden, :output
  attr_accessor :weights_1, :weights_2, :errors, :hidden_errors, :input_errors
  attr_accessor :weights_1_matrix, :weights_2_matrix
  attr_accessor :rand, :epoch_cnt, :epoch_act
  attr_accessor :learning_rate

  def initialize(image, fname, learning_rate = 5, epoch_cnt = 100)
    @input = []
    image.pixels.each do |pixel|
      @input.push(color_to_i(ChunkyPNG::Color.to_truecolor_bytes(pixel)))
    end
    @rand = Random.new#(1) # Test version = TODO: delete seed!

    @input = scale(@input)
    @input_matrix = Matrix.row_vector(@input)
    init_weights_1
    init_weights_2
    @epoch_cnt = epoch_cnt
    @learning_rate = learning_rate
    @fname = fname
  end

  # Scale input to be in (-10, 10) -- sigmoid activation function for large numbers = 1
  def scale(ary)
    max = color_to_i([255, 255, 255])
    b = ary.map { |i| 0.0 + ((i) * 20 / max) - 10 }
    b
  end

  def unscale(ary)
    max = color_to_i([255, 255, 255])
    b = ary.map do |i|
      val = ((((i)+ 10) / 20) * max)
      val = @rand.rand(20) - 10 if val.nan?
      val.ceil
    end
    b
  end

# Get RGB color, return integer value
def color_to_i(rgb)
  0.0 + (rgb.first * (16 ** 4)) + (rgb.second * (16 ** 2)) + rgb.third
end

# Get integer value, return RGB array color
def i_to_color(number)
  r = []
  num = number.to_i
  while num != 0
    r << num % 16
    num /= 16
  end
  r << 0 while r.size < 6 # Fix array size
  if r.size > 6
    raise "Array size is too large: #{num} -> #{r}, size: #{r.size}"
  end
  [r[5] * 16 + r[4], r[3] * 16 + r[2], r[1] * 16 + r[0]]
rescue TypeError
  puts "Problem with number #{num} -> #{r}: #{$!.message}"
end

# INIT weights
def init_weights_1
  @weights_1 = Array.new(Math.sqrt(@input.size)) { Array.new(@input.size) { @rand.rand } }
  @weights_1_matrix = Matrix.columns(@weights_1)
end

def init_weights_2
  @weights_2 = Array.new(@input.size) { Array.new(Math.sqrt(@input.size)) { @rand.rand } }
  @weights_2_matrix = Matrix.columns(@weights_2)
end

# FORWARD
def create_hidden_layer
  @hidden = (@input_matrix * @weights_1_matrix)
end

def create_output_layer
  @output = (@hidden * @weights_2_matrix).collect { |val| ActivationFunction.sigmoid(val) }
end

def create_output_image(output)
  image = Magick::Image.new(Math.sqrt(@input.size), Math.sqrt(@input.size))
  pixels = []
  (0...Math.sqrt(@input.size)).each do |x|
    (0...Math.sqrt(@input.size)).each do |y|
      pixel = i_to_color(output[0, transform_index(x, y, Math.sqrt(@input.size))])
      rgb = ChunkyPNG::Color.rgb(pixel.first, pixel.second, pixel.third)
      hsla = ChunkyPNG::Color.to_hsl(rgb, true)
      # puts "#{pixel} <-> #{hsla}"
      # sleep(1)
      pixels << Magick::Pixel.from_hsla(hsla.first.abs, (hsla.second * 255).floor, (hsla.third * 255).floor)
    end
  end
  image.store_pixels(0, 0, Math.sqrt(@input.size), Math.sqrt(@input.size), pixels)
  image.write(Rails.root.join('app', 'assets', 'images', "#{@fname}_#{@epoch_act}.png"))
end

# Forward
def forward
  puts "1. Forward - Create hidden layer"
  create_hidden_layer
  @hidden.collect { |val| ActivationFunction.sigmoid(val) }
  puts "2. Forward - Create output layer"
  create_output_layer
  puts "3. Forward - Unscale & Create output image"
  create_output_image(unscale(@output))
  @output = @output.to_a.flatten
end

def get_output_errors
  @errors = []
  @input.each_with_index do |input, index|
    @errors << (0.0 + input - @output[index])
    # puts "#{input} - #{@output[index]} = #{@errors.last}"
    # sleep(2)
  end
end

def get_hidden_errors
  @hidden_errors = (@weights_2_matrix * Matrix.column_vector(@errors))
end

def get_input_errors
  @input_errors = (@weights_1_matrix * @hidden_errors)
end

# 2D to 1D index
def transform_index(x, y, col_size)
  (x * col_size) + y
end

def update_input_weights
  @weights_1.each_with_index do |xval, x|
    xval.each_index do |y|
      # print "#{@weights_1[x][y]} ->" if @epoch_act >= 1
      @weights_1[x][y] += (@learning_rate * @input_errors[x, 0] * ActivationFunction.sigmoid_prime(@hidden[0, x]) * @input[x]) #
      # puts "#{@weights_1[x][y]} = -||- + (#{@learning_rate} * #{@input_errors[x, 0]} * #{ActivationFunction.sigmoid_prime(@hidden[0, x])} * #{@input[x]}), hidden: #{@hidden[0, x]}" if @epoch_act >= 1
      # sleep(2) if @epoch_act >= 1
    end
  end
  @weights_1_matrix = Matrix.columns(@weights_1)
end

def update_hidden_weights
  @weights_2.each_with_index do |xval, x|
    xval.each_index do |y|
      @weights_2[x][y] += (@learning_rate * @errors[x] * ActivationFunction.sigmoid_prime(@output[x]) * @hidden[0, y])
    end
  end
  @weights_2_matrix = Matrix.columns(@weights_2)
end

# Backpropagation of errors
def backward
  puts "1. Backward - Get output errors"
  get_output_errors
  puts "2. Backward - Get hidden errors"
  get_hidden_errors
  puts "3. Backward - Get input errors"
  get_input_errors
  puts "4. Backward - Update input weights"
  update_input_weights
  puts "5. Backward - Update hidden weights"
  update_hidden_weights
end

# Run forward and backward in some number of epochs
def run
  # max_learning_rate = @learning_rate
  # min_learning_rate = 0
  # (1..@epoch_cnt).each do |epoch|
  # @learning_rate += (max_learning_rate - min_learning_rate) / @epoch_cnt
  # @epoch_act = epoch
  puts "Epoch #{@epoch_act}"
  puts "Forward"
  forward
  puts "Backward"
  backward
  # end
  puts "end"
end

end