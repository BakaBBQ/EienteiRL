def movable_in_map?(map,x,y)
  !(['#'].include?(map.lines[y][x]))
end

def movable_in_entity?(entities,x,y)
  entities[1..(entities.length-1)].select{|e| e.pos.x == x}.select{|e| e.pos.y == y}.empty?
end


def slurp file_name
  return File.open(file_name, "rb").read
end


def pop_msg(minibuffer,msg)
  minibuffer << msg
end
