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
      a.class = "Gardener"
      a.hp = 15
      a.mhp = 15
      a.mp = 45
      a.mmp = 50
      a.turns = 0
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
    end
    return rabbit
  end
end
