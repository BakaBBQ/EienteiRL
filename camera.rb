class Camera ; end

class << Camera
  def get_focus(entity) #an array of [x,y]
    x = entity.pos.x - width / 2
    y = entity.pos.y - height / 2
    x = 0 if x < 0
    y = 0 if y < 0
    return [x,y]
  end
  
  def get_rect(entity)
    f = get_focus(entity)
    return [f[0],f[1],f[0]+width,f[1]+height]
  end
  
  def width
    CANVAS_WIDTH - 26
  end
  
  def height
    CANVAS_HEIGHT - 6
  end
  
  alias w width
  alias h height
end
