require_relative 'movement'

require_relative 'render'
require_relative 'mind'


#propably I should look into couroutines

def update_movement(time,entities, map, canvas,minibuffer)
  delta_vx = 0 #maybe just call it ax...
  delta_vy = 0
  
  actor = entities[0]
  if button_down?(char_to_button_id('s'))
    delta_vy += 1
  end

  if button_down?(char_to_button_id('w'))
    delta_vy -= 1
  end

  if button_down?(char_to_button_id('a'))
    delta_vx -= 1
  end

  if button_down?(char_to_button_id('d'))
    delta_vx += 1
  end

  if delta_vx != 0 || delta_vy != 0
    actor.velocity = Velocity.new(delta_vx, delta_vy)
    @input_timer = 0
    take_into_player_effect(entities, entities.first, map, minibuffer,canvas)
    Render.process(time,entities,map,canvas,minibuffer)
    player_decided
  end
end


def turn(time,entities, map, canvas,minibuffer)
  if waiting_for_player_deide?
    @input_timer ||= 0
    @input_timer += 1
    update_movement(time,entities, map, canvas,minibuffer) if @input_timer >= INPUT_WAIT
  else
    loop do
      time = time + 1
      #let's go very imperative this time
    
      end_this = false
      entities.each do |e|
        e.energy+=1
        if e.energy >= e.speed
          Mind.process_single_entity(entities, e, map, minibuffer)
          Movement.process_single_entity(entities, e, map, minibuffer,canvas)
          Bullet.process_single_entity(entities, e, map, minibuffer,canvas)
          e.energy = 0
          if (e.player)
            end_this = true
          end
          if e.destroy
            entities.delete e
          end
        end
      end
      break if end_this
    end
    Render.process(time,entities,map,canvas,minibuffer)
  end
  
  
  return time
  
  #Mind.process(entities,map,canvas,minibuffer)
  #Movement.process(entities,map,canvas,minibuffer)
  #Render.process(time,entities,map,canvas,minibuffer)
end

def take_into_player_effect(entities, e, map, minibuffer,canvas)
  Movement.process_single_entity(entities, e, map, minibuffer,canvas)
  
  e.energy = 0
  
end
