class NNTrainer
  attr_accessor :nns

  def initialize
    @nns = []
  end

  # Run all pictures more times
  def run(learning_rate = 1, epoch_cnt = 1, hidden_cnt = 50)
    ary = Picture.all
    pic_cnt = Picture.count
    (1...epoch_cnt).each do
     ary += a
    end
    puts "Creating NNS"
    prev = nil
    nn = nil
    ary.each_with_index do |picture, i|
      nn = NeuralNetwork.new(ChunkyPNG::Image.from_file(picture.image.path(:thumb)), File.basename(picture.image.path(:thumb), ".*"), learning_rate, epoch_cnt, true, hidden_cnt)
      nn.epoch_act = (i + pic_cnt) / pic_cnt
      # Weights are now random initialized, whe should put there our learned weights...
      if prev != nil
        nn.weights_1 = prev.weights_1
        nn.weights_2 = prev.weights_2
        nn.weights_1_matrix = prev.weights_1_matrix
        nn.weights_2_matrix = prev.weights_2_matrix
      end
      nn.run # Forward, backward, updating weights
      prev = nn
    end
    nn.weights_1
  end

  def run_each_separately(learning_rate = 1, epoch_cnt = 10, hidden_cnt = 50)
    Picture.all.each do |picture|
      nn = NeuralNetwork.new(ChunkyPNG::Image.from_file(picture.image.path(:thumb)), File.basename(picture.image.path(:thumb), ".*"), learning_rate, epoch_cnt, true, hidden_cnt)
      @nns << nn
      nn.run
    end
  end

  def run_last(learning_rate = 1, epoch_cnt = 10, hidden_cnt = 50, picture = Picture.last)
    nn = NeuralNetwork.new(ChunkyPNG::Image.from_file(picture.image.path(:thumb)), File.basename(picture.image.path(:thumb), ".*"),  learning_rate, epoch_cnt, true, hidden_cnt)
    @nns << nn
    nn.run
  end

end