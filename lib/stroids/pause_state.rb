class PauseState < StroidsState
  def initialize(window, state)
    super window
    @state = state
    @heading = window.font_image(' Paused', 'KOMIKABG', 128)
    @background = window.dark_overlay
  end

  def button_down(id)
    case id
      when Gosu::KbP, Gosu::KbEscape
        # Return to previous state
        @window.state = @state
      else
    end
  end

  def draw
    # Draw previous state in the background
    @state.draw

    @background.draw 0, 0, ZOrder::OVERLAY
    @heading.draw 175, 120, ZOrder::OVERLAY
  end
end