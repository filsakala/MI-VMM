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

  # counted as mean in x and y positions
  def recalculate_centroids
    @centroids = []
    @clusters.each do |cluster|
      result_point = { x: 0, y: 0, scale: 0 }
      cluster.each do |point|
        result_point[:x] += point.x
        result_point[:y] += point.y
        result_point[:scale] += point.scale
      end
      result_point[:x] /= cluster.size
      result_point[:y] /= cluster.size
      result_point[:scale] /= cluster.size
      # result_point[:scale] = cluster.size
      @centroids << result_point
    end
  end
end