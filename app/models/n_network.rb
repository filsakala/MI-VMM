class NNetwork < ActiveRecord::Base
  has_many :pictures

  after_create :run_training

  def run_training
    nn = NNTrainer.new
    ws = nn.run(learning_rate, repeat_cnt)
    update(weights: ws.to_s)
  end
end
