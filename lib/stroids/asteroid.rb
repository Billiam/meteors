class Asteroid < GameObject
  def initialize (window, size=10)
    super window



    @size = size
    @angle = 0
    @rotation_speed = rand(800)/100 - 4
    @image = Gosu::Image.new(window, "../media/asteroid.png", false)
    @hit = false
  end

  def radius
    @size * 15 * 0.2
  end

  def split
    @size -= 1
    self.new @window, @size
  end

  def hit! (item)
    #if item is ship, ignore
    if item.destroys_asteroids?
      @size -= 1
      @hit = true
    end
  end

  def is_live?
    @size > 0
  end

  def update(tick)
    @angle += @rotation_speed/tick
  end

  def draw
    #@image.draw_rot(@vector.x, @vector.y, 1, @angle)
    #color = @hit ? Gosu::Color::GREEN : Gosu::Color::WHITE
    @image.draw_rot(@vector.x, @vector.y, 1, @angle, 0.5, 0.5, @size*0.2, @size*0.2)

    #@image.draw_rot(@vector.x, @vector.y, 1, @angle, 0.5, 0.5, 1, 1, color)
  end
end