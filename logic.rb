require_relative 'movement'
require_relative 'render'
def turn(entities, map, canvas,minibuffer)
  entities.first.turns += 1
  Movement.process(entities,map,canvas,minibuffer)
  Render.process(entities,map,canvas,minibuffer)
end
