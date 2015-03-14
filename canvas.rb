# encoding: UTF-8
# a 2d array of strings
require_relative 'components'
require_relative 'helper'

class Canvas
  attr_accessor :data
  def initialize
    #datas are all glyphs
    clear
  end

  def clear
    @data = Array.new(CANVAS_WIDTH){Array.new(CANVAS_HEIGHT){VOID_GLYPH}}
  end
  
  def mash_text(text, x, y)
    text.lines.each_with_index do |l,y_offset|
      l.length.times do |t|
        next if l[t] == "\n"
        @data[t + x][y + y_offset] = Glyph.new(l[t],Gosu::Color::WHITE)
      end
    end
  end

  private
  def mash_map(map,camera_map,array_of_entities)
    fx, fy = *Camera.get_focus(array_of_entities.first)
    a = map.arraylized
    draw_range_x = (0...a.size).to_a - (0..(fx)).to_a
    draw_range_y = (0...a[0].size).to_a - (0..(fy)).to_a
    draw_range_x = draw_range_x.insert(0,draw_range_x[0]-1)
    draw_range_y = draw_range_y.insert(0,draw_range_y[0]-1)
    
    draw_range_x.each do |x|
      draw_range_y.each do |y|
        original_char = a[x][y]
        break if (x - fx) > CANVAS_WIDTH - 27
        break if (y - fy) > CANVAS_HEIGHT - 5

        if map.explored?(x,y) && !map.lit?(x,y)
          glyph = Glyph.new(original_char, Gosu::Color.new(140,255,255,255))
        elsif map.lit?(x,y)
           glyph = Glyph.new(original_char, Gosu::Color.new(255,255,255,255))
        end
        
        if map.explored?(x,y)
          glyph.invert = true if need_invert? original_char
          glyph.color = Gosu::Color::STAIR if [">","<"].include?(original_char)
          @data[x - fx][y - fy] = glyph 
        end
        
          #end
        
      end
    end
  end

  public
  def draw_horz_line(y,x0,x1,color=Gosu::Color::WHITE)
    CANVAS_WIDTH.times do |t|
      @data[t][y] = Glyph.new("━",color) if (x0..x1).to_a.include?(t)
    end
  end

  def draw_vert_line(x,y0,y1,color=Gosu::Color::WHITE)
    CANVAS_HEIGHT.times do |t|
      if (y0..y1).to_a.include?(t)
        if @data[x][t].char == "━"
          @data[x][t] = Glyph.new("╋",color)
        else
          @data[x][t] = Glyph.new("┃",color)
        end
      end

    end
  end

  def draw_gauge(x,y,length,v,vmax,rune,color=Gosu::Color::RED)

    rate = v / vmax.to_f
    whole_runes_cnt = (length * rate).round
    left_runes_cnt = length - whole_runes_cnt
    whole_runes_cnt.times do |t|
      @data[x + t][y] = Glyph.new(rune,color)
    end

    new_color = color.dup
    new_color.alpha = 120
    left_runes_cnt.times do |t|
      @data[x + whole_runes_cnt + t][y] = Glyph.new(rune,new_color)
    end
  end

  def draw_stairs_gauge(x,y,length,v,vmax,runes="▁▂▃▄▅▆▇█",color=Gosu::Color.new(255,0,128,255))
    unit = vmax / length.to_f
    wholes = (v / unit).floor
    wholes.times do |t|
      @data[x + t][y] = Glyph.new(runes.chars.to_a.last, color)
    end

    left = v - wholes * unit
    left_rate = left / unit.to_f
    
    return if left_rate == 0

    r = runes.chars.to_a[(runes.chars.to_a.length * left_rate).round]
    @data[x + wholes][y] = Glyph.new(r, color)
  end
  
  def draw_deck(x,y,decks,meter,runes="▁▂▃▄▅▆▇█",color=Gosu::Color::YELLOW)
    
    wholes = meter / 100
    wholes.times do |t|
      @data[x + t][y] = decks[t].glyph
    end

    left = meter - wholes * 100
    left_rate = left / 100.to_f
    
    return if left_rate == 0

    r = runes.chars[(runes.chars.length * left_rate).round]
    @data[x + wholes][y] = Glyph.new(r, color)
  end



  def draw_text(text,x,y,color=Gosu::Color::WHITE)
    text.chars.each_with_index do |c, i|
      @data[x + i][y] = Glyph.new(c, color)
    end
  end
  
  def draw_mid_text(text,x,endx,y,color=Gosu::Color::WHITE)
    l = text.length
    real_x = ((endx - x) - l)/2 + x
    draw_text(text,real_x,y,color)
  end
  


  def mash(map, array_of_entities)
    new_map = map.clone
    p = array_of_entities[0]
    new_map.raw = map.fit_for_the_camera(p)
    
    fx = Camera.get_focus(p)[0]
    fy = Camera.get_focus(p)[1]
    
    mash_map(map,new_map,array_of_entities)
    array_of_entities.sort_by{|e| e.bullet ? 1 : 0}.each do |e|
      if map.lit?(e.pos.x,e.pos.y)
        c = e.glyph.color
        m =  map.colormap
        if m[[e.pos.x+fx,e.pos.y+fy]]
          #c = [m[[e.pos.x+fx,e.pos.y+fy]], e.glyph.color].color_mean
        else
          dark_color = e.glyph.color.dup
          dark_color.alpha = 90
          c = dark_color
        end
        
        new_g = e.glyph.clone
        #new_g.color = c
        new_g.char = e.glyph.char
        
        if e.was_target
          new_g.invert = true
        end
        
        @data[e.pos.x - fx][e.pos.y - fy] = new_g
        e.discovered = true
      end
    end
  end


  def draw_minibuffer(minibuffer)
    c = [Gosu::Color::WHITE, Gosu::Color.new(180,255,255,255),Gosu::Color.new(120,255,255,255)]

    minibuffer.reverse.take(3).each_with_index do |b,i|
      draw_text(b,1,CANVAS_HEIGHT - 4 + i,c[i])
    end
  end
end
