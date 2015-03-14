class Attack ; end


require_relative 'helper'
require_relative 'vocab'
class << Attack
  def process_single_entity(entities, e, map, minibuffer,canvas)
    attack_move = e.attack_move
    return unless attack_move

    attack_move.targets.compact.each do |t|
      dmg = 0
      dmg = attack_move.dice.call if attack_move.dice
      
      if t.hp
        do_damage_while_pop_message(t,dmg,minibuffer) unless dmg == 0
        if t.hp <= 0 && t.player
          $game.state = :game_over
        end
        
      else
        p "something is wrong: e: #{e.name}, t: #{t.name}"
        return
      end
      

      
      t.was_target = true
      if 0 >= t.hp
        t.destroy = true
      end
    end
    e.attack_move = nil
    
  end
end
