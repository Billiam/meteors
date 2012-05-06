class WaveManager
  BASE_ASTEROIDS = 4
  def initialize(window)
    @window = window
    @wave = 1
  end

  def reset
    @wave = 1
    add_asteroids
  end

  def next_wave
    @wave += 1
    add_asteroids
  end

  def add_asteroids
    (@wave + BASE_ASTEROIDS).times do
      position = RQuad::Vector.new(rand(@window.width), rand(@window.height))
      @window.add_asteroid Asteroid.new(@window, position)
    end
  end
end