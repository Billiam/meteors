class Shot < GameObject
  attr_accessor :radius, :angle

  IMPULSE = 8
  COLLISION_LIMIT = 1
  LIFETIME = 45.0

  def initialize (window, vector, angle, speed)
    super window
    @vector = vector
    @radius = 2.5

    #Inherit speed from ship
    @speed = speed + speed_delta(angle, IMPULSE)
    @life = LIFETIME
    @collisions = 0
    @image = Gosu::Image.new(window, "../media/shot.png", false)

    @expire = false
  end

  def destroys_asteroids?
    true
  end

  def is_live?
    ! @expire
  end

  def update (tick)
    #reduce life of shot
    @life -= 1.0/tick
    @expire = true if @life <= 0
    @vector += create_vector(@speed.x / tick, @speed.y / tick)
  end

  def hit! (asteroid)
    @collisions += 1
    @expire = true if @collisions >= COLLISION_LIMIT
  end

  def draw
    # Calculate opacity based on lifetime
    percent =[1, (@life * 10) / LIFETIME].min
    @image.draw @vector.x, @vector.y, 1, 1, 1, Gosu::Color::from_hsv(360, 0, percent)
  end
end