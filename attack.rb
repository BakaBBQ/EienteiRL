class Attack ; end


require_relative 'helper'
require_relative 'vocab'
class << Attack
  def process_single_entity(entities, e, map, minibuffer,canvas)
    attack_move = e.attack_move
    return unless attack_move
    
    attack_move.targets.each do |t|
      dmg = attack_move.dice.call
      
    end
    future_x = e.pos.x + e.velocity.vx
    future_y = e.pos.y + e.velocity.vy

    #to prevent entities bumping into walls
    if movable_in_entity?(entities,future_x,future_y) && movable_in_map?(map,future_x,future_y)
      e.pos.x = future_x
      e.pos.y = future_y
    elsif !movable_in_map?(map,future_x,future_y)
      pop_msg(minibuffer, get_vocab(:wall)) if entities[0] == e
    elsif !movable_in_entity?(entities[1..(entities.length-1)],future_x,future_y)
      pop_msg(minibuffer, "collide_with_entity") if entities[0] == e
    end

    e.velocity.vx = 0
    e.velocity.vy = 0
    
    canvas.clear
    canvas.mash(map,entities)
  end
end
