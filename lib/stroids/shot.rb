class Shot < GameObject
  attr_accessor :radius

  IMPULSE = 5
  COLLISION_LIMIT = 1
  LIFETIME = 80.0

  def initialize (window, vector, angle, speed)
    super window
    @vector = vector
    @radius = 2

    #Inherit speed from ship
    @speed = speed + speed_delta(angle, IMPULSE)
    @life = LIFETIME
    @collisions = 0
    @image = Gosu::Image.new(window, "../media/shot.png", false)
  end

  def destroys_asteroids?
    true
  end

  def is_live?
    @collisions < COLLISION_LIMIT && @life > 0
  end

  def update (tick)
    #reduce life of shot
    @life -= 1.0/tick

    @vector += create_vector(@speed.x / tick, @speed.y / tick)
  end

  def hit! (asteroid)
    @collisions += 1
  end

  def draw
    # Calculate opacity based on lifetime
    percent =[1, (@life * 10) / LIFETIME].min
    @image.draw @vector.x, @vector.y, 1, 1, 1, Gosu::Color::from_hsv(360, 0, percent)
  end
end