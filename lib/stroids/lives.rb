class Lives
  def initialize(lives, window)
    @window = window
    @lives = lives
    puts lives.call

    @image = window.load_image('ship')
  end

  def draw
    @lives.times do |i|
      @image.draw(120 + i * 18, 10, ZOrder::GUI, 0.8, 0.8)
    end
  end
end