class GameoverState < StroidsState
  def initialize(window, state)
    super window

    @state = state
    @heading = window.font_image(' Game Over!', 'KOMIKABG', 128)
    @title_font = window.load_font('04B20', 32)
    @background = window.dark_overlay
  end

  def update
    @state.update
  end

  def button_down(id)
    case id
      when Gosu::KbSpace
        @window.state = PlayState.new @window
      when Gosu::KbEscape
        @window.state = SplashState.new @window
      else
    end
  end

  def draw
    @state.draw

    @background.draw 0, 0, ZOrder::OVERLAY
    @heading.draw 175, 120, ZOrder::OVERLAY

    @title_font.draw("Final score: #{@state.score}", 175, 345, ZOrder::OVERLAY, 0.5, 0.5)


    ship = @state.ship
    accuracy = ship.statistics.shots == 0 ? 100 : (ship.statistics.asteroids / ship.statistics.shots.to_f * 100).floor

    #draw statistics
    pos = 385
    text = [
        "Shots: #{ship.statistics.shots}",
        "Kills: #{ship.statistics.asteroids}",
        "Accuracy: %.1f%" % accuracy,
        "Fuel Used: %.1f lbs" % ship.statistics.fuel,
    ]

    text.each do|item|
      @title_font.draw item, 175, pos, ZOrder::OVERLAY, 0.3, 0.3
      pos += 20
    end

    @title_font.draw("press SPACE to start", 175, 550, ZOrder::OVERLAY, 0.3, 0.3)

  end
end