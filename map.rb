require_relative 'helper'

#the following module comes from
# http://www.roguebasin.com/index.php?title=Ruby_shadowcasting_implementation
module ShadowcastingFieldOfView
    # Multipliers for transforming coordinates into other octants
    @@mult = [
                [1,  0,  0, -1, -1,  0,  0,  1],
                [0,  1, -1,  0,  0, -1,  1,  0],
                [0,  1,  1,  0,  0, -1, -1,  0],
                [1,  0,  0,  1, -1,  0,  0, -1],
             ]

    # Determines which co-ordinates on a 2D grid are visible
    # from a particular co-ordinate.
    # start_x, start_y: center of view
    # radius: how far field of view extends
    def do_fov(start_x, start_y, radius)
        light start_x, start_y
        8.times do |oct|
            cast_light start_x, start_y, 1, 1.0, 0.0, radius,
                @@mult[0][oct],@@mult[1][oct],
                @@mult[2][oct], @@mult[3][oct], 0
        end
    end

    private
    # Recursive light-casting function
    def cast_light(cx, cy, row, light_start, light_end, radius, xx, xy, yx, yy, id)
        return if light_start < light_end
        radius_sq = radius * radius
        (row..radius).each do |j| # .. is inclusive
            dx, dy = -j - 1, -j
            blocked = false
            while dx <= 0
                dx += 1
                # Translate the dx, dy co-ordinates into map co-ordinates
                mx, my = cx + dx * xx + dy * xy, cy + dx * yx + dy * yy
                # l_slope and r_slope store the slopes of the left and right
                # extremities of the square we're considering:
                l_slope, r_slope = (dx-0.5)/(dy+0.5), (dx+0.5)/(dy-0.5)
                if light_start < r_slope
                    next
                elsif light_end > l_slope
                    break
                else
                    # Our light beam is touching this square; light it
                    light(mx, my) if (dx*dx + dy*dy) < radius_sq
                    if blocked
                        # We've scanning a row of blocked squares
                        if blocked?(mx, my)
                            new_start = r_slope
                            next
                        else
                            blocked = false
                            light_start = new_start
                        end
                    else
                        if blocked?(mx, my) and j < radius
                            # This is a blocking square, start a child scan
                            blocked = true
                            cast_light(cx, cy, j+1, light_start, l_slope,
                                radius, xx, xy, yx, yy, id+1)
                            new_start = r_slope
                        end
                    end
                end
            end # while dx <= 0
            break if blocked
        end # (row..radius+1).each
    end
end

