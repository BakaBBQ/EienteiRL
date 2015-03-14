class Title ; end


  @timer = 0
  def refresh_title canvas
    canvas.clear
    canvas.draw_horz_line(CANVAS_HEIGHT - 6, 0,CANVAS_WIDTH - 1)
    canvas.draw_mid_text("EienteiRL",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 4)
    canvas.draw_mid_text(slurp("VERSION"),0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 3,Gosu::Color.new(140,255,255,255))
    canvas.draw_mid_text("Press Z to Confirm Selection",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 2,Gosu::Color.new(130,186,225))
    canvas.draw_horz_line(CANVAS_HEIGHT - 1, 0,CANVAS_WIDTH - 1)
    
    
    canvas.draw_text("Choose a Class",1,2)
    
    choices.each_with_index do |c,i|
      if @cursor == i
        color = Gosu::Color::YELLOW
      else
        color = Gosu::Color.new(140,255,255,255)
      end
      
      prefix = (@cursor == i) ? "-> " : ""
      
      canvas.draw_text(prefix + proper_names[c],1, 4 + i,color)
    end
    
    canvas.draw_vert_line(20, 0,CANVAS_HEIGHT - 7)
    
    canvas.mash_text(@descriptions[@cursor], 22, 1)
    if button_down?(DIRECTION2NUMPAD[2]) || button_down?(char_to_button_id(DIRECTION2VI[2])) 
      @cursor = [@cursor + 1, choices.length - 1].min
    end

    if button_down?(DIRECTION2NUMPAD[8]) || button_down?(char_to_button_id(DIRECTION2VI[8])) 
      @cursor = [@cursor - 1, 0].max
    end
    
    if button_down?(char_to_button_id('z')) 
      $game.set_up_actor_clazz choices[@cursor]
      $game.state = :game
    end
  end


  def do_title(canvas)
    @timer ||= 0
    @cursor ||= 0
    @youkai ||= false
    @timer += 1
    @descriptions ||= choices.collect{|c| get_contents_for c}
    refresh_title canvas
  end
  
  def get_contents_for clazz
    slurp "presets/#{clazz}_desc.txt"
  end
  
  
  def choices
    [
      :gardener,
      :time_maid,
      :magician,
      :doll_manipulator,
    ]
  end
  
  def proper_names
    {
      :gardener => "Gardener",
      :time_maid => "Time Maid",
      :magician => "Magician",
      :doll_manipulator => "Doll Controller"
    }
  end
  
  
  
  
