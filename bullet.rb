class Bullet ; end


require_relative 'helper'
require_relative 'vocab'
class << Bullet
  def process_single_entity(entities, e, map, minibuffer,canvas)
    return unless e.rpos
    future_rx = e.rpos.x + e.rvel.vx
    future_ry = e.rpos.y + e.rvel.vy
    
    e.rpos.x = future_rx
    e.rpos.y = future_ry
    
    grid_x, grid_y = *get_grid_x_y(e)

    if movable_in_entity?(entities,grid_x,grid_y) && movable_in_map?(map,grid_x,grid_y)
      e.pos.x = grid_x
      e.pos.y = grid_y
    elsif !movable_in_map?(map,grid_x,grid_y)
      e.destroy = true
    elsif !movable_in_entity?(entities[0..(entities.length-1)],grid_x,grid_y)
      all_obstacles = get_entity_on(entities,grid_x,grid_y)
      if all_obstacles.include? entities.first
        if entities.first.just_moved
        else
          entities.first.hp -= e.damage
          if entities.first.hp <= 0
            entities.first.destroy = true
          end
        end
        e.destroy = true
      else
        e.pos.x = grid_x
        e.pos.y = grid_y
      end
      
      
    end
  end
  
  def get_grid_x_y(e)
    return [e.rpos.x / 10, e.rpos.y / 10]
  end
  
end
