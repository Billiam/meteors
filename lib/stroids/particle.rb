class Particle
  attr_accessor :vector

  def initialize (window, lifetime, vector, speed=nil)
    @window = window
    @life = @lifetime = lifetime

    @vector = vector
    # Add a position to represent height
    @vector.z = 20

    @speed = speed || RQuad::Vector.new(0, 0)
    @speed.z = rand * 3 - 1.5

    @dead = false
  end

  def zorder
    ZOrder::OBJECT + @vector.y
  end

  def is_dead?
    @dead
  end

  def update (tick)
    @speed.z -= 0.05/tick

    if @vector.z + @speed.z <= 0
      # Bouncing objects lose energy and reverse
      @speed.z = @speed.z.abs
      @speed *= 0.5
    end

    @life -= 1/tick
    @vector += @speed/tick
    @dead = true if @life <= 0
  end

  def opacity
    [1, (@life * 7) / @lifetime].min * 255
  end

  def draw
    alpha = [opacity, 0].max
    color = Gosu::Color::from_ahsv(alpha, 0, 0, 0.8)
    shadow_color = Gosu::Color::from_ahsv(alpha, 0, 0, 0)


    @image.draw @vector.x, @vector.y + (20 - @vector.z), zorder, 1, 1, color
    #draw shadow
    @image.draw @vector.x, @vector.y + 22, ZOrder::SHADOW, 1, 1, shadow_color
  end
end