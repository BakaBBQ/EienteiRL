class Movement ; end


require_relative 'helper'
require_relative 'vocab'
class << Movement
  def process(entities, map, canvas, minibuffer)
    entities.select{|e| e.velocity}.each do |e|
      process_single_entity(entities, e, map, minibuffer)
    end
  end

  def process_single_entity(entities, e, map, minibuffer)
    future_x = e.pos.x + e.velocity.vx
    future_y = e.pos.y + e.velocity.vy

    #to prevent entities bumping into walls
    if movable_in_entity?(entities,future_x,future_y) && movable_in_map?(map,future_x,future_y)
      e.pos.x = future_x
      e.pos.y = future_y
    elsif !movable_in_map?(map,future_x,future_y)
      pop_msg(minibuffer, get_vocab(:wall)) if entities[0] == e
    else
      pop_msg(minibuffer, "collide_with_entity") if entities[0] == e
    end

    e.velocity.vx = 0
    e.velocity.vy = 0
  end
end
