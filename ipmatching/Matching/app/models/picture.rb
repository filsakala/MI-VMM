class Picture < ActiveRecord::Base
  has_attached_file :image # , default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  has_many :interest_points
  after_save :analyze_ips

  def analyze_ips
    output = `cd #{Rails.root.join("public", "ipfinder", "dist")}; java -jar ./semestralka.jar #{image.path}`
    raise "#{output}"
    output.split("\n")[1..-1].each do |ips|
      xy = ips.split(' ')
      interest_points.create(x: xy[0].to_f, y: xy[1].to_f)
    end
  end

  def partial_match(my_point, other_points)
    partial_result = []
    other_points.each do |oip|
      partial_result << Math.sqrt(((my_point.x - oip.x) * (my_point.x - oip.x))+((my_point.y - oip.y) * (my_point.y - oip.y)))
    end
    partial_result.sort!
    [partial_result[0], partial_result[1]]
  end

  def match(other_picture = Picture.second, threshold = 0.5)
    result = { cnt: 0, perc: 0.0 }
    interest_points.each do |ip|
      first, second = partial_match(ip, other_picture.interest_points)
      if first / second <= threshold # || partial_result.first[1] == 0 # Najde 1 identicky bod
        result[:cnt] += 1
      end
    end
    # result[:perc] = (result[:cnt] + 0.0) / interest_points.count
    result[:perc] = (result[:cnt] + 0.0) / [interest_points.count, other_picture.interest_points.count].max
    result
  end
end
