# a 2d array of strings
require_relative 'components'
class Canvas
  attr_accessor :data
  def initialize
    #datas are all glyphs
    clear
  end

  def clear
    @data = Array.new(CANVAS_WIDTH){Array.new(CANVAS_HEIGHT){VOID_GLYPH}}
  end

  private
  def mash_map(map)
    map.lines.each_with_index do |l,y|
      l.length.times do |t|
        @data[t][y] = Glyph.new(l[t],Gosu::Color.argb(0xff606060)) if map.explored?(t,y)
        @data[t][y] = Glyph.new(l[t],Gosu::Color::WHITE) if map.lit?(t,y)
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
      @data[x + t][y] = Glyph.new(runes.chars.last, color)
    end

    left = v - wholes * unit
    left_rate = left / unit.to_f

    r = runes.chars[(runes.chars.length * left_rate).round]
    @data[x + wholes][y] = Glyph.new(r, color)
  end



  def draw_text(text,x,y,color=Gosu::Color::WHITE)
    text.chars.each_with_index do |c, i|
      @data[x + i][y] = Glyph.new(c, color)
    end
  end


  def mash(map, array_of_entities)
    mash_map(map)
    array_of_entities.each do |e|
      @data[e.pos.x][e.pos.y] = e.glyph if map.lit?(e.pos.x,e.pos.y)
    end
  end


  def draw_minibuffer(minibuffer)
    c = [Gosu::Color::WHITE, Gosu::Color.new(180,255,255,255),Gosu::Color.new(120,255,255,255)]

    minibuffer.reverse.take(3).each_with_index do |b,i|
      draw_text(b,1,CANVAS_HEIGHT - 4 + i,c[i])
    end
  end
end
