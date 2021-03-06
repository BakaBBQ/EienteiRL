# encoding: UTF-8
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
  if possible_vel.nil?
    return
  end
  e.velocity.vx = possible_vel.vx
  e.velocity.vy = possible_vel.vy
end

def bullet_absorb(me,entities,map)
  lv = $game.get_level(:bullet_absorb)
  
  d = [4,5,5,6,6][lv]
  bullets = get_bullets_seen(me,entities,map).select{|e| entity_distance(me,e) < d}
  
  cnt = 0
  bullets.each do |b|
    entities.delete b
    if (rand > 1.0 - lv * 0.05) && movable?(entities,map,b.pos.x,b.pos.y)
      case rand(5)
      when 0..1
        entities << Factory.create_night_item(b.pos.x,b.pos.y) 
      when 2..4
        entities << Factory.create_point_item(b.pos.x,b.pos.y) 
      else
        entities << Factory.create_power_item(b.pos.x,b.pos.y) 
      end
    end
    cnt += 1
  end
end

def fairy_ai(me,entities,map)
  #brainlessly shoot bullets
  if rand > 0.8 && me.discovered && entity_distance(entities.first,me) <= 60
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,1,0,3)
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,0,-1,3)
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,-1,0,3)
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,0,1,3)
    
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,1,1,3)
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,-1,1,3)
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,1,-1,3)
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,-1,-1,3)
  end
  simple_melee(me,entities,map)
end

def flame_ai(me,entities,map)
  offsets = []
  [-1,0,1].each do |x|
    [-1,0,1].each do |y|
      offsets << [me.pos.x + x,me.pos.y + y]
    end
  end
  
  possible_damage_targets = []
  possible_more_flames = []
  offsets.each do |o|
    possible_damage_targets += get_entity_on(entities,o[0],o[1])
    if movable?(entities,map,o[0],o[1])
      possible_more_flames << o
    end
  end
  
  
  me.attack_move = AttackMove.new(lambda{4},possible_damage_targets)
  possible_more_flames.each do |c|
    entities << Factory.flame(*c,me.life - 0.1) if rand > (1.0 - me.life)
  end
  
  entities.delete(me)
  
  #entities << Factory.bullet(me.pos.x + x_offset,me.pos.y + y_offset,x,y,damage,char,color)
end


def sunflower_fairy_ai(me,entities,map)
  #brainlessly shoot bullets
  if rand > 0.8 && me.discovered && entity_distance(entities.first,me) <= 60
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,1,0,6)
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,0,-1,6)
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,-1,0,6)
    shoot_bullet(me,entities,"*",Gosu::Color::GREEN,0,1,6)
    
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,1,1,6)
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,-1,1,6)
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,1,-1,6)
    shoot_bullet(me,entities,"*",Gosu::Color::FUCHSIA,-1,-1,6)
  end
  simple_melee(me,entities,map)
end

def kaguya_ai(me,entities,map)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),1,0,10)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),0,-1,10)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),-1,0,10)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),0,1,10)
  
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),1,1,10)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),-1,1,10)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),1,-1,10)
  shoot_bullet(me,entities,"*",Gosu::Color.new(159,50,83),-1,-1,10)
  
  simple_melee(me,entities,map)
end


def kedama_ai(me,entities,map)
  #brainlessly shoot bullets
  
  if me.discovered && entity_distance(entities.first,me) <= 60
    if rand > 0.8
      shoot_bullet(me,entities,"*",Gosu::Color.new(140,20,240),1,0,4)
      shoot_bullet(me,entities,"*",Gosu::Color.new(140,20,240),-1,0,4)
      shoot_bullet(me,entities,"*",Gosu::Color.new(140,20,240),0,1,4)
      shoot_bullet(me,entities,"*",Gosu::Color.new(140,20,240),0,-1,4)
    end
    
    
    random_move(me,entities,map)
  end
end

def red_kedama_ai(me,entities,map)
  #brainlessly shoot bullets
  
  if me.discovered && entity_distance(entities.first,me) <= 30
    if rand > 0.8
      shoot_bullet(me,entities,"●",Gosu::Color.new(140,20,240),1,0,5)
      shoot_bullet(me,entities,"●",Gosu::Color.new(140,20,240),-1,0,5)
      shoot_bullet(me,entities,"●",Gosu::Color.new(140,20,240),0,1,5)
      shoot_bullet(me,entities,"●",Gosu::Color.new(140,20,240),0,-1,5)
    end
    
    
    random_move(me,entities,map)
  end