module PermissiveFieldOfView
    # Determines which co-ordinates on a 2D grid are visible
    # from a particular co-ordinate.
    # start_x, start_y: center of view
    # radius: how far field of view extends
    def do_fov(start_x, start_y, radius)
        @start_x, @start_y = start_x, start_y
        @radius_sq = radius * radius
        
        # We always see the center
        light @start_x, @start_y
        
        # Restrict scan dimensions to map borders and within the radius
        min_extent_x = [@start_x, radius].min
        max_extent_x = [self.width - @start_x - 1, radius].min
        min_extent_y = [@start_y, radius].min
        max_extent_y = [self.height - @start_y - 1, radius].min
        
        # Check quadrants: NE, SE, SW, NW
        check_quadrant  1,  1, max_extent_x, max_extent_y
        check_quadrant  1, -1, max_extent_x, min_extent_y
        check_quadrant -1, -1, min_extent_x, min_extent_y
        check_quadrant -1,  1, min_extent_x, max_extent_y
    end
    
    private
    # Represents a line (duh)
    class Line < Struct.new(:xi, :yi, :xf, :yf)
        # Macros to make slope comparisons clearer
        {:below => '>', :below_or_collinear => '>=', :above => '<',
            :above_or_collinear => '<=', :collinear => '=='}.each do |name, fn|
            eval "def #{name.to_s}?(x, y) relative_slope(x, y) #{fn} 0 end"
        end
        
        def dx; xf - xi end
        def dy; yf - yi end
    
        def line_collinear?(line)
            collinear?(line.xi, line.yi) and collinear?(line.xf, line.yf)
        end
        
        def relative_slope(x, y)
            (dy * (xf - x)) - (dx * (yf - y))
        end
    end
    
    class ViewBump < Struct.new(:x, :y, :parent)
        def deep_copy
            ViewBump.new(x, y, parent.nil? ? nil : parent.deep_copy)
        end
    end
    
    class View < Struct.new(:shallow_line, :steep_line)
        attr_accessor :shallow_bump, :steep_bump
        def deep_copy
            copy = View.new(shallow_line.dup, steep_line.dup)
            copy.shallow_bump = shallow_bump.nil? ? nil : shallow_bump.deep_copy
            copy.steep_bump   = steep_bump.nil? ? nil : steep_bump.deep_copy
            return copy
        end
    end
    
    # Check a quadrant of the FOV field for visible tiles
    def check_quadrant(dx, dy, extent_x, extent_y)
        active_views = []
        shallow_line = Line.new(0, 1, extent_x, 0)
        steep_line = Line.new(1, 0, 0, extent_y)
        
        active_views << View.new(shallow_line, steep_line)
        view_index = 0
        
        # Visit the tiles diagonally and going outwards
        i, max_i = 1, extent_x + extent_y
        while i != max_i + 1 and active_views.size > 0
            start_j = [0, i - extent_x].max
            max_j = [i, extent_y].min
            j = start_j
            while j != max_j + 1 and view_index < active_views.size
                x, y = i - j, j
                visit_coord x, y, dx, dy, view_index, active_views
                j += 1
            end
            i += 1
        end
    end
    
    def visit_coord(x, y, dx, dy, view_index, active_views)
        # The top left and bottom right corners of the current coordinate
        top_left, bottom_right = [x, y + 1], [x + 1, y]
        
        while view_index < active_views.size and
            active_views[view_index].steep_line.below_or_collinear?(*bottom_right)
            # Co-ord is above the current view and can be ignored (steeper fields may need it though)
            view_index += 1
        end
        
        if view_index == active_views.size or
            active_views[view_index].shallow_line.above_or_collinear?(*top_left)
            # Either current co-ord is above all the fields, or it is below all the fields
            return
        end
        
        # Current co-ord must be between the steep and shallow lines of the current view
        # The real quadrant co-ordinates:
        real_x, real_y = x * dx, y * dy
        coord = [@start_x + real_x, @start_y + real_y]
        light *coord
        
        # Don't go beyond circular radius specified
        #if (real_x * real_x + real_y * real_y) > @radius_sq
        #    active_views.delete_at(view_index)
        #    return
        #end
        
        # If this co-ord does not block sight, it has no effect on the view
        return unless blocked?(*coord)
        
        view = active_views[view_index]
        if view.shallow_line.above?(*bottom_right) and view.steep_line.below?(*top_left)
            # Co-ord is intersected by both lines in current view, and is completely blocked
            active_views.delete(view)
        elsif view.shallow_line.above?(*bottom_right)
            # Co-ord is intersected by shallow line; raise the line
            add_shallow_bump top_left[0], top_left[1], view
            check_view active_views, view_index
        elsif view.steep_line.below?(*top_left)
            # Co-ord is intersected by steep line; lower the line
            add_steep_bump bottom_right[0], bottom_right[1], view
            check_view active_views, view_index
        else
            # Co-ord is completely between the two lines of the current view. Split the
            # current view into two views above and below the current co-ord.
            shallow_view_index, steep_view_index = view_index, view_index += 1
            active_views.insert(shallow_view_index, active_views[shallow_view_index].deep_copy)
            add_steep_bump bottom_right[0], bottom_right[1], active_views[shallow_view_index]
            
            unless check_view(active_views, shallow_view_index)
                view_index -= 1
                steep_view_index -= 1
            end
            
            add_shallow_bump top_left[0], top_left[1], active_views[steep_view_index]
            check_view active_views, steep_view_index
       end
    end
    
    def add_shallow_bump(x, y, view)
        view.shallow_line.xf = x
        view.shallow_line.yf = y
        view.shallow_bump = ViewBump.new(x, y, view.shallow_bump)
        
        cur_bump = view.steep_bump
        while not cur_bump.nil?
            if view.shallow_line.above?(cur_bump.x, cur_bump.y)
                view.shallow_line.xi = cur_bump.x
                view.shallow_line.yi = cur_bump.y
            end
            cur_bump = cur_bump.parent
        end
    end
    
    def add_steep_bump(x, y, view)
        view.steep_line.xf = x
        view.steep_line.yf = y
        view.steep_bump = ViewBump.new(x, y, view.steep_bump)
        
        cur_bump = view.shallow_bump
        while not cur_bump.nil?
            if view.steep_line.below?(cur_bump.x, cur_bump.y)
                view.steep_line.xi = cur_bump.x
                view.steep_line.yi = cur_bump.y
            end
            cur_bump = cur_bump.parent
        end
    end
    
    # Removes the view in active_views at index view_index if:
    # * The two lines are collinear
    # * The lines pass through either extremity
    def check_view(active_views, view_index)
        shallow_line = active_views[view_index].shallow_line
        steep_line = active_views[view_index].steep_line
        if shallow_line.line_collinear?(steep_line) and (shallow_line.collinear?(0, 1) or
            shallow_line.collinear?(1, 0))
            active_views.delete_at view_index
            return false
        end
        return true
    end
