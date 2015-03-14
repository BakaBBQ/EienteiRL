module Skills
end



class << Skills
  def manifest(skill, user, time,entities,map,canvas,minibuffer)
    targets = []
    dice = lambda{4}
    case skill.code
    when :six_realms
      dice = generate_dice 4, 2, $game.get_level(:six_realms)
      targets = get_entity_seen(user,entities,map).select{|e| (e.pos.x == user.pos.x || e.pos.y == user.pos.y)}
      targets.delete user
    when :mysterious_jack
      dice = generate_dice 2, 2, $game.get_level(:mysterious_jack)
      a = get_entity_seen(user,entities,map)
      a.delete_at 0
      targets = a.sort_by{|a| entity_distance(user,a)}.take(1)
    when :stardust_missle
      dice = generate_dice 3, 3, $game.get_level(:stardust_missle)
      a = get_entity_seen(user,entities,map)
      a.delete_at 0
      single_target = a.sort_by{|a| entity_distance(user,a)}.take(1)
      
      if single_target.empty?
        targets = single_target
      else
        t = single_target.first
        a.delete t
        targets = a.select{|e| entity_distance(t,e) <= 2}
        targets << t
      end
    when :magic_dust
      cnt = [3,3,4,4,5][$game.get_level(:magic_dust)]
      dice = generate_dice 4, 4, $game.get_level(:magic_dust)
      a = get_entity_seen(user,entities,map)
      a.delete_at 0
      single_target = a.sort_by{|a| entity_distance(user,a)}.take(1)
      
      if single_target.empty?
        targets = single_target
      else
        t = single_target.first
        a.delete t
        targets = a.select{|e| entity_distance(t,e) <= cnt}
        targets << t
      end
    when :flower_slash
      dice = generate_dice 6, 3, $game.get_level(:flower_slash)
      a = get_entity_seen(user,entities,map).select{|e| (e.pos.x - user.pos.x).abs <= 1 && (e.pos.y - user.pos.y).abs <= 1}.sort_by!{|e| e.hp}
      a.delete(user)
      targets = a.take(1)
      return if targets.empty?
      
      st = targets[0]
      pos_diff = [st.pos.x - user.pos.x,st.pos.y - user.pos.y]
      final_pos = Pos.new(st.pos.x + pos_diff[0], st.pos.y + pos_diff[1])
      if movable?(entities,map,final_pos.x,final_pos.y)
        user.pos = final_pos
      end
    when :phosphorus_slash
      dice = generate_dice 5, 3, $game.get_level(:phosphorus_slash)
      a = get_entity_seen(user,entities,map).select{|e| (e.pos.x - user.pos.x).abs <= 1 && (e.pos.y - user.pos.y).abs <= 1}.sort_by!{|e| e.hp}
      a.delete(user)
      targets = a.take(3)
      return if targets.empty?
    when :changeling_magic
      dice = generate_dice 6, 3, $game.get_level(:changeling_magic)
      a = get_entity_seen(user,entities,map).select{|e| (e.pos.x - user.pos.x).abs <= 1 && (e.pos.y - user.pos.y).abs <= 1}.sort_by!{|e| e.hp}
      a.delete(user)
      targets = a.take(1)
      return if targets.empty?
      a_old_pos = user.pos
      user.pos = targets[0].pos
      targets[0].pos = a_old_pos
    when :close_up_magic
      dice = generate_dice 2, 3, $game.get_level(:close_up_magic)
      a = get_entity_seen(user,entities,map).select{|e| (e.pos.x - user.pos.x).abs <= 2 && (e.pos.y - user.pos.y).abs <= 2}.compact.sort_by!{|e| e.hp}
      a.delete(user)
      a.take(4)
      
      targets = a
    when :vanish_everything
      dice = lambda{0}
      a = get_entity_seen(user,entities,map)
      a.delete_at 0
      return if a.empty?
      a = a.sort_by{|a| entity_distance(user,a)}.take(1)
      targets = a
      st = targets[0]
      movable_places = []
      
      rng = [-1..1,-1..1,-2..2,-2..2,-2..2][$game.get_level(:vanish_everything)]
      rng.to_a.each do |m|
        rng.to_a.each do |n|
          next if m == n && m == 0
          movable_places << [st.pos.x + m, st.pos.y + n]
        end
      end
      movable_places = movable_places.select{|p| movable?(entities,map,p[0],p[1])}
      preferable_place = movable_places.sort_by{|p| raw_distance(user.pos.x,user.pos.y,p[0],p[1])}.first
      user.pos.x = preferable_place[0]
      user.pos.y = preferable_place[1]
    when :magic_star_sword
      dice = generate_dice 2, 3, $game.get_level(:magic_star_sword)
      targets = get_entity_seen(user,entities,map).select{|e|(e.pos.x - user.pos.x).abs <= 2 || (e.pos.y - user.pos.y).abs <= 2}.take(3)
      targets.delete(user)
    when :doll_placement
      a = get_entity_seen(user,entities,map)
      a.delete_at 0
      a = a.sort_by{|a| entity_distance(user,a)}.take(1)
      targets = a
      st = targets[0]
      return if st.nil?
      movable_places = []
      [-2,-1,0,1,2].each do |m|
        [-2,-1,0,1,2].each do |n|
          next if m == n && m == 0
          movable_places << [st.pos.x + m, st.pos.y + n]
        end
      end
      movable_places = movable_places.select{|p| movable?(entities,map,p[0],p[1])}
      preferable_place = movable_places.sort_by{|p| raw_distance(user.pos.x,user.pos.y,p[0],p[1])}.last
      
      entities.push Factory.create_doll_spinner(preferable_place[0], preferable_place[1])
      targets = []
    when :edo
      nearest_enemy = get_entity_seen(user,entities,map).sort_by{|e| entity_distance(user, e)}.first
      return unless nearest_enemy
      movable_places = []
      [-1,0,1].each do |m|
        [-1,0,1].each do |n|
          next if m == n && m == 0
          movable_places << [user.pos.x + m, user.pos.y + n]
        end
      end
      movable_places = movable_places.select{|p| movable?(entities,map,p[0],p[1])}
      preferable_place = movable_places.sort_by{|p| raw_distance(nearest_enemy.pos.x,nearest_enemy.pos.y,p[0],p[1])}.last
      entities.push Factory.create_edo_doll(preferable_place[0], preferable_place[1])
      targets = []
    when :ambush
      possible_ambush_places = []
      [-1,0,1].each do |m|
        [-1,0,1].each do |n|
          next if m == n && m == 0
          possible_ambush_places << [user.pos.x + m, user.pos.y + n]
        end
      end
      cnt = [3,4,4,5,5][$game.get_level(:ambush)]
      possible_ambush_places.select{|p| movable?(entities,map,p[0],p[1])}.sample(cnt).each do |p|
        entities.push Factory.create_ambush_doll(p[0], p[1])
      end
      targets = []
    when :servant
      possible_ambush_places = []
      [-1,0,1].each do |m|
        [-1,0,1].each do |n|
          next if m == n && m == 0
          possible_ambush_places << [user.pos.x + m, user.pos.y + n]
        end
      end
      servant_cnt = [1,1,1,1,2][$game.get_level(:servant)]
      possible_ambush_places.select{|p| movable?(entities,map,p[0],p[1])}.sample(1).each do |p|
        entities.push Factory.create_servant_doll(p[0], p[1])
      end
      targets = []
    when :bullet_absorb
      a = get_bullets_seen(user,entities,map)
      a.delete_at 0
      a = a.sort_by{|a| entity_distance(user,a)}.take(1)
      targets = a
      st = targets[0]
      return if st.nil?
      movable_places = []
      [-2,-1,0,1,2].each do |m|
        [-2,-1,0,1,2].each do |n|
          next if m == n && m == 0
          movable_places << [st.pos.x + m, st.pos.y + n]
        end
      end
      movable_places = movable_places.select{|p| movable?(entities,map,p[0],p[1])}
      preferable_place = movable_places.sort_by{|p| raw_distance(user.pos.x,user.pos.y,p[0],p[1])}.last
      
      entities.push Factory.create_bullet_absorber(preferable_place[0], preferable_place[1])
      targets = []
    when :summer_flame
      movable_places = []
      [-2,-1,0,1,2].each do |m|
        [-2,-1,0,1,2].each do |n|
          next if m == n && m == 0
          movable_places << [user.pos.x + m, user.pos.y + n]
        end
      end
      movable_places = movable_places.select{|p| movable?(entities,map,p[0],p[1])}
      preferable_place = movable_places.sort_by{|p| raw_distance(user.pos.x,user.pos.y,p[0],p[1])}.last
      
      entities.push Factory.flame(preferable_place[0], preferable_place[1], 0.8 + $game.get_level(:summer_flame) * 0.05)
      targets = []
    when :borrow
      a = get_entity_seen(user,entities,map).select{|e| (e.pos.x - user.pos.x).abs <= 1 && (e.pos.y - user.pos.y).abs <= 1}.sort_by!{|e| e.hp}
      a.delete(user)
      if a.first && a.first.drop
        movable_places = []
        [-1,0,1].each do |m|
          [-1,0,1].each do |n|
            next if m == n && m == 0
            movable_places << [user.pos.x + m, user.pos.y + n]
          end
        end
        movable_places = movable_places.select{|p| movable?(entities,map,p[0],p[1])}
        preferable_place = movable_places.sample
        if rand > (0.5 + $game.get_level(:borrow) * 0.1)
          msg(get_vocab(:failed_borrow))
          return
        end
        
        if preferable_place
          case rand(3)
          when 0
            entities.push Factory.create_power_item(preferable_place[0],preferable_place[1]) 
          when 1
            entities.push Factory.create_night_item(preferable_place[0],preferable_place[1]) 
          when 2
            entities.push Factory.create_point_item(preferable_place[0],preferable_place[1]) 
          end
        end
        
      end
    when :time_stop
      user.time_stop = true
      user.energy = user.speed
    when :doll_recycle
      cnt = 0
      entities.select{|e| e.doll}.each do |d|
        entities.delete d
        cnt+=1
      end
      multiplier = [1,2,2,3,4][$game.get_level(:doll_recycle)]
      user.mp = [user.mp + cnt * multiplier, user.mmp].min
      targets = []
    end
    user.attack_move = AttackMove.new(dice,targets)
  end
end
