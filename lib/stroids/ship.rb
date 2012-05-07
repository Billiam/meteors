require 'game_object'
require 'particle'

class Ship < GameObject
  attr_accessor :hyper, :health, :radius, :active_shots
  attr_reader :statistics

  FRICTION = 0.005

  class Effect < Particle
    def initialize (window, lifetime, vector, speed = 0)
      super
      @image = Gosu::Image.new(window, "../media/shot.png", false)
    end
  end

  def initialize (window)
    super window

    stats = Struct.new :shots, :fuel, :asteroids

    @statistics = stats.new 0, 0, 0

    @angle = 0
    @health = 1

    @active_shots = 0
    @radius = 1
    @thrust = false
    @hyper = false

    @ship_img = Gosu::Image.new(window, "../media/ship.png", false)
    @thrust_img = Gosu::Image.new(window, "../media/ship-thrust.png", false)
  end

  def can_fire?
    @active_shots < 4
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
    #check for can fire

    @statistics.shots += 1
    [Shot.new(@window, @vector, @angle, @speed)]
  end

  def thrust=(thrust)
    @thrust = thrust
    accelerate if thrust
  end

  def accelerate
    @speed += speed_delta @angle, ship_power
  end

  def hit! (item)
    #reduce health / shield
    @health -= 1
  end

  def is_live?
    @health > 0
  end

  def update(tick)
    #slow down based on friction
    @speed *= 1 - FRICTION

    if @thrust
      @statistics.fuel += ship_power / tick
    end

    # add speed including current tick to current position
    @vector += create_vector @speed.x/tick, @speed.y/tick
  end

  def draw
    return unless is_live?

    image = @thrust ? @thrust_img : @ship_img
    image.draw_rot(@vector.x, @vector.y, 1, @angle)
  end

  # return effect particles for explosion as an array
  def effect
    particle_count = rand(5) + 30
    particle_count.times.collect do
      # inherit speed from asteroid, and add random velocity
      speed = speed_delta(rand * 360, rand * 10 - 5) + @speed
      # create a new single particle
      Effect.new @window, 30, @vector, speed
    end
  end
end