end

require_relative 'components'

Light = Struct.new(:color, :distance, :pos) do
  def manifest(map)
    @map = map
    #let's just do a lot of elimination and care about the performance later
    return colormap
  end
  
  def colormap
    @colormap ||= uncached_colormap
  end
  
  def uncached_colormap
    colormap = {}
    range_of_tiles.each do |t|
      x = t[0]
      y = t[1]
      a = 255 / ([raw_distance(0,0,x,y),1].max)
      colormap[[x,y]] = Gosu::Color.new(a, self.color.r,self.color.g,self.color.b)
    end
    return colormap
  end
  
  def write(colormap, x,y,value)
    colormap[[x,y]] = value
  end
  
  
  def range_of_tiles
    @range_of_tiles ||= uncached_range_of_tiles
    return @range_of_tiles
  end
  
  def uncached_range_of_tiles
    possible_tiles = []
    for i in (-distance)..distance
      for j in (-distance)..distance
        possible_tiles << [i,j]
      end
    end
    
    r = self.distance
    possible_tiles.select! do |t|
      x = t[0]
      y = t[1]
      x**2 + y**2 < r**2
    end
    return possible_tiles
  end
  
  def uncached_range_of_tiles
    return get_possible_points_for_shadowcasting(@map.raw, self.pos.x, self.pos.y, self.distance)
  end
  
end

module LightBlend
  def blend_lights(array_of_lights)
    colormaps = []
    array_of_lights.each do |l|
      colormap = {}
      manifested_data = l.manifest(self)
      #p manifested_data
      x_offset = l.pos.x
      y_offset = l.pos.y
      
      manifested_data.each do |md, c|
        colormap[[md[0] + x_offset, md[1] + y_offset]] = c
      end
      colormaps << colormap
    end
    return avg_colormap(colormaps)
  end
  
  def avg_colormap(array_of_colormaps)
    #p array_of_colormaps
    manageble_version = {}
    array_of_colormaps.each do |cm|
      cm.each do |k,v|
        if manageble_version[k]
          manageble_version[k] << v
        else
          manageble_version[k] = [v]
        end
      end
    end
    
    final_ver = {}
   #p manageble_version
    manageble_version.each do |k, v|
      final_ver[k] = v.color_sum
    end
    
    return final_ver
  end
end


class DummyMap
  include PermissiveFieldOfView
  attr_reader :raw
  attr_accessor :lighted_coords
  def initialize(raw)
    @raw = raw
    @lighted_coords = []
  end
  
  def blocked?(x,y)
    !movable_in_map?(self.raw,x,y)
  end
  
  def light(x,y)
    @lighted_coords << [x,y]
  end
  
  def width
    return @raw.lines.to_a[0].length
  end
  
  def height
    return @raw.lines.to_a.length
  end
end

