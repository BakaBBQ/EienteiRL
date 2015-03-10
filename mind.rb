class Mind ; end


require_relative 'helper'
require_relative 'vocab'

def random_move(e,entities,map) #gets all viable places to move, then move to that place
  offsets = []
  [-1,0,1].each do |x|
    [-1,0,1].each do |y|
      offsets << [x,y]
    end
  end
  
  all_vel = []
  offsets.each do |o|
    all_vel << Velocity.new(o[0],o[1])
  end
  
  possible_vel = all_vel.select{|vel| vel_will_not_collide(e, vel,entities,map)}.sample
  e.velocity.vx = possible_vel.vx
  e.velocity.vy = possible_vel.vy
end

def distance_from_player(e,entities,map)
  player = entities[0]
  return Math.hypot(player.pos.x - e.pos.x, player.pos.y - e.pos.y)
end



class << Mind
  def process(entities, map, canvas, minibuffer)
    entities.select{|e| e.mind}.each do |e|
      process_single_entity(entities, e, map, minibuffer)
    end
  end

  def process_single_entity(entities, e, map, minibuffer)
    mind = e.mind
    
    case mind
    when :player
      wait_for_player_to_decide
    when :silly
      random_move(e,entities,map)
    end
  end
end
