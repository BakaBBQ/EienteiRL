require 'gosu'

require_relative 'canvas'
require_relative 'factory'
require_relative 'helper'
require_relative 'map'
require_relative 'components'
require_relative 'logic'
require_relative 'camera'
require_relative 'bullet'
require 'ruby-prof'
require_relative 'gen'

require_relative 'title'

CANVAS_WIDTH = 75
CANVAS_HEIGHT = 32

FONT_HEIGHT = 20
FONT_WIDTH = 11

INPUT_WAIT = 0

TITLE = "EienteiRL"

$wait_for_player_to_make_up_decision = false

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
  def initialize
    super FONT_WIDTH * CANVAS_WIDTH, FONT_HEIGHT * CANVAS_HEIGHT, false, 50
    self.caption = TITLE

    @font = Gosu::Font.new(self, "fonts/DejaVuSansMono.ttf", FONT_HEIGHT)

    @canvas = Canvas.new
    

    @minibuffer = []
    
    @unnamed_fun = FunFloor.new
    #@map_raw = @unnamed_fun.to_s#slurp("presets/test.txt")
    @map_raw = slurp("presets/test.txt")
    @map = Map.new(@map_raw,@unnamed_fun.nodes)

    #@actor = Factory.create_actor(*@unnamed_fun.start)
    @actor = Factory.create_actor(3,3)
    #r = 
    #b = Factory.bullet(15,3,1,1)
    @entities = [@actor,Factory.rabbit(3,5),Factory.create_power_item(3,4),Factory.create_night_item(4,3),Factory.create_point_item(2,2)]
    #binding.pry
    @input_timer = 0
    
    @time = Time.new(1969,9,12,2,0,0)
    
    @state = :title
    
    #do_turn
  end

  
  def update
    case @state
    when :title
      do_title(@canvas)
    when :game
      do_turn
    end
    
    
    self.caption = "#{TITLE} - fps: #{Gosu.fps}"
  end



  def do_turn
    @time = turn(@time,@entities,@map,@canvas,@minibuffer)
  end

  def draw
    @canvas.data.each_with_index do |fv, cx|
      fv.compact.each_with_index do |glyph, cy|
        #p glyph.item
        if glyph.invert
          draw_rect(cx * FONT_WIDTH, cy * FONT_HEIGHT, FONT_WIDTH, FONT_HEIGHT, glyph.color)
          @font.draw(glyph.char, cx * FONT_WIDTH, cy * FONT_HEIGHT, 0, 1.0, 1.0, Gosu::Color::BLACK)
        elsif glyph.item
          draw_rect(cx * FONT_WIDTH, cy * FONT_HEIGHT + 7, FONT_WIDTH, FONT_HEIGHT - 7, glyph.color)
          @font.draw(glyph.char, cx * FONT_WIDTH, cy * FONT_HEIGHT, 0, 1.0, 1.0, Gosu::Color::WHITE)
        else
          @font.draw(glyph.char, cx * FONT_WIDTH, cy * FONT_HEIGHT, 0, 1.0, 1.0, glyph.color)
        end
        
      end
    end
  end
  
end


window = GameWindow.new
window.show
