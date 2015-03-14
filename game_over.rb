def game_over(canvas)
  canvas.clear
  canvas.draw_horz_line(CANVAS_HEIGHT - 6, 0,CANVAS_WIDTH - 1)
  canvas.draw_mid_text("Game Over",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 4)
  canvas.draw_mid_text("Press Z for Restart",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 3,Gosu::Color.new(140,255,255,255))
  canvas.draw_horz_line(CANVAS_HEIGHT - 1, 0,CANVAS_WIDTH - 1)
  if button_down?(char_to_button_id("z"))
    $game.restart
  end
end
