Pos = Struct.new(:x,:y)
Velocity = Struct.new(:vx,:vy)
Glyph = Struct.new(:char, :color) do
  attr_accessor :invert, :item
end

Mind = Struct.new(:type)
Attack = Struct.new(:dice, :all_target_coords)
Intention = Struct.new(:tag, :value)
AttackMove = Struct.new(:dice, :targets) #dice is a lambda, targets are array of elements
VOID_GLYPH = Glyph.new(" ", Gosu::Color::NONE)
ACTOR_GLYPH = Glyph.new("@", Gosu::Color::YELLOW)
