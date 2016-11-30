class EuclideanDistance < ActiveRecord::Base
  belongs_to :first_point, :class_name => "InterestPoint", :foreign_key => "first_point_id"
  belongs_to :second_point, :class_name => "InterestPoint", :foreign_key => "second_point_id"

  before_save :calculate_distance

  def calculate_distance
    Math.sqrt(((first_point.x - second_point.x) ** 2)+((first_point.y - second_point.y) ** 2))
  end
end
