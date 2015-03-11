require 'pry'
def movable_in_map?(map,x,y)
  #binding.pry
  begin
    !(['#'].include?(map.lines[y][x]))
  rescue
    p "movable failed #{x}, #{y}"
    false
  end
end

def need_invert?(char)
  return ['#'].include? char
end

def draw_rect(x,y,width,height,c)
  draw_quad(x,y,c,x+width,y,c,x,y+height,c,x+width,y+height,c)
end

def movable_in_entity?(entities,x,y)
  entities[0..(entities.length-1)].select{|e| e.pos.x == x}.select{|e| e.pos.y == y}.empty?
end

def tiles_to_readable(data)
  lines = []
  
  height = data[0].size
  width = data.size
  
  height.times do |h|
    cline = ""
    width.times do |w|
      cline+=data[w][h]
    end
    lines << cline
  end
  return lines.join("\n")
end

def delete_and_return_rest(array, char)
  a = array.delete(char)
  return a
end


def do_damage_while_pop_message(entity,dmg,minibuffer)
  future_hp = entity.hp - dmg
  vocab_set = case (future_hp / entity.mhp.to_f) * 100
  when 0..20
    :dying
  when 21..40
    :moderate_to_lower
  when 41..60
    :moderate
  when 61..80
    :moderate_to_upper
  when 81.90
    :light_dmg
  when 91..100
    :very_light_dmg
  end
  
  pop_msg(minibuffer, get_vocab(vocab_set, entity.name))
  entity.hp = future_hp
end

def arraylize(str)
  str.chars
end


def movable?(entities,map,x,y)
  movable_in_map?(map,x,y) && movable_in_entity?(entities,x,y)
end

def vel_will_not_collide(e, vel,entities,map)
  future_x = e.pos.x + vel.vx
  future_y = e.pos.y + vel.vy
  return movable?(entities,map,future_x,future_y)
end

def raw_distance(x0,y0,x1,y1)
  return Math.hypot(x0 - x1, y0 - y1)
end


class Array
    def sum
      inject(0.0) { |result, el| result + el }
    end

    def mean 
      sum / size
    end
end
  
  

class Array
    def color_mean 
      final_c = Gosu::Color.new(0,0,0,0)
      final_c.a = collect{|c| c.a}.sum / size
      final_c.r = collect{|c| c.r}.sum / size
      final_c.g = collect{|c| c.g}.sum / size
      final_c.b = collect{|c| c.b}.sum / size
      return final_c
    end
    
    def color_sum
      final_c = Gosu::Color.new(0,0,0,0)
      final_c.a = collect{|c| c.a}.sum / 1
      final_c.r = collect{|c| c.r}.sum / 1
      final_c.g = collect{|c| c.g}.sum / 1
      final_c.b = collect{|c| c.b}.sum / 1
      return final_c
    end
end

class Gosu::Color
  alias r red
  alias g green
  alias b blue
  alias a alpha
  alias r= red=
  alias g= green=
  alias b= blue=
  alias a= alpha=
end

def slurp file_name
  return File.open(file_name, "rb").read
end

def pop_msg(minibuffer,msg)
  minibuffer << msg
end

def fmt_time(time) # => str
  return time.strftime("%l:%M %p").sub(" ", '')
end

