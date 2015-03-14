require 'gosu'
#require 'toml'
#require 'pry'

require_relative 'canvas'
require_relative 'factory'
require_relative 'helper'
require_relative 'map'
require_relative 'components'
require_relative 'logic'
require_relative 'camera'
require_relative 'bullet'
require_relative 'game_over'
#require 'ruby-prof'

require_relative 'gen/dungeon'
require_relative 'title'

CANVAS_WIDTH = 75
CANVAS_HEIGHT = 32

FONT_HEIGHT = 20
FONT_WIDTH = 11

INPUT_WAIT = 0

TITLE = "EienteiRL"


$wait_for_player_to_make_up_decision = false


DIRECTION2NUMPAD = {
  0 => 98,
  1 => 89,
  2 => 90,
  3 => 91,
  4 => 92,
  5 => 93,
  6 => 94,
  7 => 95,
  8 => 96,
  9 => 97,
}

DIRECTION2VI = {
  1 => 'b',
  2 => 'j',
  3 => 'n',
  4 => 'h',
  5 => '+',
  6 => 'l',
  7 => 'y',
  8 => 'k',
  9 => 'u',
}

class Gosu::Color
  STAIR = Gosu::Color.new(255,180,255,10)
end


def waiting_for_player_deide?
  return $wait_for_player_to_make_up_decision
end

def wait_for_player_to_decide
  $wait_for_player_to_make_up_decision = true
end

def player_decided
  $wait_for_player_to_make_up_decision = false
end

class GameWindow < Gosu::Window
  attr_accessor :current_level
  attr_accessor :state
  def initialize
    super FONT_WIDTH * CANVAS_WIDTH, FONT_HEIGHT * CANVAS_HEIGHT, false, 50
    self.caption = TITLE
    restart
    #do_turn
  end
  
  def restart
    @font = Gosu::Font.new(self, "fonts/DejaVuSansMono.ttf", FONT_HEIGHT)

    @canvas = Canvas.new
    
    @current_level = 1

    @minibuffer = []
    
    arena = guarded_create_level(1)
    
    @map_raw = arena.to_s
    @map = Map.new(@map_raw)
    
    start_x, start_y = @map.find_start

    @actor = Factory.create_actor(start_x, start_y)

    @entities = [@actor]
    @map.bind_entities(@entities)
    @input_timer = 0
    
    @time = Time.new(1969,9,12,2,0,0)
    
    @state = :title
  end
  
  
  def set_up_actor_clazz clazz
    a = @entities[0]
    case clazz
    when :gardener
      a.mhp = 28
      a.hp = a.mhp
      a.mmp = 30
      a.mp = a.mmp
      a.shot = Skill.new(0,:six_realms)
      a.skills = [Skill.new(0,:flower_slash),Skill.new(0,:phosphorus_slash)]
      a.clazz="Gardener"
      a.speed = 6
    when :time_maid
      a.mhp = 25
      a.hp = a.mhp
      a.mmp = 40
      a.mp = a.mmp
      a.shot = Skill.new(0,:mysterious_jack)
      a.skills = [Skill.new(0,:close_up_magic),Skill.new(0,:vanish_everything)]
      a.speed = 8
      a.clazz="Time Maid"
    when :magician
      a.mhp = 15
      a.hp = a.mhp
      a.mmp = 50
      a.mp = a.mmp
      a.shot = Skill.new(0,:stardust_missle)
      a.skills = [Skill.new(0,:bullet_absorb),Skill.new(0,:magic_dust)]
      a.speed = 9
      a.clazz="Magician"
    when :doll_manipulator
      a.mhp = 25
      a.hp = a.mhp
      a.mmp = 30
      a.mp = a.mmp
      a.shot = Skill.new(0,:doll_placement)
      a.skills = [Skill.new(0,:ambush),Skill.new(0,:edo)]
      a.speed = 8
      a.clazz="Doll Magician"
    end
    
    profile = eval(slurp("presets/profile.rb"))
    cards = profile[clazz]
    a.name = profile[:name]
    a.deck = cards.collect{|c| Card.new(Glyph.new(c.to_s.chars.to_a.first.capitalize,Gosu::Color.new(255,255,229,180)),c)}
  end
  
  def ascend_to_new_level
    actor = @entities[0]
    @current_level += 1
    arena = guarded_create_level(@current_level)
    
    @map_raw = arena.to_s
    @map = Map.new(@map_raw)
    
    start_x, start_y = @map.find_start
    
    actor.pos.x = start_x
    actor.pos.y = start_y
    
    @entities = [actor]
    @map.bind_entities(@entities)
  end
  

  
  def update
    case @state
    when :title
      do_title(@canvas)
    when :game
      do_turn
    when :game_over
      game_over(@canvas)
    end
    
    
    self.caption = "#{TITLE} - fps: #{Gosu.fps}"
  end
  
  def get_level skill_name
    if @entities[0].shot.code == skill_name
      return @entities[0].shot.level
    end
    
    @entities[0].skills.each do |s|
      if s.code == skill_name
        return s.level
      end
    end
  end
  
  

  def do_turn
    @time = turn(@time,@entities,@map,@canvas,@minibuffer)
  end

  def draw
    w = @canvas.data.size
    h = @canvas.data[0].size
    
    w.times do |x|
      h.times do |y|
        glyph = @canvas.data[x][y]
        if glyph.invert
          draw_rect(x * FONT_WIDTH, y * FONT_HEIGHT, FONT_WIDTH, FONT_HEIGHT, glyph.color)
          @font.draw(glyph.char, x * FONT_WIDTH, y * FONT_HEIGHT, 0, 1.0, 1.0, Gosu::Color::BLACK)
        elsif glyph.item
          draw_rect(x * FONT_WIDTH, y * FONT_HEIGHT + 7, FONT_WIDTH, FONT_HEIGHT - 7, glyph.color)
          @font.draw(glyph.char, x * FONT_WIDTH, y * FONT_HEIGHT, 0, 1.0, 1.0, Gosu::Color::WHITE)
        else
          @font.draw(glyph.char, x * FONT_WIDTH, y * FONT_HEIGHT, 0, 1.0, 1.0, glyph.color)
        end
      end
    end
  end
  
  def player
    return @entities.first
  end
  
  
end


$game = GameWindow.new
$game.show
