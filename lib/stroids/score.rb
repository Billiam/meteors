class Score
  attr_accessor :score

  def initialize(window)
    @window = window
    @font = window.load_font('BITLOW' , 28)
    reset
  end

  def sub(score)
    @score -= score
  end

  def add(score)
     @score += score
  end

  def reset
    @score = 0
  end

  def to_s
    @score.to_s
  end

  def draw
    @font.draw("#@score", 5, 5, ZOrder::OVERLAY, 0.5, 0.5)
  end
end