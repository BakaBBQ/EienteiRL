require_relative 'movement'

require_relative 'render'
require_relative 'mind'
require_relative 'attack'
require_relative 'skills'

#propably I should look into couroutines

def update_movement(time,entities, map, canvas,minibuffer)
  delta_vx = 0 #maybe just call it ax...
  delta_vy = 0
  wait = false
  
  actor = entities[0]
  if button_down?(DIRECTION2NUMPAD[2]) || button_down?(char_to_button_id(DIRECTION2VI[2])) 
    delta_vy = 1
  elsif button_down?(DIRECTION2NUMPAD[8]) || button_down?(char_to_button_id(DIRECTION2VI[8])) 
    delta_vy = -1
  elsif button_down?(DIRECTION2NUMPAD[4]) || button_down?(char_to_button_id(DIRECTION2VI[4])) 
    delta_vx = -1
  elsif button_down?(DIRECTION2NUMPAD[6]) || button_down?(char_to_button_id(DIRECTION2VI[6])) 
    delta_vx = 1
  elsif button_down?(DIRECTION2NUMPAD[1]) || button_down?(char_to_button_id(DIRECTION2VI[1])) 
    delta_vx = -1
    delta_vy = 1
  elsif button_down?(DIRECTION2NUMPAD[3]) || button_down?(char_to_button_id(DIRECTION2VI[3])) 
    delta_vx = 1
    delta_vy = 1
  elsif button_down?(DIRECTION2NUMPAD[7]) || button_down?(char_to_button_id(DIRECTION2VI[7])) 
    delta_vx = -1
    delta_vy = -1
  elsif button_down?(DIRECTION2NUMPAD[9]) || button_down?(char_to_button_id(DIRECTION2VI[9])) 
    delta_vx = +1
    delta_vy = -1
  elsif button_down?(DIRECTION2NUMPAD[5]) || button_down?(char_to_button_id(DIRECTION2VI[5]))
    wait = true
  end

  if delta_vx != 0 || delta_vy != 0 || wait
    actor.velocity = Velocity.new(delta_vx, delta_vy)
    @input_timer = 0
    take_into_player_effect(entities, entities.first, map, minibuffer,canvas)
    Render.process(time,entities,map,canvas,minibuffer)
    Attack.process_single_entity(entities, actor, map, minibuffer,canvas)
    player_decided
  end
  
  if button_down?(char_to_button_id('f')) || button_down?(char_to_button_id('z'))
    return if actor.mp < 5
    actor.mp -= 5
    Skills.manifest(actor.shot, actor, time,entities,map,canvas,minibuffer)
    @input_timer = 0
    take_into_player_effect(entities, entities.first, map, minibuffer,canvas)
    Attack.process_single_entity(entities, actor, map, minibuffer,canvas)
    Render.process(time,entities,map,canvas,minibuffer)
    player_decided
  end
  
  ['q','w','e','r','t'].each_with_index do |key, i|
    next if actor.skills[i].nil?
    if button_down?(char_to_button_id(key))
      return if actor.mp <= 10
      actor.mp -= 10
      Skills.manifest(actor.skills[i],actor,time,entities,map,canvas,minibuffer)
      @input_timer = 0
      take_into_player_effect(entities, entities.first, map, minibuffer,canvas)
      Attack.process_single_entity(entities, actor, map, minibuffer,canvas)
      Render.process(time,entities,map,canvas,minibuffer)
      player_decided
    end
  end
  update_command(time,entities,map,canvas,minibuffer)
end

