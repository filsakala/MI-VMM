module ApplicationHelper

  def actual_step
    if action_name == 'new'
      return 1
    elsif action_name == 'second'
      return 2
    else
      return 3
    end
  end
end
