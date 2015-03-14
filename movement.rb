class Movement ; end


require_relative 'helper'
require_relative 'vocab'
require_relative 'components'
class << Movement
  def process(entities, map, canvas, minibuffer)
    entities.select{|e| e.velocity}.each do |e|
      process_single_entity(entities, e, map, minibuffer)
    end
  end

  def process_single_entity(entities, e, map, minibuffer,canvas)
    return unless e.velocity
    e.just_moved = false
    future_x = e.pos.x + e.velocity.vx
    future_y = e.pos.y + e.velocity.vy

    #to prevent entities bumping into walls
    if movable_in_entity?(entities,future_x,future_y) && movable_in_map?(map,future_x,future_y)
      e.pos.x = future_x
      e.pos.y = future_y
      
      get_entity_on(entities,future_x,future_y).each do |m|
        next if m.player
        next if !e.player
        if m.bullet
          
        elsif m.item
          e.hp = [(e.hp * (1 + m.heal)).floor, e.mhp].min if m.heal
          if m.point
            e.score += (m.point * (1 + e.np / 100.0)).round
            e.np = [e.np + 5, 100].min
          end
          e.deck = e.deck.shuffle!
          e.hand << e.deck.shift if m.card &&! e.deck.empty?
          e.np = [e.np + 20, 100].min if m.night
        end
        entities.delete m
      end
      e.just_moved = true
      
    elsif !movable_in_map?(map,future_x,future_y)
      pop_msg(minibuffer, get_vocab(:wall)) if entities[0] == e
    elsif !movable_in_entity?(entities[1..(entities.length-1)],future_x,future_y)
      e.attack_move = AttackMove.new(lambda{4},get_entity_on(entities,future_x,future_y).select{|e| (! e.bullet)}) if e.player
    end
    
    e.glyph.invert = false

    e.velocity.vx = 0
    e.velocity.vy = 0
    
  end
end
