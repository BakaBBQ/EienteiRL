# encoding: UTF-8
require_relative 'walker.rb'
require_relative 'arena.rb'

def create_dungeon( arena, walk_length, level,have_stairs = true, walker = Walker.new )
  @room_index ||= 0
  while(walk_length>0)
    walk_length -=1
    
    # Cut out a bit of tunnel where I am.
    arena[*walker.position] = '.'
    walker.wander
    
    # Bosh down a room ocaissionally.
    if(walk_length%80==0)
      create_room(arena, walker,level)
    end

    # Spawn off a child now and then. Split the remaining walk_length with it.
    # Only one of us gets the stairs though.
    if(walk_length%40==0)
      child_walk_length = rand(walk_length)
      walk_length -= child_walk_length
      if child_walk_length > walk_length
        create_dungeon(arena, child_walk_length, level,have_stairs, walker.create_child)
        have_stairs = false
      else
        create_dungeon(arena, child_walk_length, level, false, walker.create_child)
      end
    end
  end

  # Put in the down stairs, if I have them.
  if(have_stairs)
    arena[*(walker.position)] = '>'
  end
end

def create_room(arena, walker,level)
  @room_index += 1
  methods = methods_for level
  p @room_index % methods.size
  methods.collect{|m| method(m)}[@room_index % methods.size].call(arena,walker,level)
end

def methods_for(level,route=:a)
  methods = []
  case level
  when 1..2
    methods = [
      :empty_room,
      :medicine_room,
      :cure_room,
    ]
  when 3..6
    methods = [
      :empty_room,
      :medicine_room,
      :cure_room,
      :fairy_room,
    ]
  when 7..9
    methods = [
      :empty_room_hard,
      :medicine_room_hard,
      :cure_room,
      :crow_room,
      :fairy_room,
    ]
  when 10..12
    methods = [
      :empty_room_hard,
      :medicine_room_hard,
      :crow_room,
      :sunflower_fairy_room,
    ]
  when 13..14
    methods = [
      :empty_room_hard,
      :medicine_room_hard,
      :crow_room,
      :crow_room,
      :crow_room,
      :sunflower_fairy_room,
    ]
  when 15
    methods = [
      :sunflower_fairy_room,
    ]
  end
  return methods
end


def empty_room(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = 'p' if rand > 0.98
      arena[x+walker.x, y+walker.y] = 'P' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'n' if rand > 0.95
      arena[x+walker.x, y+walker.y] = 'o' if rand > 0.96
    end
  end
end

def fairy_room(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = 'p' if rand > 0.98
      arena[x+walker.x, y+walker.y] = 'P' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'n' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'o' if rand > 0.96
      arena[x+walker.x, y+walker.y] = 'f' if rand > 0.96
    end
  end
end

def sunflower_fairy_room(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = 'p' if rand > 0.98
      arena[x+walker.x, y+walker.y] = 'P' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'n' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'O' if rand > 0.96
      arena[x+walker.x, y+walker.y] = 'F' if rand > 0.96
    end
  end
end

def empty_room_hard(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = 'p' if rand > 0.98
      arena[x+walker.x, y+walker.y] = 'P' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'n' if rand > 0.995
      arena[x+walker.x, y+walker.y] = 'O' if rand > 0.95
    end
  end
end


def crow_room(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = 'p' if rand > 0.95
      arena[x+walker.x, y+walker.y] = 'c' if rand > 0.9
    end
  end
end

def medicine_room(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = ',' if rand > 0.8 && arena[x+walker.x, y+walker.y] == '.'
      arena[x+walker.x, y+walker.y] = 'o' if rand > 0.99
      arena[x+walker.x, y+walker.y] = 'r' if rand > 0.98
    end
  end
end

def medicine_room_hard(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = ',' if rand > 0.8 && arena[x+walker.x, y+walker.y] == '.'
      arena[x+walker.x, y+walker.y] = 'o' if rand > 0.99
      arena[x+walker.x, y+walker.y] = 'r' if rand > 0.98
    end
  end
end

def cure_room(arena, walker, level)
  max = 10
  width = -rand(max)..rand(max)
  height = -rand(max)..rand(max)
  height.each do |y|
    width.each do |x|
      arena[x+walker.x, y+walker.y] = '.'
      arena[x+walker.x, y+walker.y] = ',' if rand > 0.8 && arena[x+walker.x, y+walker.y] == '.'
      arena[x+walker.x, y+walker.y] = 'n' if rand > 0.99
      arena[x+walker.x, y+walker.y] = 'P' if rand > 0.99
    end
  end
end




def create_level(level)
  complexity = 120 + level * 20
  arena = Arena.new
  #p level.class
  create_dungeon(arena,complexity,level)
  arena[0,0] = '<' unless level == 15
  
  if level == 15
    arena[0,0] = 'K'
  end
  
  return arena
end

def guarded_create_level(level)
 # p level.class
  arena = create_level(level)
  if arena.to_s.include? '>'
    return arena
  else
    guarded_create_level(level)
  end
end

=begin
for i in 1..15
  puts guarded_create_level(i)
  puts ""
end
=end


# Create an arena, and set of a walker in it.
#arena = Arena.new
#create_dungeon(arena, 400)

# Put in the up stairs.
#

# Show the dungeon.
#puts arena