def get_possible_points_for_shadowcasting(raw_map, sx, sy, r)
  d = DummyMap.new(raw_map)
  d.do_fov(sx,sy,r)
  return d.lighted_coords.collect{|c| [c[0] - sx, c[1] - sy]}
end

class Map
  include ShadowcastingFieldOfView
  include LightBlend
  attr_accessor :raw
  attr_accessor :lightmap, :colormap
  attr_accessor :explored
  def initialize(raw)
    @raw = raw
    @lights = []
    
    
    #lights_coord.each do |c|
     # @lights << Light.new(Gosu::Color::RED, 10, Pos.new(c[0],c[1]))
   # end
   
   @lights << Light.new(Gosu::Color::WHITE,10,Pos.new(4,4))
    
    @lightmap = {}
    @colormap = {}
    @explored = {}
    
    
    @raw = tiles_to_readable self.arraylized
    #binding.pry
  end
  
  def bind_entities(entities)
    a = arraylized
    
    empties = []
    width.times do |x|
      height.times do |y|
        case a[x][y]
        when "r"
          entities << Factory.rabbit(x,y)
          a[x][y] = "."
        when "f"
          entities << Factory.small_fairy(x,y)
          a[x][y] = "."
        when "p"
          entities << Factory.create_point_item(x,y)
          a[x][y] = "."
        when "P"
          entities << Factory.create_power_item(x,y)
          a[x][y] = "."
        when "n"
          entities << Factory.create_night_item(x,y)
          a[x][y] = "."
        when "F"
          entities << Factory.sunflower_fairy(x,y)
          a[x][y] = "."
        when "o"
          entities << Factory.kedama(x,y)
          a[x][y] = "."
        when "O"
          entities << Factory.red_kedama(x,y)
          a[x][y] = "."
        when "c"
          entities << Factory.crow(x,y)
          a[x][y] = "."
        when "K"
          entities << Factory.kaguya(x,y)
          a[x][y] = "."
        end
        
        if a[x][y] == "."
          empties << [x,y]
        end
        
        
      end
    end
    entities << Factory.create_card_item(*empties.sample)
    @raw = tiles_to_readable a
  end
  
  def find_start
    a = arraylized
    width.times do |x|
      height.times do |y|
        if a[x][y] == ">"
          a[x][y] = "."
          return [x,y]
        end
      end
    end
  end
  
  
  def width
    arraylized.size
  end
  
  def height
    arraylized[0].size
  end
  
  def uncached_arraylized
    un_m = []
    @raw.lines.each do |l|
      c = l.chars.to_a
      c = c.delete_if{|e| e=="\n"}
      un_m.push c
    end
    un_m.transpose
  end
  
  def arraylized
    @arraylized ||= uncached_arraylized
  end
  
  
  def clip_from_up(a,cliped_total)
    a.transpose[cliped_total..(a[0].length-1)].transpose
  end
  
  def clip_from_down(a,cliped_total)
    a.transpose[0..(a[0].length-1-cliped_total)].transpose
  end
  
  def clip_from_left(a,cliped_total)
    a[cliped_total..(a.length-1)]
  end
  
  def clip_from_right(a,cliped_total)
    a[0..(a.length-1-cliped_total)]
  end
  
  def fit_for_camera(camera_lx,camera_ly,camera_rx,camera_ry)
    a = arraylized
    
    rc = width - camera_rx
    lc = camera_lx
    uc = camera_ly
    dc = height - camera_ry
    return tiles_to_readable(clip_from_left(clip_from_up(clip_from_down(clip_from_right(a,rc),dc),uc),lc))
  end
  
  def fit_for_the_camera(player)
    fit_for_camera(*Camera.get_rect(player))
  end
  

  def light(x,y)
    @lightmap[[x,y]] = true
    @explored[[x,y]] = true
  end

  def blocked?(x,y)
    !movable_in_map?(self,x,y)
  end

  def lines
    return self.raw.lines
  end

  def lit? x, y
    return @lightmap[[x,y]]
  end
  
  def colorize_lights
    @colormap = blend_lights(@lights)
  end
  

  def explored? x, y
    return @explored[[x,y]]
  end
  
end
