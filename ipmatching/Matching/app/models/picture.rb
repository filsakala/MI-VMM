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

  def match_sqft(other_picture = Picture.second)
    cluster = cluster()
    cluster.recalculate_centroids
    other_cluster = other_picture.cluster
    other_cluster.recalculate_centroids
    a = []
    w = []
    me_scale_sum = cluster.centroids.sum { |c| c[:scale] }
    other_scale_sum = other_cluster.centroids.sum { |c| c[:scale] }
    (cluster.centroids + other_cluster.centroids).each_with_index do |ip, i|
      (cluster.centroids + other_cluster.centroids).each_with_index do |oip, j|
        a[i] ||= []
        a[i][j] = 1 / (1 + Math.sqrt(((ip[:x] - oip[:x]) ** 2)+((ip[:y] - oip[:y]) ** 2)))
      end
    end
    cluster.centroids.each_with_index do |ip, i|
      w[i] = (0.0 + ip[:scale]) / me_scale_sum
    end
    ips_cnt = w.size
    other_cluster.centroids.each_with_index do |oip, j|
      w[ips_cnt + j] = (0.0 - oip[:scale]) / other_scale_sum
    end
    am = Matrix.columns(a)
    wmt = Matrix.column_vector(w)
    wm = wmt.transpose
    # raise "rc: #{am.row_count}, cc: #{am.column_count}, wm rc: #{wm.row_count} cc:  #{wm.column_count}, wmt rc: #{wmt.row_count} cc:  #{wmt.column_count}"
    Math.sqrt((wm * am * wmt)[0, 0].abs) # sometimes - inside ?!?
  end

  # Cluster IPS
  def cluster
    if !@cluster
      @cluster = Cluster.new
      interest_points.each do |ip|
        interest_points.each do |oip|
          if ip != oip &&
            oip.x >= (ip.x - ip.scale) && oip.x <= (ip.x + ip.scale) &&
            oip.y >= (ip.y - ip.scale) && oip.y <= (ip.y + ip.scale) # in_cluster
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
      # interest_points.each do |ip| # Body, ktore netvoria aspon par...
      #   @cluster.add(ip) if !@cluster.cluster_of(ip) # add non-clustered points
      # end
    end
    @cluster
  end

end
