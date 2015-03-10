require 'pry'
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
  
  def place_line(x0,y0,x1,y1,rune)
    points = get_line(x0,x1,y0,y1)
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



class Floor < Room
end


#f = Floor.new(60,60)
#puts f

def t
  a = Library.new
  puts a
end

t
binding.pry
