class Shot < GameObject
  IMPULSE = 5
  LIFETIME = 100.0

  def initialize (window, origin_x, origin_y, angle, speed_x = 0, speed_y = 0)
    super window
    @x = origin_x
    @y = origin_y

    #Inherit speed from ship
    speed = speedDelta(angle, IMPULSE)
    @speed_x = speed[0] + speed_x
    @speed_y = speed[1] + speed_y

    @life = LIFETIME
    @image = Gosu::Image.new(window, "../media/shot.png", false)
  end

  def is_dead?
    @life < 0
  end

  def update (tick)
    #reduce life of shot
    @life -= 1.0/tick

    @x += @speed_x/tick
    @y += @speed_y/tick
  end

  def draw
    # Calculate opacity based on lifetime
    percent =[1, (@life / LIFETIME ) + 0.9].min
    @image.draw @x, @y, 1, 1, 1, Gosu::Color::from_hsv(360, 0, percent)
  end
end