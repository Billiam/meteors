require 'game_object'

class Ship < GameObject
  attr_accessor :hyper

  FRICTION = 0.005

  def initialize (window)
    super window

    @angle = 0
    @image = Gosu::Image.new(window, "../media/ship.png", false)
  end

  def turn_speed
    @hyper ? 9 : 4
  end

  def acceleration
    @hyper ? 0.1 : 0.05
  end


  def warp (x, y)
    @x, @y = x, y
  end

  def stop
    @speed_x = 0
    @speed_y = 0
  end

  def turn_left(tick)
    @angle = (@angle - (turn_speed / tick)) % 360
  end

  def turn_right(tick)
    @angle =  (@angle + (turn_speed / tick)) % 360
  end

  def fire
    [Shot.new(@window, @x, @y, @angle, @speed_x, @speed_y)]
  end

  def accelerate
    speed = speedDelta(@angle, acceleration)
    @speed_x += speed[0]
    @speed_y += speed[1]
  end

  def update(tick)
    @x += @speed_x / tick
    @y += @speed_y / tick

    @speed_x *= 1 - FRICTION
    @speed_y *= 1 - FRICTION
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end