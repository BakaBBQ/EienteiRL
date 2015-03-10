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

CANVAS_WIDTH = 75
CANVAS_HEIGHT = 32

FONT_HEIGHT = 20
FONT_WIDTH = 11

INPUT_WAIT = 2

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

    @map_raw = slurp("presets/test.txt")
    @map = Map.new(@map_raw)

    @minibuffer = []

    @actor = Factory.create_actor(3,3)
    r = Factory.rabbit(3,4)
    b = Factory.bullet(15,3,1,1)
    @entities = [@actor,r,b]

    @input_timer = 0
    
    @time = Time.new(1969,9,12,2,0,0)

    do_turn
  end

  
  def update
    do_turn
    self.caption = "#{TITLE} - fps: #{Gosu.fps}"
  end



  def do_turn
    @time = turn(@time,@entities,@map,@canvas,@minibuffer)
  end

  def draw
    @canvas.data.each_with_index do |fv, cx|
      fv.compact.each_with_index do |glyph, cy|
        if glyph.invert
          draw_rect(cx * FONT_WIDTH, cy * FONT_HEIGHT, FONT_WIDTH, FONT_HEIGHT, glyph.color)
          @font.draw(glyph.char, cx * FONT_WIDTH, cy * FONT_HEIGHT, 0, 1.0, 1.0, Gosu::Color::BLACK)
        else
          @font.draw(glyph.char, cx * FONT_WIDTH, cy * FONT_HEIGHT, 0, 1.0, 1.0, glyph.color)
        end
        
      end
    end
  end
  
end


window = GameWindow.new
window.show
