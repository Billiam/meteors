require 'game_object'

class Ship < GameObject
  attr_accessor :hyper, :health, :radius

  FRICTION = 0.005

  class Gun

  end

  def initialize (window)
    super window

    @angle = 0
    @health = 1

    @radius = 1
    @thrust = false

    @ship_img = Gosu::Image.new(window, "../media/ship.png", false)
    @thrust_img = Gosu::Image.new(window, "../media/ship-thrust.png", false)
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

    # add speed including current tick to current position
    @vector += create_vector @speed.x/tick, @speed.y/tick
  end

  def draw
    image = @thrust ? @thrust_img : @ship_img
    image.draw_rot(@vector.x, @vector.y, 1, @angle)
  end
end