require 'overlay'
class SplashScreen < Overlay
  def initialize(window, title_font)
    super window

    @heading = Gosu::Image.from_text(window, "TOTALLY NOT ASTEROIDS", "Komika Boogie", 84)
    @title_font = title_font
  end

  def draw
    return unless @visible
    @heading.draw 175, 120, 50
    @title_font.draw("press SPACE to start", 175, 345, 50, 0.3, 0.3)
  end
end