end


def shoot_bullet(me,entities,char,color,x,y,damage)
  x_offset = x > 0 ? 1 : -1
  y_offset = y > 0 ? 1 : -1
  entities << Factory.bullet(me.pos.x + x_offset,me.pos.y + y_offset,x,y,damage,char,color)
end



def simple_melee(e,entities,map)
  if entity_distance(e,entities.first) <= 1.5
    #binding.pry
    e.attack_move = AttackMove.new(e.dice,entities.take(1))
    #p e.attack_move.targets
  elsif entity_distance(e,entities.first) <= 8
    move_close_from(e,entities.first,entities,map)
  else
    random_move(e,entities,map)
  end
end

def spinner(me,entities,map)
  dice = generate_dice(2, 2, $game.get_level(:doll_placement))
  targets = entities.select{|e| (!e.player) && (! e.doll) && (! e.bullet) && entity_distance(me,e) <= 1.5}
  me.attack_move = AttackMove.new(dice,targets)
end


def edo(me,entities,map)
  dice = generate_dice(5, 10, $game.get_level(:edo))
  targets = entities.select{|e| (!e.player) && (! e.doll) && (! e.bullet) && entity_distance(me,e) <= 1.5}
  if targets.empty?
    # walk towards the nearest enemy
    possible_target = entities.select{|e| (!e.player) && (! e.doll)}.sort_by{|e| entity_distance(me,e)}.first
    return if possible_target.nil?
    move_close_from(me,possible_target,entities,map)
  else
    # we find a possible target, now explode
    targets = entities.select{|e| entity_distance(me,e) <= 1.5}
    me.attack_move = AttackMove.new(dice,targets)
    me.destroy = true
  end
end

def ambush(me,entities,map)
  dice = generate_dice(2, 3, $game.get_level(:ambush))
  targets = entities.select{|e| (!e.player) && (! e.doll) && (! e.bullet) && entity_distance(me,e) <= 1.5}
  if targets.empty?

  else
    targets = entities.select{|e| (! e.doll) && (! e.player) && (! e.bullet) && entity_distance(me,e) <= 1.5}.select{|e|e.hp}.sort_by{|e| e.hp}.take(1)
    me.attack_move = AttackMove.new(dice,targets)
    me.destroy = true
  end
end

def servant(me,entities,map)
  dice = generate_dice(2, 3, $game.get_level(:servant))
  targets = entities.select{|e| (!e.player) && (! e.doll) && (! e.bullet) && entity_distance(me,e) <= 1.5}
  if targets.empty?
    move_close_from(me,entities.first,entities,map)
  else
    targets = entities.select{|e| (! e.doll) && (! e.player)&& (! e.bullet) && entity_distance(me,e) <= 1.5}.sort_by{|e| e.hp}.take(1)
    me.attack_move = AttackMove.new(dice,targets)
  end
end


def move_close_from(e1,e2,entities,map)
  #hey lets do something stupid
  places = []
  [-1,0,1].each do |m|
    [-1,0,1].each do |n|
      next if m == n && m == 0
      places << [e1.pos.x + m, e1.pos.y + n]
    end
  end
  
  places = places.select{|c| movable?(entities,map,c[0],c[1])}
  
  places.sort_by!{|c| raw_distance(c[0],c[1],e2.pos.x,e2.pos.y)}
  return if places.empty?
  e1.pos.x = places.first[0]
  e1.pos.y = places.first[1]
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
      simple_melee(e,entities,map)
    when :spinner
      spinner(e,entities,map)
    when :edo
      edo(e,entities,map)
    when :ambush
      ambush(e,entities,map)
    when :servant
      servant(e,entities,map)
    when :fairy
      fairy_ai(e,entities,map)
    when :kedama
      kedama_ai(e,entities,map)
    when :red_kedama
      red_kedama_ai(e,entities,map)
    when :bullet_absorber
      bullet_absorb(e,entities,map)
    when :sunflower_fairy
      sunflower_fiary_ai(e,entities,map)
    when :flame
      flame_ai e, entities, map
    when :kaguya
      kaguya_ai e, entities, map
    end
  end
end
