module PicturesHelper

  def actual(number)
    if actual_step == number
      "active"
    else
      "disabled"
    end
  end
end
