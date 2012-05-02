class Asteroid < GameObject

  def initialize (window, size=2)
    super window
    @size = size
    @angle = 0
    @rotation_speed = rand(800)/100 - 4
    @image = Gosu::Image.new(window, "../media/asteroid.png", false)
  end

  def hitBy? (shot)

  end

  def split
    @size -= 1
    #set random velocities
    self.new @window, @size
  end

  def update
    @angle += @rotation_speed
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end