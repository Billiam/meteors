class Ship < GameObject
  attr_accessor :hyper, :health, :radius, :active_shots
  attr_reader :statistics

  FRICTION = 0.005

  class Effect < Particle
    def initialize (window, lifetime, vector, speed = 0)
      super
      @image = window.load_image('shot')
    end
  end


  def initialize (window)
    super window

    stats = Struct.new :shots, :fuel, :asteroids

    @statistics = stats.new 0, 0, 0

    @angle = 0
    @health = 1
    @dead = false
    @active_shots = 0
    @radius = 3
    @thrust = false
    @hyper = false

    @tick = 1.0

    @thrust_instance = nil
    @shot_sound = window.load_sound('fire')
    @engine_sound = window.load_sound('engine')
    @explode_sound = window.load_sound('ship_explode')

    @ship_img = window.load_image('ship')
    @shadow_img = window.load_image('ship-shadow')
    @thrust_img = window.load_image('ship-thrust')
  end

  def can_fire?
    @active_shots < 4 && is_live?
  end

  def turn_speed
    @hyper ? 9 : 4
  end

  def ship_power
    @hyper ? 0.1 : 0.05
  end

  def stop
    @speed = create_vector
  end

  def turn_left(tick)
    @angle = (@angle - (turn_speed / tick)) % 360
  end

  def turn_right(tick)
    @angle =  (@angle + (turn_speed / tick)) % 360
  end

  def fire
    @statistics.shots += 1
    @shot_sound.play(1, sound_speed)
    [Shot.new(@window, @vector, @angle, @speed)]
  end

  def thrust=(thrust)
    @thrust = thrust
    if thrust
      accelerate
      @thrust_instance ||= @engine_sound.play 0.4, sound_speed, true
    else
      if @thrust_instance
        @thrust_instance.stop
        @thrust_instance = nil
      end
    end
  end

  def sound_speed
    1/@tick
  end


  def accelerate
    @speed += speed_delta @angle, ship_power
  end

  def hit! (item)
    #reduce health / shield
    @health -= 1
    @dead = health <= 0
    destroy! if @dead
  end

  def destroy!
    @explode_sound.play
  end

  def is_live?
    ! @dead
  end

  def update(tick)
    if tick != @tick
      @tick = tick
      #update speed of playing sounds
      @thrust_instance.speed = sound_speed if @thrust_instance
    end

    #slow down based on friction
    @speed *= 1 - FRICTION

    if @thrust
      @statistics.fuel += ship_power / tick
    else

    end

    # add speed including current tick to current position
    @vector += create_vector(@speed.x, @speed.y) / tick
  end

  def draw
    return unless is_live?

    image = @thrust ? @thrust_img : @ship_img
    @window.scale(1, 0.55, @vector.x, @vector.y) do
      image.draw_rot(@vector.x, @vector.y, zorder, @angle)
    end

    @window.scale(1, 0.55, @vector.x, @vector.y + 30) do
      @shadow_img.draw_rot(@vector.x, @vector.y + 30, ZOrder::SHADOW, @angle)
    end
  end

  # return effect particles for explosion as an array
  def effect
    particle_count = rand(15) + 50
    particle_count.times.collect do
      # inherit speed from asteroid, and add random velocity
      particle_speed = rand * 10 - 5
      life = rand(60) + 120
      random_speed = speed_delta(rand * 360, particle_speed)
      random_speed.y *= 0.5
      speed = random_speed + @speed
      # create a new single particle
      Effect.new @window, life , @vector, speed
    end
  end
end