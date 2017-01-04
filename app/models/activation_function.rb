class ActivationFunction

  def self.sigmoid(param)
    1 / (1 + (Math::E ** (-param)))
  end

  # S'(t) = S(t) * (1-S(t))
  def self.sigmoid_prime(param)
    s = sigmoid(param)
    s * (1 - s)
  end
end