class Lives
  def initialize(state, window)
    @window = window
    @state = state

    @image = window.load_image('ship')
  end

  def draw
    @state.lives.times do |i|
      @image.draw(120 + i * 18, 10, ZOrder::GUI, 0.8, 0.8)
    end
  end
end