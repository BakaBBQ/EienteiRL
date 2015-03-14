
class Arena
  attr_reader :left, :right, :top, :bottom
  def initialize
    @arena = Hash.new {|h,k| h[k]=Hash.new('#')}
    @left = @right = @top = @bottom = 0
  end
  
  def [](x,y)
    @arena[y][x]
  end

  def []=(x,y,v)
    # I originally worked out the width and height at the end by scanning the map.
    # I was also using a single map, rather than the 'map in a map' now used. I
    # found that dungeon creation  was slow, but almost all of it was the final
    # rendering stage, so switched over to the current approach.
    @arena[y][x]=v
    @left = [@left, x].min
    @right = [@right, x].max
    @top = [@top, y].min
    @bottom = [@bottom, y].max
  end
  
  def width
    @arena[0].size
  end
  
  def height
    @arena.size
  end
  

  def to_s
    to_array.collect {|row| row.join}.join("\n")
  end

  def to_array
    (top-1..bottom+1).collect do |y|
      (left-1..right+1).collect do |x|
        self[x,y]
      end
    end
  end
end