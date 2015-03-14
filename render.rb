# encoding: UTF-8
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
    
    canvas.draw_text("np:#{actor.np}%",CANVAS_WIDTH - 23, PLAYER_STATS_START + 4)
    canvas.draw_stairs_gauge(CANVAS_WIDTH - 12, PLAYER_STATS_START + 4, 10, actor.np, 100, "▁▂▃▄▅▆▇█",Gosu::Color.new(150,27,114))
    
    canvas.draw_mid_text("#{fmt_time(time)}",CANVAS_WIDTH - 23,CANVAS_WIDTH - 1,CANVAS_HEIGHT - 3)
    canvas.draw_mid_text("Fl: #{$game.current_level}",CANVAS_WIDTH - 23,CANVAS_WIDTH - 1,CANVAS_HEIGHT - 2,Gosu::Color.new(255,180,180,255))
    
    canvas.draw_horz_line(12, CANVAS_WIDTH - 24, CANVAS_WIDTH - 1)
    
    canvas.draw_horz_line(18, CANVAS_WIDTH - 24, CANVAS_WIDTH - 1)
    
    entities[1..(entities.length - 1)].select{|e| e.name && map.lit?(e.pos.x,e.pos.y)}.take(5).each_with_index do |seen_e, i|
      e = seen_e
      canvas.draw_text(seen_e.glyph.char,CANVAS_WIDTH - 23,13 + i, seen_e.glyph.color)
      canvas.draw_text("- " + seen_e.name.chars.take(11).join,CANVAS_WIDTH - 20,13 + i)
      canvas.draw_stairs_gauge(CANVAS_WIDTH - 6, 13 + i, 3, e.hp, e.mhp,"▁▂▃▄▅▆▇█",Gosu::Color.new(255,233,196,176))
    end
    
    
    shot = actor.shot
    shot_name = actor.shot.get_name
    canvas.draw_text('f',CANVAS_WIDTH - 23,19,Gosu::Color.new(20,152,228))
    canvas.draw_text("#{shot_name.chars.take(18).join} #{shot.level}",CANVAS_WIDTH - 21,19)
    ['q','w','e','r','t'].each_with_index do |key, i|
      next if actor.skills[i].nil?
      skill = actor.skills[i]
      canvas.draw_text(key,CANVAS_WIDTH - 23,20 + i,Gosu::Color::YELLOW)
      canvas.draw_text("#{skill.get_name.chars.take(18).join} #{skill.level}",CANVAS_WIDTH - 21,20 + i)
    end
    
    canvas.draw_deck(CANVAS_WIDTH - 22,CANVAS_HEIGHT - 7,actor.deck - actor.hand,(actor.deck).size * 100)
    

    canvas.draw_deck(CANVAS_WIDTH - 22,CANVAS_HEIGHT - 6,actor.hand,actor.hand.size * 100)

    canvas.draw_horz_line(CANVAS_HEIGHT - 8, CANVAS_WIDTH - 24, CANVAS_WIDTH - 1)
    canvas.draw_minibuffer(minibuffer)
  end
end
