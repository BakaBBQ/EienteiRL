class Render ; end

require "benchmark"
require_relative 'helper'

PLAYER_STATS_START = 6
class << Render
  def process(time,entities, map, canvas,minibuffer)
    sx = entities[0].pos.x
    sy = entities[0].pos.y
    
    canvas.clear
    canvas.mash(map,entities)

    actor = entities[0]

    map.lightmap = {}
    
    map.do_fov(sx,sy,15)
    map.colorize_lights

    canvas.draw_horz_line(CANVAS_HEIGHT - 5, 0, CANVAS_WIDTH)
    canvas.draw_vert_line(CANVAS_WIDTH - 25, 0, CANVAS_HEIGHT)
    
    canvas.draw_horz_line(4, CANVAS_WIDTH - 24, CANVAS_WIDTH - 1)
    
    canvas.draw_mid_text("Score",CANVAS_WIDTH - 23,CANVAS_WIDTH - 1,1)
    canvas.draw_mid_text("%011d" % actor.score,CANVAS_WIDTH - 23,CANVAS_WIDTH - 1,2)
    
    canvas.draw_text(actor.name,CANVAS_WIDTH - 23, PLAYER_STATS_START, Gosu::Color::AQUA)
    canvas.draw_text("-",CANVAS_WIDTH - 23 + actor.name.length + 1, PLAYER_STATS_START)
    canvas.draw_text(actor.clazz.capitalize,CANVAS_WIDTH - 23 + actor.name.length + 3, PLAYER_STATS_START, Gosu::Color.new(255,233,196,176))

    canvas.draw_text("hp:#{actor.hp}/#{actor.mhp}",CANVAS_WIDTH - 23, PLAYER_STATS_START + 2)
    canvas.draw_gauge(CANVAS_WIDTH - 12, PLAYER_STATS_START + 2, 10, actor.hp, actor.mhp, "█", Gosu::Color.new(255,138,7,7))

    canvas.draw_text("mp:#{actor.mp}/#{actor.mmp}",CANVAS_WIDTH - 23, PLAYER_STATS_START + 3)
    canvas.draw_stairs_gauge(CANVAS_WIDTH - 12, PLAYER_STATS_START + 3, 10, actor.mp, actor.mmp)
    canvas.draw_mid_text("#{fmt_time(time)}",CANVAS_WIDTH - 23,CANVAS_WIDTH - 1,CANVAS_HEIGHT - 3)

    canvas.draw_minibuffer(minibuffer)
  end
end
