
# This class basically implements a random walk. I remember
# my direction, and it's this that I randomly adjust, rather
# than simply jittering my position.
class Walker
  attr_accessor :x, :y, :direction
  
  def initialize(x=0, y=0, direction=0)
    @x, @y, @direction = x, y, direction
  end

  # Handy for testing.
  def position
    [x,y]
  end
  
  # Adjust direction, and walk once.
  def wander
    perturb_direction
    walk
  end

  # Make the child pointing of 90 degrees away from me.
  def create_child
    Walker.new(x, y, direction + 2*rand(2) - 1)
  end

  def perturb_direction
    @direction += rand*wiggle_max - (wiggle_max/2)
  end
  
  def walk(d = direction_with_smoothing_fuzz)
    # Ensure that the direction is correctly wrapped around.
    d = (d.round)%4
    @x += [1,0,-1,0][d]
    @y += [0,1,0,-1][d]
    self
  end
  
  # Adding some noise on to the direction "stocastically" samples
  # it, smoothing off turns, and making it more catacombey.
  def direction_with_smoothing_fuzz
    @direction + rand*smoothing - smoothing/2
  end

  # How wiggley are the dungeons? Bigger numbers are more wiggly
  # and compact.
  def wiggle_max
    0.9
  end
  
  # How smooth are tunnels? Larger numbers give smoother more
  # 'catacombe' like tunnels (and smaller dungeons). Smaller
  # numbers give more cartesian & straight tunnels.
  def smoothing
    0.4
  end

end

