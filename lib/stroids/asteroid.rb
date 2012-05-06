require 'observer'
class Asteroid < GameObject
  include Observable

  attr_reader :radius, :points

  def initialize (window, vector, speed=nil, size=3)
    super window

    asteroid_type = Struct.new :radius, :points, :image
    @sizes = {
        1 => asteroid_type.new(8, 15, Gosu::Image.new(window, "../media/asteroid2.png", false)),
        2 => asteroid_type.new(16, 10, Gosu::Image.new(window, "../media/asteroid3.png", false)),
        3 => asteroid_type.new(32, 5, Gosu::Image.new(window, "../media/asteroid4.png", false)),
    }

    @health = 1
    @dead = false

    @vector = vector

    #random angle and rotation
    @angle = rand 360
    @rotation = rand 360

    #random speed

    #random rotation
    @rotation_speed = rand * 8 -4

    random_speed = speed_delta(angle, rand * 0.8 + 0.5)

    # inherit velocity
    if speed.is_a? RQuad::Vector
      @speed = speed + random_speed
    else
      @speed = random_speed * 1.5
    end

    set_size size
  end

  #TODO: Refactor
  def set_size(size)
    if size > 0
      @size = size
      data = @sizes[size]

      @radius = data[:radius]
      @image = data[:image]
      @points = data[:points]
    else
      @dead = true
    end
  end

  def hit! (item)
    @health -= 1

    if @health < 1
      @dead = true

      spawned = []
      if @size > 1
        2.times do
          spawned << Asteroid.new(@window, @vector, @speed, @size - 1)
        end
        #  create new asteroids
      end

      changed
      notify_observers self, spawned
    end
    # trigger explosion
  end

  def is_live?
    ! @dead
  end

  def update(tick)
    @rotation += @rotation_speed/tick
    @vector += create_vector(@speed.x / tick, @speed.y / tick)
  end

  def draw
    @image.draw_rot(@vector.x, @vector.y, 1, @rotation, 0.5, 0.5)
  end
end