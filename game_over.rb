def game_over(canvas)
  canvas.clear
  canvas.draw_horz_line(CANVAS_HEIGHT - 6, 0,CANVAS_WIDTH - 1)
  canvas.draw_mid_text("Game Over",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 4)
  
  canvas.draw_mid_text("You failed to find out the true culpit.",0,CANVAS_WIDTH - 1, 3)
  canvas.draw_mid_text("Score: #{$game.player.score}",0,CANVAS_WIDTH - 1, 4,Gosu::Color.new(140,255,255,255))
  canvas.draw_mid_text("Press Z for Restart",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 3,Gosu::Color.new(140,255,255,255))
  canvas.draw_horz_line(CANVAS_HEIGHT - 1, 0,CANVAS_WIDTH - 1)
  if button_down?(char_to_button_id("z"))
    $game.restart
  end
end

def game_win(canvas)
  canvas.clear
  canvas.draw_horz_line(CANVAS_HEIGHT - 6, 0,CANVAS_WIDTH - 1)
  canvas.draw_mid_text("You Win",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 4)
  
  canvas.draw_mid_text("You defeated Kaguya.",0,CANVAS_WIDTH - 1, 3)
  canvas.draw_mid_text("Score: #{$game.player.score}",0,CANVAS_WIDTH - 1, 4,Gosu::Color.new(140,255,255,255))
  canvas.draw_mid_text("Press Z for Restart",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 3,Gosu::Color.new(140,255,255,255))
  canvas.draw_horz_line(CANVAS_HEIGHT - 1, 0,CANVAS_WIDTH - 1)
  if button_down?(char_to_button_id("z"))
    $game.restart
  end
end

def deck_error(canvas)
  canvas.clear
  canvas.draw_horz_line(CANVAS_HEIGHT - 6, 0,CANVAS_WIDTH - 1)
  canvas.draw_mid_text("Deck Error",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 4)
  

  canvas.draw_mid_text("Your deck either has no proper length, or is not in proper format",0,CANVAS_WIDTH - 1, 4,Gosu::Color.new(140,255,255,255))
  canvas.draw_mid_text("Press Z for Restart",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 3,Gosu::Color.new(140,255,255,255))
  canvas.draw_horz_line(CANVAS_HEIGHT - 1, 0,CANVAS_WIDTH - 1)
  if button_down?(char_to_button_id("z"))
    $game.restart
  end
end

