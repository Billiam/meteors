class StroidsState
  def initialize(window)
    @window = window
  end

  def dark_overlay
    TexPlay::create_blank_image(@window, @window.width, @window.height, {:caching => false, :color => [0, 0, 0, 0.6 ]})
  end

  def button_up(id)
  end

  def button_down(id)
  end

  def setup
  end

  def update
  end

  def teardown
  end

  def draw
  end

  def button_down? id
    @window.button_down? id
  end

  def button_up? id
    @window.button_up? id
  end
end