def update_command(time,entities,map,canvas,minibuffer)
  if button_down?(char_to_button_id('<')) || button_down?(char_to_button_id(','))
    if map.arraylized[entities.first.pos.x][entities.first.pos.y] == "<"
      pop_msg minibuffer, "You go upstairs... (Continue)"
      Render.process(time,entities, map, canvas,minibuffer)
      $game.ascend_to_new_level
    else
      pop_msg minibuffer, "There is nowhere to go up."
    end
    @input_timer = 0
    #Render.process(time,entities, map, canvas,minibuffer)
  end
  
  if button_down?(char_to_button_id('s'))
    return unless entities.first.hand.size >= 1
    
    entities.first.hand.push entities.first.hand.shift
    @input_timer = 0
    Render.process(time,entities, map, canvas,minibuffer)
  end
  
  if button_down?(char_to_button_id('d'))
    return unless entities.first.hand.size >= 1
    
    current_card = entities.first.hand.first
    if current_card.name == :mhp
      entities.first.mhp += (entities.first.mhp * 0.1).round
    elsif current_card.name == :mmp
      entities.first.mmp += (entities.first.mmp * 0.1).round
    else
      made = false
      (entities.first.skills + [entities.first.shot]).each do |s|
        if s.code == current_card.name
          made = true
          s.level += 1
          s.level = 4 if s.level >= 4
        end
      end
      entities.first.skills.push(Skill.new(1,current_card.name)) unless made
    end
    entities.first.hand.shift
    @input_timer = 0
    Render.process(time,entities, map, canvas,minibuffer)
  end
end

def add_drop (e,time,entities, map, canvas,minibuffer)
  drop_sym = e.drop
  
  pos = e.pos
  
  px = e.pos.x
  py = e.pos.y
  case drop_sym
  when :power
    entities << Factory.create_power_item(px,py)
  when :point
    entities << Factory.create_point_item(px,py)
  when :night
    entities << Factory.create_night_item(px,py)
  end
end

def turn(time,entities, map, canvas,minibuffer)
  if waiting_for_player_deide?
    @input_timer ||= 0
    @input_timer += 1
    update_movement(time,entities, map, canvas,minibuffer) if @input_timer >= INPUT_WAIT
  else
    t = 0
    loop do
      time = time + 1 if rand > (entities.first.np / 100.0) && !entities.first.time_stop
      
      if time >= Time.new(1969,9,12,5,0,0)
        $game.state = :game_over
      end
      
      #let's go very imperative this time
      end_this = false
      
      entities.select{|e| e.energy}.each do |e|
        e.energy+=1
        if e.energy >= e.speed
          Mind.process_single_entity(entities, e, map, minibuffer)
          Attack.process_single_entity(entities, e, map, minibuffer,canvas)
          Movement.process_single_entity(entities, e, map, minibuffer,canvas)
          Bullet.process_single_entity(entities, e, map, minibuffer,canvas)
          
          e.energy = 0
          if (e.player)
            end_this = true
          end
          if e.destroy
            if e.player
              $game.state = :game_over
            end
            
            if e.kaguya
              $game.state = :win
            end
            
            if e.drop
              add_drop e,time,entities, map, canvas,minibuffer
            end
            msg "#{e.name} is slain." if e.name
            entities.delete e unless e.player
          end
        end
      end
      
      break if end_this
    end

    
    Render.process(time,entities,map,canvas,minibuffer)
  end
  
  
  return time
end

def take_into_player_effect(entities, e, map, minibuffer,canvas)
  Movement.process_single_entity(entities, e, map, minibuffer,canvas)
  e.hp += 1 if e.hp < e.mhp && rand > 0.8
  e.mp += 1 if e.mp < e.mmp
  if e.np > 0
    min_d = entities[1...entities.size].collect{|m| entity_distance(e,m)}.sort[0]
    return if min_d.nil?
    case min_d
    when 0..2
    when 3..8
      e.np -= 1 if rand > 0.5
    when 9..15
      e.np -= 1 if rand > 0.3
    else
      e.np -= 1
    end
  end
  e.energy = 0
  if e.time_stop
    c = (5 - $game.get_level(:time_stop) * 0.5).floor
    if e.mp < c
      e.time_stop = false
    else
      e.mp -= c
      e.energy = e.speed
    end
  end
  
end
