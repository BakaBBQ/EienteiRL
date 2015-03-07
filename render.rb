class Render ; end


require_relative 'helper'
class << Render
  def process(entities, map, canvas,minibuffer)
    sx = entities[0].pos.x
    sy = entities[0].pos.y

    actor = entities[0]

    map.lightmap = {}
    map.do_fov(sx,sy,14)

    canvas.clear
    canvas.mash(map,entities)

    canvas.draw_horz_line(CANVAS_HEIGHT - 5, 0, CANVAS_WIDTH)
    canvas.draw_vert_line(CANVAS_WIDTH - 25, 0, CANVAS_HEIGHT)

    canvas.draw_text(actor.name,CANVAS_WIDTH - 23, 1, Gosu::Color::AQUA)

    canvas.draw_text("hp:#{actor.hp}/#{actor.mhp}",CANVAS_WIDTH - 23, 3)
    canvas.draw_gauge(CANVAS_WIDTH - 12, 3, 10, actor.hp, actor.mhp, "#")

    canvas.draw_text("mp:#{actor.mp}/#{actor.mmp}",CANVAS_WIDTH - 23, 4)
    canvas.draw_stairs_gauge(CANVAS_WIDTH - 12, 4, 5, actor.mp, actor.mmp)

    canvas.draw_text("turns:#{actor.turns}",CANVAS_WIDTH - 23, 6)

    canvas.draw_minibuffer(minibuffer)
  end
end
