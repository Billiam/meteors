class Score
  attr_accessor :score

  def initialize(window)
    @window = window
    reset
  end

  def sub(score)
    @score = [0, @score - score].max
  end

  def add(score)
     @score += score
  end

  def reset
    @score = 0
  end

  def draw
    image = Gosu::Image.from_text(@window, "SCORE: #@score", "04b09", 8)
    image.draw(10, 10, 20, 1, 1, Gosu::Color::RED)
  end
end