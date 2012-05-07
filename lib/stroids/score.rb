require 'overlay'

class Score < Overlay
  attr_accessor :score

  def initialize(window)
    super window
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
    return unless @visible
    @font.draw "SCORE: #@score", 10, 10, 20
  end
end