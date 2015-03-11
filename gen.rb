require 'pry'
require 'theseus'
#Bresenham's line algorithm
#http://www.roguebasin.com/index.php?title=Bresenham%27s_Line_Algorithm

TABLE = 'Ξ'
LIGHT = 'ϔ'
def get_line(x0,x1,y0,y1)
  points = []
  steep = ((y1-y0).abs) > ((x1-x0).abs)
  if steep
    x0,y0 = y0,x0
    x1,y1 = y1,x1
  end
  if x0 > x1
    x0,x1 = x1,x0
    y0,y1 = y1,y0
  end
  deltax = x1-x0
  deltay = (y1-y0).abs
  error = (deltax / 2).to_i
  y = y0
  ystep = nil
  if y0 < y1
    ystep = 1
  else
    ystep = -1
  end
  for x in x0..x1
    if steep
      points << {:x => y, :y => x}
    else
      points << {:x => x, :y => y}
    end
    error -= deltay
    if error < 0
      y += ystep
      error += deltax
    end
  end
  return points
end




class Room
  def initialize(w,h)
    @tiles = Array.new(w){Array.new(h){"X"}}
    gen
    rand_orient
  end
  
  def place(x,y,rune)
    @tiles[x][y] = rune
  end
  
  def place_line(x0,y0,x1,y1,rune,thickness=1)
    points = get_line(x0,x1,y0,y1)
    
    thickness.times do |t|
      y_offset = thickness / 2 + t
      points += get_line(x0,x1,y0 + y_offset,y1 + y_offset)
    end
    
    
    points.each do |p|
      place(p[:x],p[:y],rune)
    end
  end
  
  def fill_rect(x0,y0,x1,y1,rune)
    (x0..x1).to_a.each do |a|
      (y0..y1).to_a.each do |b|
        place(a,b,rune)
      end
    end
  end
  
  def rand_fill_rect(x0,y0,x1,y1,runes)
    (x0..x1).to_a.each do |a|
      (y0..y1).to_a.each do |b|
        place(a,b,runes.sample)
      end
    end
  end
  
  
  def fill_all(rune)
    fill_rect(0,0,width-1,height-1,rune)
  end
  
  
  def width
    @tiles.length
  end
  
  def height
    @tiles[0].length
  end
  
  def gen
  end
  
  def to_s
    lines = []
    height.times do |h|
      cline = ""
      width.times do |w|
        cline+=@tiles[w][h]
      end
      lines << cline
    end
    return lines.join("\n")
  end
  
  def rand_orient
    case rand(4)
    when 0
    when 1
      @tiles = @tiles.reverse
    when 2
      @tiles = @tiles.transpose
    when 3
      @tiles = @tiles.transpose.reverse
    end
  end
  
end

class Arena < Room
  def initialize
    super(20,20)
  end
  
  def gen
    fill_rect(0,0,width-1,height-1,"#")
    fill_rect(1,1,width-2,height-2,".")
  end
end

class Dorm < Room
  class DormRoom < Room
    def initialize
      super(rand(7..10),rand(6..7))
    end
    
    def gen
      fill_rect(0,0,width-1,height-1,"#")
      fill_rect(1,1,width-2,height-2,".")
      fill_rect(1,1,width-rand(3..4),rand(1..2),TABLE)
      place(width-2-rand(1),height-rand(2)-2,LIGHT)
    end
  end
  
  def initialize
    super(70,20)
  end
  
  def gen
    fill_rect(0,0,width-1,height-1,"#")
    fill_rect(1,1,width-20,height-10,".")
  end
end

class Library < Room
  def initialize
    super(rand(30..50),rand(30..50))
  end
  
  def gen
    fill_rect(0,0,width-1,height-1,"#")
    fill_rect(1,1,width-18-rand(4),height-8-rand(4),".")
    
    rand(2..12).times do
       gen_study(rand(3..(width-25)), rand(3..(height-15)))
    end
    
    
    alcove_x = width-18-4 + 4 + rand(3)
    alcove_y = height-8-rand(4)
    fill_rect(width-18-4,4 + rand(2), alcove_x, alcove_y, ".")
    fill_rect(alcove_x-1,alcove_y - 15 - rand(9), alcove_x + rand(1), alcove_y - 4 + rand(9),TABLE)
  end
  
  def gen_study(x,y)
    place(x,y,TABLE)
    [
      [0,1],
      [0,-1],
      [1,0],
      [-1,0]
    ].each do |c|
      place(c[0] + x, c[1] + y, 'ñ') if rand > 0.2
    end
    
  end
end


class CorridorFloor < Room
  def initialize
    super(120,80)
    
    
    @startx = rand(width)
    @starty = rand(height)
    
    #@nodes = []
    #nodes_construction
    #@nodes.sort!
    #p @nodes
    
    @nodes.each_with_index do |n,i|
      if @nodes[i+1]
        place_line(n[0],n[1],@nodes[i+1][0],@nodes[i+1][1],".",10)
      end
    end
    
    fill_rect(@startx - 5,@starty - 5, @startx+5, @starty+5,".")
    place(@startx,@starty,">")
  end
  
  def nodes_construction
    @nodes << [@startx,@starty,0]
    construct_single_node(@startx,@starty,:horz,0)
  end
  
  def construct_single_node(x,y,dir,depth)
    a = (dir == :horz ? x : (x - 50 + rand(100)))
    b = (dir == :vert ? y : (y - 50 + rand(100)))
    @nodes.push [a,b,depth]
    #p [x,y,a,b]
   # p [a,b]
    
    next_direction = (dir == :horz ? :vert : :horz)
    if @nodes.length <= 15
      construct_single_node(x,y,next_direction,depth+1)
    end
  end
  
  def gen
    fill_rect(0,0,width-1,height-1,"#")
  end
end


class FunFloor < Room
  attr_accessor :exit
  attr_accessor :start
  
  attr_reader :nodes
  def initialize
    super(90,90)
    
    
    se = some_entrance_and_exit
    #p [*se[0]]
    maze = Theseus::OrthogonalMaze.new(width:20, height:20,entrance: [*se[0]],exit: [*se[1]])
    maze.generate!
    solver = maze.new_solver(type: :astar)
    while solver.step do
      
    end
    solution = solver.solution
    
    @nodes = []
    solution.each do |s|
      @nodes << [s[0] * 3 + 10, s[1] * 3 + 10]
    end
    
    @nodes.each_with_index do |n,i|
      if @nodes[i+1]
        fill_rect(n[0]-3,n[1]-3,@nodes[i+1][0]+3,@nodes[i+1][1]+3,".")
      end
    end
    s = @nodes.first
    sx = s[0]
    sy = s[1]
    
    f = @nodes.last
    fx = f[0]
    fy = f[1]
    
    place(sx,sy,">")
    place(fx,fy,"<")
    
    self.exit = f
    self.start = s
  end
  
  def some_entrance_and_exit
    pos = [:ul, :ur, :ll, :lr].sample
    point = {
      :ul => [0,0],
      :ur => [19,0],
      :ll => [0,19],
      :lr => [19,19]
    }
    opp_point = {
      :ul => :lr,
      :ur => :ll,
      :ll => :ur,
      :lr => :ul
    }
    opp_pos = point[opp_point[pos]]
    current_pos = point[pos]
    return [current_pos, opp_pos]
  end
  
  def gen
    fill_rect(0,0,width-1,height-1,"#")
  end
end

#f = Floor.new(60,60)
#puts f

def t
  a = FunFloor.new
  puts a
end
t

#binding.pry
