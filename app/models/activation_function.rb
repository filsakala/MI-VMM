class ActivationFunction

  def self.sigmoid(param)
    1 / (1 + (Math::E ** (-param)))
  end

  def self.sigmoid_ary(param)
    param.collect { |i| 1 / (1 + (Math::E ** - i))}
  end

  # S'(t)=S(t)*(1-S(t))
  def self.sigmoid_prime(param)
    s = sigmoid(param)
    s * (1 - s)
  end
end