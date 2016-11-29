require 'matrix'

class Picture < ActiveRecord::Base
  has_attached_file :image # , default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  attr_accessor :cluster

  has_many :interest_points
  after_save :analyze_ips

  def analyze_ips
    output = `cd #{Rails.root.join("public", "ipfinder", "dist")}; java -jar ./semestralka.jar #{image.path}`
    output.split("\n")[1..-1].each do |ips|
      xy = ips.split(' ')
      interest_points.create(x: xy[0].to_f, y: xy[1].to_f, scale: xy[2].to_f)
    end
  end

  def partial_match(my_point, other_points)
    partial_result = []
    other_points.each do |oip|
      partial_result << euclidean_distance(my_point, oip)
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
    # result[:perc] = (result[:cnt] + 0.0) / [interest_points.count, other_picture.interest_points.count].max
    result[:perc] = (2 * result[:cnt] + 0.0) / (interest_points.count + other_picture.interest_points.count) # Number of connected points of both pictures together
    result
  end

  def match_sqft(other_picture = Picture.second)
    if self != other_picture
      cluster = cluster()
      cluster.recalculate_centroids
      other_cluster = other_picture.cluster
      other_cluster.recalculate_centroids
      a = []
      w = []
      cluster_size = cluster.centroids.sum { |c| c[:size] }
      other_cluster_size = other_cluster.centroids.sum { |c| c[:size] }

      (cluster.centroids + other_cluster.centroids).each_with_index do |ip, i|
        (cluster.centroids + other_cluster.centroids).each_with_index do |oip, j|
          a[i] ||= []
          a[i][j] = 1 / (1 + Math.sqrt(((ip[:point].x - oip[:point].x) ** 2)+((ip[:point].y - oip[:point].y) ** 2)))
        end
      end

      cluster.centroids.each_with_index do |ip, i|
        w[i] = (0.0 + ip[:size]) / cluster_size
      end

      ips_cnt = w.size
      other_cluster.centroids.each_with_index do |oip, j|
        w[ips_cnt + j] = (0.0 - oip[:size]) / other_cluster_size
      end

      am = Matrix.columns(a)
      wmt = Matrix.column_vector(w)
      wm = wmt.transpose
      # raise "rc: #{am.row_count}, cc: #{am.column_count}, wm rc: #{wm.row_count} cc:  #{wm.column_count}, wmt rc: #{wmt.row_count} cc:  #{wmt.column_count}"
      return Math.sqrt((wm * am * wmt)[0, 0].abs) # sometimes negative (-) inside ?!?
    else
      return 1
    end
  end

  def euclidean_distance(a, b)
    Math.sqrt(((a.x - b.x) ** 2)+((a.y - b.y) ** 2))
  end

  def cluster(threshold = 10)
    if !@cluster
      @cluster = Cluster.new
      interest_points.each do |ip|
        interest_points.each do |oip|
          if ip != oip && euclidean_distance(ip, oip) < threshold
            cip = @cluster.cluster_of(ip)
            coip = @cluster.cluster_of(oip)
            if cip && coip # join clusters
              @cluster.join_clusters(cip, coip)
            elsif cip
              @cluster.add(oip, cip)
            elsif coip
              @cluster.add(ip, coip)
            else
              @cluster.add(oip, @cluster.add(ip)) # add oip where you added ip before
            end
          end
        end
      end
    end
    @cluster
  end

end
