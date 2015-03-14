
require 'test/unit'
require_relative 'arena'

class TestArena < Test::Unit::TestCase
  def test_default
    arena = Arena.new
    assert_equal('#', arena[0,0])
    assert_equal('#', arena[100,100])
  end
  
  def test_can_use_negatives
    arena = Arena.new
    assert_equal('#', arena[-10,-10])
    assert_equal('#', arena[-10,10])
    assert_equal('#', arena[10,-10])
  end 
  
  def test_can_set
    arena = Arena.new
    arena[0,0] = '1'
    assert_equal('1', arena[0,0])
  end
  
  def test_barfs_about_bad_coords
    assert_raise(ArgumentError) {(Arena.new)[123,123,123]}
    assert_raise(ArgumentError) {(Arena.new)[123]}
  end

  def test_extents
    arena = Arena.new
    arena[-3,0] = '.'
    arena[4,0] = '.'
    arena[0,-5] = '.'
    arena[0,6] = '.'
    
    assert_equal(-3, arena.left)
    assert_equal(4, arena.right)
    assert_equal(-5, arena.top)
    assert_equal(6, arena.bottom)
  end

  def test_to_array
    arena = Arena.new
    arena[0,0] = '.'
    assert_equal([%w{# # #}, %w{# . #}, %w{# # #}], arena.to_array)
  end

  def test_to_s
    arena = Arena.new
    arena[0,0] = '.'
    assert_equal("###\n#.#\n###", arena.to_s)
  end
end

