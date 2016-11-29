class Cluster
  attr_accessor :clusters
  attr_accessor :centroids

  def initialize
    @clusters = []
    @centroids = []
  end

  def cluster_of(obj)
    @clusters.each_with_index do |c, index|
      return index if c.include?(obj)
    end
    return nil
  end

  def add(obj, index = nil)
    if index
      @clusters[index] << obj
      return index
    else
      @clusters << [obj] if !cluster_of(obj)
      return @clusters.length - 1
    end
  end

  def join_clusters(first, second)
    if first != second
      @clusters[first] = @clusters[first] + @clusters[second]
      @clusters.delete_at(second)
    end
    first
  end

  def count
    @clusters.size
  end

  def euclidean_distance(a, b)
    Math.sqrt(((a.x - b.x) ** 2)+((a.y - b.y) ** 2))
  end

  def recalculate_centroids
    @centroids = []
    @clusters.each do |cluster|
      euclidean_distances = {}
      cluster.each do |p|
        euclidean_distances[p] ||= 0.0
        cluster.each do |op|
          euclidean_distances[p] += euclidean_distance(p, op)
        end
      end
      @centroids << { point: euclidean_distances.sort_by { |k, v| v }[0][0], size: cluster.size }
    end
  end
end
