class Title ; end


  @timer = 0
  def refresh_title canvas
    canvas.clear
    canvas.draw_horz_line(CANVAS_HEIGHT - 6, 0,CANVAS_WIDTH - 1)
    canvas.draw_mid_text("EienteiRL",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 4)
    canvas.draw_mid_text(slurp("VERSION"),0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 3,Gosu::Color.new(140,255,255,255))
    canvas.draw_horz_line(CANVAS_HEIGHT - 1, 0,CANVAS_WIDTH - 1)
    
    #canvas.draw_vert_line(CANVAS_WIDTH / 3, 0, CANVAS_HEIGHT - 7)
    
    canvas.draw_mid_text("m - music room; q - quit",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 7,Gosu::Color.new((@timer % 50 - 25).abs * 2 + 155,255,255,0))
    race_text = @youkai ? "h - choose race as human" : "y - choose race as youkai"
    canvas.draw_mid_text(race_text + "; up/down - choose class",0,CANVAS_WIDTH - 1, CANVAS_HEIGHT - 8,Gosu::Color.new(((@timer + 25) % 50 - 25).abs * 2 + 155,140,255,0))
    canvas.draw_horz_line(CANVAS_HEIGHT - 9, 0,CANVAS_WIDTH - 1)
    
    canvas.draw_mid_text("Choose a Class",0,CANVAS_WIDTH - 1, 2)
    
    choices.each_with_index do |c,i|
      if @cursor == i
        color = Gosu::Color::YELLOW
      else
        color = Gosu::Color.new(140,255,255,255)
      end
      
      prefix = (@cursor == i) ? "-> " : ""
      
      canvas.draw_mid_text(prefix + proper_names[c],0,CANVAS_WIDTH - 1, 4 + i,color)
    end
    
    if button_down?(char_to_button_id('s'))
      @cursor = [@cursor + 1, choices.length - 1].min
    end

    if button_down?(char_to_button_id('w'))
      @cursor = [@cursor - 1, 0].max
    end
    
  end


  def do_title(canvas)
    @timer ||= 0
    @cursor ||= 0
    @youkai ||= false
    @timer += 1
    refresh_title canvas
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
  
  
  
