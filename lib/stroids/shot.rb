class Shot < GameObject
  IMPULSE = 5
  LIFETIME = 10

  def initialize (window, origin_x, origin_y, angle, speed_x = 0, speed_y = 0)
    super window
    @x = origin_x
    @y = origin_y

    #Inherit speed from ship
    speed = speedDelta(angle, IMPULSE)
    @speed_x = speed[0] + speed_x
    @speed_y = speed[1] + speed_y

    # This won't work :)'
    #@velocity_x = velocity_x + IMPULSE
    #@velocity_y = velocity_y + IMPULSE

    @life = LIFETIME
    @image = Gosu::Image.new(window, "../media/shot.png", false)
  end

  def is_dead?
    @life < 0
  end

  def update
    @life -= 1
    @x += @speed_x
    @y += @speed_y
  end

  def draw
    @image.draw @x, @y, 1
  end
end