require 'gosu'

require_relative 'canvas'
require_relative 'factory'
require_relative 'helper'
require_relative 'map'
require_relative 'components'
require_relative 'logic'

CANVAS_WIDTH = 65
CANVAS_HEIGHT = 32

FONT_HEIGHT = 20
FONT_WIDTH = 14

class GameWindow < Gosu::Window
  def initialize
    super FONT_WIDTH * CANVAS_WIDTH, FONT_HEIGHT * CANVAS_HEIGHT, false
    self.caption = "EienteiRl"

    @font = Gosu::Font.new(self, "fonts/DejaVuSansMono.ttf", FONT_HEIGHT)

    @canvas = Canvas.new

    @map_raw = slurp("presets/test.txt")
    @map = Map.new(@map_raw)

    @minibuffer = []

    @actor = Factory.create_actor(3,2)
    r = Factory.rabbit(3,4)
    @entities = [@actor,r]

    @input_timer = 0

    do_turn
  end

  INPUT_WAIT = 8
  def update
    @input_timer += 1
    update_movement if @input_timer >= INPUT_WAIT

  end

  def update_movement
    delta_vx = 0 #maybe just call it ax...
    delta_vy = 0

    if button_down?(char_to_button_id('s'))
      delta_vy += 1
    end

    if button_down?(char_to_button_id('w'))
      delta_vy -= 1
    end

    if button_down?(char_to_button_id('a'))
      delta_vx -= 1
    end

    if button_down?(char_to_button_id('d'))
      delta_vx += 1
    end

    if delta_vx != 0 || delta_vy != 0
      @actor.velocity = Velocity.new(delta_vx, delta_vy)
      @input_timer = 0
      do_turn
    end

  end


  def do_turn
    turn(@entities,@map,@canvas,@minibuffer)
  end


  def draw
    @canvas.data.each_with_index do |fv, cx|
      fv.each_with_index do |glyph, cy|
        @font.draw(glyph.char, cx * FONT_WIDTH, cy * FONT_HEIGHT, 0, 1.0, 1.0, glyph.color)
      end
    end

  end
end


window = GameWindow.new
window.show
