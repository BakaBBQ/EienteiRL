class Attack ; end


require_relative 'helper'
require_relative 'vocab'
class << Attack
  def process_single_entity(entities, e, map, minibuffer,canvas)
    attack_move = e.attack_move
    return unless attack_move

    attack_move.targets.compact.each do |t|
      dmg = attack_move.dice.call
      if t.hp
        t.hp -= dmg
      else
        p "something is wrong: e: #{e.name}, t: #{t.name}"
        return
      end
      
      pop_msg(minibuffer, "damge done: #{dmg}") unless 0 == dmg
      t.was_target = true
      if 0 >= t.hp
        t.destroy = true
      end
    end
    e.attack_move = nil
    
  end
end
