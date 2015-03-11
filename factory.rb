require_relative 'components'
require_relative 'entity'


class Factory ; end

module GenHelper
  def gen_mhp(base,variance)
    a = base - variance / 2
    return a + rand(variance)
  end
end


class << Factory
  include GenHelper
  def create_actor(x,y)
    actor = OpenStruct.new
    actor.glyph = Glyph.new("@",Gosu::Color::YELLOW)
    actor.pos = Pos.new(x,y)
    actor.velocity = Velocity.new(0,0)
    actor.tap do |a|
      a.name = "LBQ"
      a.clazz = "gardener"
      a.race = "human"
      a.hp = 15
      a.mhp = 15
      a.mp = 45
      a.mmp = 50
      a.turns = 0
      a.speed = 10
      
      a.energy = 0
      
      a.score = 0
      a.player = true
      a.mind = :player
    end
    return actor
  end

  def rabbit(x,y)
    rabbit = OpenStruct.new
    rabbit.tap do |o|
      o.glyph = Glyph.new("r", Gosu::Color.new(254,252,255))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Rabbit"
      o.mhp = gen_mhp(8,4)
      o.hp = o.mhp
      o.mind = :silly
      
      o.alertness = 5
      o.energy = 0
      o.speed = 12
    end
    return rabbit
  end
  
  def bullet(x,y,sx,sy,char="*",color=Gosu::Color::YELLOW)
    bullet = OpenStruct.new
    bullet.tap do |o|
      o.glyph = Glyph.new(char,color)
      o.pos = Pos.new(x,y)
      o.rpos = Pos.new(x * 10, y * 10)
      o.rvel = Velocity.new(sx * 10, sy * 10)
      o.speed = 8
      o.energy = 0
    end
    return bullet
  end
  
  def create_point_item(x,y)
    point_item = OpenStruct.new
    point_item.tap do |p|
      g = Glyph.new("p",Gosu::Color::BLUE)
      g.item = true
      p.glyph = g
      p.pos = Pos.new(x,y)
      
      p.point = 200
    end
    return point_item
  end
  
  def create_power_item(x,y)
    point_item = OpenStruct.new
    point_item.tap do |p|
      g = Glyph.new("p",Gosu::Color::RED)
      g.item = true
      p.glyph = g
      p.pos = Pos.new(x,y)
      
      p.power = 1
    end
    return point_item
  end
  
  def create_night_item(x,y)
    point_item = OpenStruct.new
    point_item.tap do |p|
      g = Glyph.new("n",Gosu::Color::FUCHSIA)
      g.item = true
      p.glyph = g
      p.pos = Pos.new(x,y)
      
      p.power = 1
    end
    return point_item
  end
  
end
