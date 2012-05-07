require 'rquad'

class GameObject
  attr_accessor :speed, :angle, :vector

  def speed_delta(angle, acceleration)
    radians = Gosu::degrees_to_radians angle - 90

    create_vector acceleration * Math.cos(radians), acceleration * Math.sin(radians)
  end

  def x
    @vector.x
  end

  def y
    @vector.y
  end

  def create_vector (x=0, y=0)
    RQuad::Vector.new x, y
  end

  def dist_to (item)
    @vector.dist_to(item.vector)
  end

  def initialize (window)
    @window = window
    @vector = create_vector
    @speed = create_vector
  end

  def warp (x, y)
    @vector = create_vector x, y
  end
end