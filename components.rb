Pos = Struct.new(:x,:y)
Velocity = Struct.new(:vx,:vy)
Glyph = Struct.new(:char, :color) do
  attr_accessor :invert, :item
end

Mind = Struct.new(:type)
Card = Struct.new(:glyph, :name)
Intention = Struct.new(:tag, :value)
AttackMove = Struct.new(:dice, :targets) #dice is a lambda, targets are array of elements

Skill = Struct.new(:level, :code) do
  def get_name
    return get_vocab(self.code)
  end
end


VOID_GLYPH = Glyph.new(" ", Gosu::Color::NONE)
ACTOR_GLYPH = Glyph.new("@", Gosu::Color::YELLOW)


