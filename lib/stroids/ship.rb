class Ship < GameObject
  include Observable

  attr_accessor :hyper, :health, :radius, :active_shots
  attr_reader :statistics

  FRICTION = 0.005
  SPAWN_PROTECT_TIME = 2.5 * 60

  class Effect < Particle
    def initialize (window, lifetime, vector, speed = 0)
      super
      @image = window.load_image('shot')
    end
  end

  def initialize (window, tick=1.0)
    super window

    stats = Struct.new :shots, :fuel, :asteroids

    @radius = 3
    @statistics = stats.new 0, 0, 0
    @tick_count = 0.0
    @tick = tick
    initialize_media
    spawn
  end

  def stop
    @speed = create_vector
  end

  def turn_left(tick)
    @angle -= rotate(tick)
    @angle %= 360
  end

  def turn_right(tick)
    @angle += rotate(tick)
    @angle %= 360
  end


  def collides?
    ! @protected
  end

  def can_fire?
    @active_shots < 4 && is_live?
  end

  def fire
    stop_protect
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


  def spawn
    @angle = 0
    @health = 1
    @dead = false
    @active_shots = 0
    @thrust = false
    @hyper = false

    protect!
    stop
  end

  def protect!
    @protected = true
    @protect_time = SPAWN_PROTECT_TIME
  end

  def hit! (item)
    #reduce health / shield
    @health -= 1
    destroy! if health <= 0
  end

  def destroy!
    @dead = true
    @explode_sound.play
    self.thrust = false
    effect
  end

  def is_live?
    ! @dead
  end

  def update_spawn_protect
    if @protected
      @protect_time -= 1/@tick
      stop_protect if @protect_time <= 0
    end
  end

  def stop_protect
    @protected = false
  end

  def update(tick)
    @tick_count += tick
    if tick != @tick
      @tick = tick
      #update speed of playing sounds
      @thrust_instance.speed = sound_speed if @thrust_instance
    end

    update_spawn_protect

    #slow down based on friction
    @speed *= 1 - FRICTION

    if @thrust
      @statistics.fuel += ship_power / tick
    end

    # add speed including current tick to current position
    @vector += @speed / tick
  end

  def draw
    return unless is_live?

    if @protected
      color = Gosu::Color::from_ahsv(opacity, 0, 0, 1)
    else
      color = 0xffffffff
    end

    image = @thrust ? @thrust_img : @ship_img
    @window.scale(1, 0.55, @vector.x, @vector.y) do
      image.draw_rot(@vector.x, @vector.y, zorder, @angle, 0.5, 0.5, 1, 1, color)
    end

    @window.scale(1, 0.55, @vector.x, @vector.y + 30) do
      @shadow_img.draw_rot(@vector.x, @vector.y + 30, ZOrder::SHADOW, @angle)
    end
  end

  def to_s
    "H:#@health s:#@speed p:#@vector"
  end

  protected

  def turn_speed
    @hyper ? 12 : 6
  end

  def ship_power
    @hyper ? 0.1 : 0.05
  end

  def rotate(tick)
    speed = turn_speed / tick
    @statistics.fuel += speed / 1500
    speed
  end

  def sound_speed
    1/@tick
  end

  def accelerate
    @speed += speed_delta @angle, ship_power
  end

  def opacity
    ((@protect_time * 10 % 300) - 150).abs + 25
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

  def initialize_media

    @thrust_instance = nil
    @shot_sound = @window.load_sound('fire')
    @engine_sound = @window.load_sound('engine')
    @explode_sound = @window.load_sound('ship_explode')

    @ship_img = @window.load_image('ship')
    @shadow_img = @window.load_image('ship-shadow')
    @thrust_img = @window.load_image('ship-thrust')
  end
end