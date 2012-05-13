class WaveManager
  BASE_ASTEROIDS = 4

  def initialize(state, window)
    @state = state
    @window = window
    @wave = 1
  end

  def reset
    @wave = 1
    add_asteroids
  end

  def set_wave num
    @wave = num
    add_asteroids
  end

  def next_wave
    @wave += 1
    add_asteroids
  end

  def add_asteroids
    (@wave + BASE_ASTEROIDS).times do
      position = RQuad::Vector.new(rand(@window.width), rand(@window.height))
      @state.add_asteroid Asteroid.new(@window, position)
    end
  end
end