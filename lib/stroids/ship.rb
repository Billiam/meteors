require 'game_object'

class Ship < GameObject

  def initialize (window)
    super window
    @friction = 0.01
    @angle = 0
    @turn_speed = 3
    @acceleration = 0.1

    @image = Gosu::Image.new(window, "../media/ship.png", false)
  end

  def warp (x, y)
    @x, @y = x, y
  end

  def stop
    @speed_x = 0
    @speed_y = 0
  end

  def turn_left
    @angle = (@angle - @turn_speed) % 360
  end

  def turn_right
    @angle =  (@angle + @turn_speed) % 360
  end

  def fire
    [Shot.new @window, @x, @y, @angle, @speed_x, @speed_y]
  end

  def accelerate
    speed = speedDelta(@angle, @acceleration)
    @speed_x += speed[0]
    @speed_y += speed[1]
  end

  def update
    #puts @angle
    @x += @speed_x
    @y += @speed_y

    #slow down
    @speed_x *= 1 - @friction
    @speed_y *= 1 - @friction
  end

  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
end