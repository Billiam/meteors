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
    @angle = angle
    @life = LIFETIME
    @collisions = 0
    @image = Gosu::Image.new(window, "../media/shot.png", false)
    @trail = Gosu::Image.new(window, "../media/trail.png", false)
    @expire = false
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
    percent = [1, (@life * 10) / LIFETIME].min
    opacity = (percent * 255).floor
    color = Gosu::Color::from_ahsv([opacity, 0].max, 0, 0, 1)

    @image.draw @vector.x, @vector.y, ZOrder::PROJECTILE, 1, 1, color
  end
end