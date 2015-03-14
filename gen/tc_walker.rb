
require 'test/unit'
require_relative 'walker'

class TestDungeonWalker < Test::Unit::TestCase
  def test_direction
    walker = Walker.new(0,0,0)
    walker.direction = 1.1
    walker.walk
    assert_equal([0,1], walker.position)
  end

  def test_walk
    walker = Walker.new(0,0,0)
    assert_equal([1,0], walker.walk(0.1).position)
    assert_equal([1,1], walker.walk(1.1).position)
    assert_equal([0,1], walker.walk(1.8).position)
    assert_equal([0,0], walker.walk(3.1).position)
    assert_equal([0,-1], walker.walk(-1.1).position)
  end

  def test_wonder
    walker_before = Walker.new
    walker_after = walker_before.dup.wander
    assert_not_equal( walker_before.position, walker_after.position )
  end
end

