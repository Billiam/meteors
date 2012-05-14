class SplashState < StroidsState
  def initialize(window)
    super window

    @animated_objects = []
    #
    @heading = Gosu::Image.from_text window, "TOTALLY NOT ASTEROIDS", "Komika Boogie", 84
    @title_font = window.load_font '04b_20', 32

    #@title_font = Gosu::Font.new window, '04b_20', 32

    @background = dark_overlay

    @waves = WaveManager.new self, window
    @waves.set_wave 10
  end

  def add_asteroid asteroid
    @animated_objects << asteroid
  end

  def update
    @animated_objects.each(&:update)
    wrap_objects
  end

  def wrap_objects
    @animated_objects.each do |item|
      item.vector.x %= @window.width
      item.vector.y %= @window.height
    end
  end

  def draw
    @background.draw 0, 0, ZOrder::OVERLAY

    @animated_objects.each(&:draw)
    @heading.draw 175, 120, ZOrder::OVERLAY
    @title_font.draw("press SPACE to start", 175, 345, ZOrder::OVERLAY, 0.3, 0.3)
  end

  def button_down(id)
    case id
      when Gosu::KbZ
        @animated_objects.first.hit! nil
      when Gosu::KbSpace
        @window.state = PlayState.new @window
      when Gosu::KbEscape
        @window.close
      else
    end
  end
end