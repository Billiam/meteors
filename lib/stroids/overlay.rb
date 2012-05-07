class Overlay
  attr_accessor :visible

  def initialize(window)
    @visible = false
    @window = window
  end
end