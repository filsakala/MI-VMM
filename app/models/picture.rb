require 'matrix'
require 'rmagick'

class Picture < ActiveRecord::Base
  has_attached_file :image # , default_url: "/images/:style/missing.png"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  attr_accessor :cluster
  attr_accessor :m

  has_many :interest_points
  after_save :analyze_ips

  def analyze_ips
    output = `cd #{Rails.root.join("public", "ipfinder", "dist")}; java -jar ./semestralka.jar #{image.path}`
    output.split("\n")[1..-1].each do |ips|
      xy = ips.split(' ')
      interest_points.create(x: xy[0].to_f, y: xy[1].to_f, scale: xy[2].to_f)
    end
  end

  def partial_match_b(my_point, other_points)
    partial_result = []
    semaphore = Mutex.new
    todos = other_points.to_a

    threads = []
    threads << Thread.new do
      my_results = []
      todos[0...(todos.size / 4)].each do |oip|
        my_results << euclidean_distance(my_point, oip)
      end
      partial_result = partial_result + my_results
    end
    threads << Thread.new do
      my_results = []
      todos[(todos.size / 4)...(2 * todos.size / 4)].each do |oip|
        my_results << euclidean_distance(my_point, oip)
      end
      partial_result = partial_result + my_results
    end
    threads << Thread.new do
      my_results = []
      todos[(2 * todos.size / 4)...(3 * todos.size / 4)].each do |oip|
        my_results << euclidean_distance(my_point, oip)
      end
      partial_result = partial_result + my_results
    end
    threads << Thread.new do
      my_results = []
      todos[(3 * todos.size / 4)...todos.size].each do |oip|
        my_results << euclidean_distance(my_point, oip)
      end
      partial_result = partial_result + my_results
    end
    threads.each { |t| t.join }

    partial_result.sort!
    [partial_result[0], partial_result[1]]
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
      if first / second <= threshold || first == 0 # || partial_result.first[1] == 0 # Najde 1 identicky bod
        result[:cnt] += 1
      end
    end
    # result[:perc] = (result[:cnt] + 0.0) / interest_points.count
    # result[:perc] = (result[:cnt] + 0.0) / [interest_points.count, other_picture.interest_points.count].max
    result[:perc] = (2 * result[:cnt] + 0.0) / (interest_points.count + other_picture.interest_points.count) # Number of connected points of both pictures together
    result
  end

  def match_sqft(other_picture = Picture.second, cluster_threshold = 10)
    if self != other_picture
      cluster = cluster(cluster_threshold)
      cluster.recalculate_centroids
      other_cluster = other_picture.cluster(cluster_threshold)
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

  # Picture combination
  def circle(gc, x, y)
    gc.circle x, y, x - 3, y
  end

  def setup_drawers(my_color = '#ff0000', other_color = '#ff0000', match_color = '#000000')
    my_color = '#ff0000' if !my_color
    other_color = '#ff0000' if !other_color
    match_color = '#000000' if !match_color

    mdraw = Magick::Draw.new
    mdraw.fill 'none'
    mdraw.stroke(my_color)
    mdraw.stroke_width(1)

    odraw = Magick::Draw.new
    odraw.fill 'none'
    odraw.stroke(other_color)
    odraw.stroke_width(1)

    rdraw = Magick::Draw.new
    rdraw.fill 'none'
    rdraw.stroke(match_color)
    rdraw.stroke_width(1)
    [mdraw, odraw, rdraw]
  end

  def prepare_picture(image, interest_points, drawer)
    i = Magick::Image.read(image.path).first
    interest_points.each do |ip|
      circle(drawer, ip.x, ip.y)
    end
    drawer.draw i
    i
  end

  def group_images(first, second, mdraw, odraw, rdraw)
    my_img = prepare_picture(first.image, first.interest_points, mdraw)
    other_img = prepare_picture(second.image, second.interest_points, odraw)
    f = Paperclip::Geometry.from_file(first.image)
    s = Paperclip::Geometry.from_file(second.image)
    blank_img = Magick::Image.new(f.width + s.width, [f.height, s.height].max) { self.background_color = "white" }
    blank_img.composite(my_img, 0, 0, Magick::CopyCompositeOp).composite(other_img, f.width, 0, Magick::CopyCompositeOp)
  end

  def create_combining_picture(other, threshold = 0.5, my_color = '#ff0000', other_color = '#ff0000', match_color = '#000000')
    mdraw, odraw, rdraw = setup_drawers(my_color, other_color, match_color)
    result = group_images(self, other, mdraw, odraw, rdraw)
    my_dim = Paperclip::Geometry.from_file(image)

    # Matching
    interest_points.each do |ip|
      partial_result = []
      other.interest_points.each do |oip|
        partial_result << { oip: oip, dist: euclidean_distance(ip, oip) }
      end
      partial_result.sort! { |x, y| x[:dist] <=> y[:dist] }
      first = partial_result[0]
      second = partial_result[1]
      if first[:dist] / second[:dist] <= threshold || first[:dist] == 0 # || partial_result.first[1] == 0 # Najde 1 identicky bod
        # line between ip, first and second
        circle(rdraw, ip.x, ip.y)
        circle(rdraw, my_dim.width + first[:oip].x, first[:oip].y)
        rdraw.line ip.x, ip.y, my_dim.width + first[:oip].x, first[:oip].y
      end
    end
    rdraw.draw result

    result.write(Rails.root.join('app', 'assets', 'images', 'result.jpg'))
    Rails.root.join('app', 'assets', 'images', 'result.jpg')
  end

end
