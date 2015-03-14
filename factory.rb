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
      a.hp = 25
      a.mhp = 25
      a.mp = 45
      a.mmp = 50
      a.turns = 0
      a.speed = 10
      
      a.np = 50
      
      a.energy = 0
      
      a.score = 0
      a.player = true
      a.mind = :player
      
      a.skills = [Skill.new(0,:changeling_magic),Skill.new(0,:close_up_magic),Skill.new(0,:vanish_everything)]
      a.shot = Skill.new(0,:mysterious_jack)
      
      a.meter = 1000
      a.deck = []
      a.hand = []
      
      10.times do |t|
        a.deck << Card.new(Glyph.new("S",Gosu::Color.new(255,255,229,180)),:vanish_everything)
      end
      
      
      a.mp_recover = 0
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
      o.dice = lambda{rand(1) + 2}
    end
    return rabbit
  end
  
  def crow(x,y)
    crow = OpenStruct.new
    crow.tap do |o|
      o.glyph = Glyph.new("c", Gosu::Color.new(154,252,255))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Crow"
      o.mhp = gen_mhp(8,4)
      o.hp = o.mhp
      o.mind = :silly
      
      o.alertness = 5
      o.energy = 0
      o.speed = 7
      o.dice = lambda{rand(3) + 2}
    end
    return crow
  end
  
  def small_fairy(x,y)
    fairy = OpenStruct.new
    fairy.tap do |o|
      o.glyph = Glyph.new("f", Gosu::Color.new(255,10,10,220))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Small Fairy"
      o.mhp = gen_mhp(8,4)
      o.hp = o.mhp
      o.mind = :fairy
      
      o.alertness = 5
      o.energy = 0
      o.speed = 10
      
      o.drop = :power
    end
    return fairy
  end
  
  def kaguya(x,y)
    kaguya = OpenStruct.new
    kaguya.tap do |o|
      o.glyph = Glyph.new("K", Gosu::Color.new(159,50,83))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Kaguya"
      o.mhp = gen_mhp(50,0)
      o.hp = o.mhp
      o.mind = :kaguya
      
      o.alertness = 5
      o.energy = 0
      o.speed = 5
    end
    return kaguya
  end
  
  def sunflower_fairy(x,y)
    fairy = OpenStruct.new
    fairy.tap do |o|
      o.glyph = Glyph.new("F", Gosu::Color.new(255,255,215,0))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Sunflower Fairy"
      o.mhp = gen_mhp(14,4)
      o.hp = o.mhp
      o.mind = :sunflower_fairy
      
      o.alertness = 5
      o.energy = 0
      o.speed = 10
      
      o.drop = :power
    end
    return fairy
  end
  
  def kedama(x,y)
    kedama = OpenStruct.new
    kedama.tap do |o|
      o.glyph = Glyph.new("o", Gosu::Color.new(255,100,149,237))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Kedama"
      o.mhp = gen_mhp(1,0)
      o.hp = o.mhp
      o.mind = :kedama
      
      o.alertness = 5
      o.energy = 0
      o.speed = 4
      
      o.drop = :point
    end
    return kedama
  end
  
  def red_kedama(x,y)
    kedama = OpenStruct.new
    kedama.tap do |o|
      o.glyph = Glyph.new("O", Gosu::Color.new(255,255,105,180))
      o.pos = Pos.new(x,y)
      o.velocity = Velocity.new(0,0)
      o.name = "Red Kedama"
      o.mhp = gen_mhp(3,2)
      o.hp = o.mhp
      o.mind = :red_kedama
      
      o.alertness = 5
      o.energy = 0
      o.speed = 4
      
      o.drop = :power
    end
    return kedama
  end
  
  def bullet(x,y,sx,sy,damage,char="*",color=Gosu::Color::YELLOW)
    bullet = OpenStruct.new
    bullet.tap do |o|
      o.glyph = Glyph.new(char,color)
      o.pos = Pos.new(x,y)
      o.rpos = Pos.new(x * 10, y * 10)
      o.rvel = Velocity.new(sx * 10, sy * 10)
      o.speed = 8
      o.energy = 0
      o.bullet = true
      o.damage = damage
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
      p.item = true
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
      p.item = true
      p.power = 1
      p.heal = 0.1
    end
    return point_item
  end
  
  def create_card_item(x,y)
    point_item = OpenStruct.new
    point_item.tap do |p|
      g = Glyph.new("c",Gosu::Color.new(206,15,155))
      g.item = true
      p.glyph = g
      p.pos = Pos.new(x,y)
      p.item = true
      p.card = true
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
      p.item = true
      p.power = 1
    end
    return point_item
  end
  
  def create_doll_spinner x,y
    spinner = OpenStruct.new
    spinner.tap do |s|
      s.glyph = Glyph.new("s", Gosu::Color::YELLOW)
      s.pos = Pos.new x,y
      s.hp = 5
      s.mhp = 5
      s.doll = true
      s.mind = :spinner
      s.energy = 0
      s.speed = 4
    end
    return spinner
  end
  
  def create_edo_doll x,y
    doll = OpenStruct.new
    doll.tap do |s|
      s.glyph = Glyph.new("e", Gosu::Color.new(255,140,140,255))
      s.pos = Pos.new x,y
      s.hp = 1
      s.mhp = 1
      s.doll = true
      s.mind = :edo
      s.energy = 0
      s.speed = 14
    end
    return doll
  end
  
  def create_bullet_absorber x,y
    doll = OpenStruct.new
    doll.tap do |s|
      s.glyph = Glyph.new("a", Gosu::Color.new(74,164,62))
      s.pos = Pos.new x,y
      s.hp = 1
      s.mhp = 1
      s.doll = false
      s.mind = :bullet_absorber
      s.energy = 0
      s.speed = 4
    end
    return doll
  end
  
  def create_ambush_doll x,y
    doll = OpenStruct.new
    doll.tap do |s|
      s.glyph = Glyph.new("a", Gosu::Color.new(255,200,200,140))
      s.pos = Pos.new x,y
      s.hp = 1
      s.mhp = 1
      s.doll = true
      s.mind = :ambush
      s.energy = 0
      s.speed = 10
    end
    return doll
  end
  
  def create_servant_doll x,y
    doll = OpenStruct.new
    doll.tap do |s|
      s.glyph = Glyph.new("s", Gosu::Color.new(255,240,200,10))
      s.pos = Pos.new x,y
      s.hp = 10
      s.mhp = 10
      s.doll = true
      s.mind = :servant
      s.energy = 0
      s.speed = 15
    end
    return doll
  end

  
  
  
end
