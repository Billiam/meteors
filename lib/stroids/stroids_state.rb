class StroidsState
  def initialize(window)
    @window = window
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