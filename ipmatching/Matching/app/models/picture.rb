class Picture < ActiveRecord::Base
  has_attached_file :image # , default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  has_many :interest_points
  after_save :analyze_ips

  def analyze_ips
    output = `cd ~/Dokumenty/mi-vmm/MI-VMM/ipfinder/dist; java -jar ./semestralka.jar #{image.path}`
    output.split("\n")[1..-1].each do |ips|
      xy = ips.split(' ')
      interest_points.create(x: xy[0].to_f, y: xy[1].to_f)
    end
  end

  def match(other_picture = Picture.second, prah = 0.5)
    result = { cnt: 0, perc: 0.0 }
    interest_points.each do |ip|
      partial_result = {}
      other_picture.interest_points.each do |oip|
        partial_result[oip] = Math.sqrt(((ip.x - oip.x) * (ip.x - oip.x))+((ip.y - oip.y) * (ip.y - oip.y)))
      end
      sorted = partial_result.sort_by { |k, v| v }
      if sorted.first[1] / sorted.second[1] >= prah || sorted.first[1] == 0 # Najde 1 identicky bod
        result[:cnt] += 1
      end
    end
    # result[:perc] = (result[:cnt] + 0.0) / interest_points.count
    if interest_points.count >= other_picture.interest_points.count
      result[:perc] = (result[:cnt] + 0.0) / interest_points.count
    else
      result[:perc] = (result[:cnt] + 0.0) / other_picture.interest_points.count
    end
    result
  end
end
