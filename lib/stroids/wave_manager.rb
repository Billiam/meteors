class WaveManager
  BASE_ASTEROIDS = 4
  WAVE_DELAY = 1500

  attr_reader :wave

  def initialize(state, window)
    @state = state
    @window = window
    @wave = 1
    @wave_ended = 0
  end

  def reset
    @wave = 1
    @wave_ended = 0
    add_asteroids
  end

  def set_wave num
    @wave = num
    add_asteroids
  end

  def update
    if @wave != @wave_ended && @state.round_complete?
      @wave_ended = @wave
      @window.timers.set_timeout WAVE_DELAY do
        next_wave
      end
    end
  end

  def next_wave
    @wave += 1
    add_asteroids
  end
;
  def add_asteroids
    (@wave + BASE_ASTEROIDS).times do
      position = RQuad::Vector.new(rand(@window.width), rand(@window.height))
      @state.add_asteroid Asteroid.new(@window, position)
    end
  end
end