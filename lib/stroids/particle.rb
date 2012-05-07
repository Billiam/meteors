class Particle
  attr_accessor :vector

  def initialize (window, lifetime, vector, speed=0)
    @window = window
    @life = @lifetime = lifetime

    @vector = vector

    @speed = speed.is_a?(RQuad::Vector) ? speed : RQuad::Vector.new(0, 0)

    @dead = false
  end

  def is_dead?
    @dead
  end

  def update (tick)
    @life -= 1/tick
    @vector += @speed/tick
    @dead = true if @life <= 0
  end

  def opacity
    @life / @lifetime
  end

  def draw
    color = Gosu::Color::from_hsv(360, 0, [opacity, 0].max)
    @image.draw @vector.x, @vector.y, 10, 1, 1, color
  end
end