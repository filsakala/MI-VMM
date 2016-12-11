require 'matrix'

class NeuralNetwork
  attr_accessor :input, :hidden, :output
  attr_accessor :weights_1, :weights_2, :error

  def initialize(image)
    @input = []
    image.each_pixel do |pixel, c, r|
      @input.push(color_to_i(pixel.red, pixel.green, pixel.blue))
    end
  end

  def color_to_i(r, g, b)
    0.0 + r * (256 ** 4) + g * (256 ** 2) + b
  end

  def i_to_color(number)
    r = []
    num = number
    while num != 0
      r << num % 256
      num /= 256
    end
    while r.size < 6
      r << 0
    end
    r.reverse!
    if r.size > 6
      raise "Array size is too large: #{number} -> #{r}, size: #{r.size}"
    elsif r.size == 0
      raise "Array size is too small: #{number} -> #{r}, size: #{r.size}"
    end
    [r[0] * 256 + r[1], r[2] * 256 + r[3], r[4] * 256 + r[5]]
  rescue TypeError
    puts "Problem with number #{number} -> #{r}: #{$!.message}"
  end

  # Forward Propagation
  def forward
    rand = Random.new(1)
    @weights_1 = []
    (0...Math.sqrt(@input.size)).each do |x|
      @weights_1[x] ||= []
      @input.each_index do |y|
        @weights_1[x][y] = rand.rand # init_value
      end
    end
    input_matrix = Matrix.row_vector(@input)
    w1_matrix = Matrix.columns(@weights_1)
    # raise "I r:#{input_matrix.row_count} c:#{input_matrix.column_count}, W: r:#{w1_matrix.row_count} c:#{w1_matrix.column_count}"
    @hidden = (input_matrix * w1_matrix).collect { |val| val / @input.size } # use also activation function
    # raise "H r:#{@hidden.row_count} c:#{@hidden.column_count}"

    @weights_2 = []
    @input.each_index do |x|
      @weights_2[x] ||= []
      (0...Math.sqrt(@input.size)).each do |y|
        @weights_2[x][y] = rand.rand # init_value
      end
    end
    w2_matrix = Matrix.columns(@weights_2)

    @output = (@hidden * w2_matrix).transpose.collect { |val| (val / @input.size).to_i }.to_a.flatten
    e = []
    @input.each_with_index do |input, index|
      e << 0.0 + (input - @output[index]).abs / [input, @output[index]].max
    end
    e = e.reduce(:+) / e.size.to_f
  end
end