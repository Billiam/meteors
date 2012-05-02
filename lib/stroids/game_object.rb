class GameObject
  attr_accessor :x, :y, :speed_x, :speed_y, :angle

  def speedDelta(angle, acceleration)
    radians = Gosu::degrees_to_radians angle - 90
    [acceleration * Math.cos(radians), acceleration * Math.sin(radians)]
  end

  def initialize (window)
    @window = window
    @x = 0
    @y = 0
    @speed_x = 0
    @speed_y = 0
  end
end