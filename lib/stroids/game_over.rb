require 'overlay'
class GameOver < Overlay
  def initialize(window, title_font)
    super window
    @heading = Gosu::Image.from_text(window, " Game Over!", "Komika Boogie", 128)
    @title_font = title_font
  end

  def draw
    return unless @visible

    @heading.draw 175, 120, 50
    @title_font.draw("Final score: #{@window.score}", 175, 345, 50, 0.5, 0.5)
    ship = @window.ship

    accuracy = ship.statistics.shots == 0 ? 100 : (ship.statistics.asteroids / ship.statistics.shots.to_f * 100).floor

    #draw statistics
    pos = 385
    [
        "Shots: #{ship.statistics.shots}",
        "Kills: #{ship.statistics.asteroids}",
        "Accuracy: %.1f%" % accuracy,
        "Fuel Used: %.1f lbs" % ship.statistics.fuel,
    ].each {|item|
      @title_font.draw item, 175, pos, 50, 0.3, 0.3
      pos += 20
    }
  end
end