class PauseState < StroidsState
  def initialize(window, state)
    super window
    @state = state
    @heading = Gosu::Image.from_text(window, "Paused", "Komika Boogie", 128)
    @background = dark_overlay
  end

  def button_down(id)
    if [Gosu::KbP, Gosu::KbEscape].include? id
      @window.state = @state
    end
  end

  def draw
    @state.draw
    @background.draw 0, 0, ZOrder::OVERLAY
    @heading.draw 175, 120, ZOrder::MODAL
  end
end