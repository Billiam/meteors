class Asteroid < GameObject
  include Observable
  attr_reader :radius, :points, :health

  class Effect < Particle
    def initialize (window, lifetime, vector, speed = 0)
      super
      @image = window.load_image 'asteroid-particle'
    end
  end


  def initialize (window, vector, speed=nil, size=3)
    super window

    case size
      when 1
        @radius = 8
        @points = 100
        @image = window.load_image 'asteroid2'
        @shadow = window.load_image 'shadow2'
      when 2
        @radius = 16
        @points = 50
        @image = window.load_image 'asteroid3'
        @shadow = window.load_image 'shadow3'
      when 3
        @radius = 24
        @points = 120
        @image = window.load_image 'asteroid4'
        @shadow = window.load_image 'shadow4'
      else
    end


    @sound = window.load_sound 'asteroid_explode'

    @split_size = size > 1 ? size - 1 : nil

    @health = 1
    @dead = false
    @vector = vector
    @tick = 1.0

    #random starting angle and rotation
    @angle = rand 360
    @rotation = rand 360

    #random rotation
    @rotation_speed = rand * 8 - 4

    random_speed = speed_delta(angle, rand * 0.8 + 0.5)

    # inherit velocity
    if speed
      @speed = speed + random_speed
    else
      @speed = random_speed * 1.5
    end

  end

  def hit!(item)
    @health -= 1
    if @health < 1
      @dead = true

      @sound.play 0.8, 1/@tick

      spawned = @split_size ? [split_factory, split_factory] : []

      # Trigger chanegs for observers
      changed
      notify_observers self, spawned
    end
  end

  # Factory method for splitting off new asteroids
  def split_factory
    Asteroid.new @window, @vector, @speed, @split_size
  end

  def is_dead?
    @dead
  end

  def is_live?
    ! @dead
  end

  def update(tick=1.0)
    @tick = tick
    @rotation += @rotation_speed/tick
    @vector += create_vector(@speed.x, @speed.y) / tick
  end

  def draw
    @image.draw_rot @vector.x, @vector.y, zorder, @rotation, 0.5, 0.5
    @shadow.draw @vector.x - @radius, @vector.y + 30, ZOrder::SHADOW, 1, 0.5
  end

  # return effect particles for explosion as an array
  def effect
    particle_count = rand(5) + 10
    particle_count.times.collect do
      velocity = rand * 5 - 2.5
      life = rand(45) + 45
      random_speed = speed_delta(rand * 360, velocity)
      random_speed.y *= 0.5
      # inherit speed from asteroid, and add random velocity
      speed = random_speed + @speed
      # create a new single particle
      Effect.new @window, life, @vector, speed
    end
  end
end