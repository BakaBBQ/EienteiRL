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



class Map
  include ShadowcastingFieldOfView
  attr_accessor :raw
  attr_accessor :lightmap
  attr_accessor :explored
  def initialize(raw)
    @raw = raw
    @lightmap = {}
    @explored = {}
  end

  def light(x,y)
    @lightmap[[x,y]] = true
    @explored[[x,y]] = true
  end

  def blocked?(x,y)
    !movable_in_map?(self.raw,x,y)
  end

  def lines
    return self.raw.lines
  end

  def lit? x, y
    return @lightmap[[x,y]]
  end

  def explored? x, y
    return @explored[[x,y]]
  end
  
end
