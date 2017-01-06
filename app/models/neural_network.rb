require 'matrix'
require 'rmagick'

class NeuralNetwork
  attr_accessor :input, :input_matrix, :hidden, :hidden_without_sigmoid, :output # layers
  attr_accessor :weights_1, :weights_2, :weights_1_matrix, :weights_2_matrix # weights
  attr_accessor :output_errors, :hidden_errors # errors
  attr_accessor :rand, :epoch_cnt, :epoch_act, :learning_rate, :hidden_size # params

  # Params: learning_rate (float), epoch_cnt (int), init_weights (boolean), hidden_size
  def initialize(image, fname, *params)
    if params.size != 4
      puts "Wrong params count #{params.size}, should be: [learning_rate, epoch_cnt, init_input?]. Setting default values..."
      params = [5, 100, true, 50]
    end
    @fname = fname
    @learning_rate = params[0]
    @epoch_cnt = params[1]
    @rand = Random.new # Random seed
    @hidden_size = params[3]

    # Init input pixel array
    @input = []
    image.grayscale! # Convert to grayscale
    image.pixels.each do |pixel|
      @input.push(ChunkyPNG::Color.r(pixel)) # RGB are the same
    end

    init_input
    init_weights_1 if params[2] == true
    init_weights_2 if params[2] == true
  end

  def init_input
    @input.map! { |i| ((i + 0.0) / 255) }
    @input_matrix = Matrix.row_vector(@input)
  end

  def output_to_pixels
    b = @output.map { |i| (i * 255).round }
    b
  end

  # INIT weights
  def init_weights_1
    @weights_1 = Array.new(@hidden_size) { Array.new(@input.size) { @rand.rand } }
    @weights_1_matrix = Matrix.columns(@weights_1)
  end

  def init_weights_2
    @weights_2 = Array.new(@input.size) { Array.new(@hidden_size) { @rand.rand } }
    @weights_2_matrix = Matrix.columns(@weights_2)
  end

  # FORWARD
  def create_hidden_layer
    @hidden = (@input_matrix * @weights_1_matrix)
  end

  def create_output_layer
    @output = (@hidden * @weights_2_matrix)
  end

  def create_output_image(output)
    image = Magick::Image.new(Math.sqrt(@input.size), Math.sqrt(@input.size))
    pixels = []
    (0...@input.size).each do |i|
      rgb = ChunkyPNG::Color.rgb(output[i], output[i], output[i]) # RGB pixel
      hsla = ChunkyPNG::Color.to_hsl(rgb) # HSLA pixel
      pixels << Magick::Pixel.from_hsla(hsla.first.abs, (hsla.second * 255).floor, (hsla.third * 255).floor)
    end
    image.store_pixels(0, 0, Math.sqrt(@input.size), Math.sqrt(@input.size), pixels)
    image.write(Rails.root.join('app', 'assets', 'images', "#{@fname}_#{@epoch_act}.png"))
  end

  # FORWARD
  def forward
    # puts "1. Forward - Create hidden layer"
    create_hidden_layer
    @hidden_without_sigmoid = @hidden
    @hidden = @hidden.collect { |val| ActivationFunction.sigmoid(val) }
    # puts "2. Forward - Create output layer"
    create_output_layer
    # puts "3. Forward - Repair output pixels & Create output image"
    @output = @output.to_a.flatten
    @output = @output.map { |val| ((val * 1.0) / 255) }
    create_output_image(output_to_pixels)
  end

  def get_output_errors
    @output_errors = []
    @input.each_with_index do |input, index|
      @output_errors << (input - @output[index])
    end
  end

  def get_hidden_errors
    @hidden_errors = (@weights_2_matrix * Matrix.column_vector(@output_errors))
  end

  def update_input_weights
    @weights_1.each_with_index do |xval, x|
      xval.each_index do |y|
        # print "#{@weights_1[x][y]} ->" if @epoch_act >= 2
        @weights_1[x][y] += (@learning_rate * @hidden_errors[x, 0] * ActivationFunction.sigmoid_prime(@hidden_without_sigmoid[0, x]) * @input[y]) #
        # puts "#{@weights_1[x][y]} = -||- + (#{@learning_rate} * #{@hidden_errors[x, 0]} * #{ActivationFunction.sigmoid_prime(@hidden_without_sigmoid[0, x])} * #{@input[y]}), hidden: #{@hidden_without_sigmoid[0, x]}" if @epoch_act >= 2
        # sleep(1) if @epoch_act >= 2
      end
    end
    @weights_1_matrix = Matrix.columns(@weights_1)
  end

  def update_hidden_weights
    @weights_2.each_with_index do |xval, x|
      xval.each_index do |y|
        @weights_2[x][y] += (@learning_rate * @output_errors[x] * @hidden[0, y])
      end
    end
    @weights_2_matrix = Matrix.columns(@weights_2)
  end

  # Backpropagation of errors
  def backward
    # puts "1. Backward - Get output errors"
    get_output_errors
    # puts "2. Backward - Get hidden errors"
    get_hidden_errors
    # puts "3. Backward - Update input weights"
    update_input_weights
    # puts "4. Backward - Update hidden weights"
    update_hidden_weights
  end

  # Run forward and backward in some number of epochs
  def run
    (1..@epoch_cnt).each do |epoch|
      @epoch_act = epoch
      #puts "Epoch #{@epoch_act}"
      # puts "Forward"
      forward
      # puts "Backward"
      backward
    end
    # Get network final error
    puts "#{(@output_errors.map { |v| v.abs }.sum / @output_errors.size) * 100}"
    (@output_errors.map { |v| v.abs }.sum / @output_errors.size) * 100
  end

end