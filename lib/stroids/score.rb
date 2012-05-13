class Score
  attr_accessor :score

  def initialize(window)
    @window = window
    @font = Gosu::Font.new window, '04b09', 8
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
    @font.draw "SCORE: #@score", 10, 10, ZOrder::GUI
  end
end