class SplashState < StroidsState
  def initialize(window)
    super window

    @asteroids = []
    @effects = []
    @new_asteroids = []

    @heading = window.font_image(' Meteors', 'KOMIKABG', 120)
    @title_font = window.load_font('04B20', 32)

    @background = window.dark_overlay


    @waves = WaveManager.new self, window
    @waves.set_wave 10
  end

  def add_asteroid asteroid
    @asteroids << asteroid
  end

  def update
    @asteroids.each(&:update)

    wrap_objects

    # remove asteroids
    @asteroids.reject! do |asteroid|
      ! asteroid.is_live?
    end

    # remove effects
    @effects.reject! do |effect|
      ! effect.is_live?
    end

    #update effects
    @effects.each(&:update)
  end


  def draw
    @background.draw 0, 0, ZOrder::OVERLAY

    @asteroids.each(&:draw)
    @effects.each(&:draw)

    @heading.draw 175, 120, ZOrder::OVERLAY
    @title_font.draw("press SPACE to start", 175, 345, ZOrder::OVERLAY, 0.3, 0.3)
  end

  def button_down(id)
    case id
      when Gosu::KbZ
        @asteroids.each(&:hit!)
      when Gosu::KbSpace
        @window.state = PlayState.new @window
      when Gosu::KbEscape
        @window.close
      when Gosu::MsLeft
        click(@window.mouse_x, @window.mouse_y)
      else
    end
  end

  protected

  def moving_objects
    @asteroids + @effects
  end

  def wrap_objects
    moving_objects.each do |item|
      item.vector.x %= @window.width
      item.vector.y %= @window.height
    end
  end

  def click (mouse_x, mouse_y)
    pos = RQuad::Vector.new(mouse_x, mouse_y)
    @asteroids.each do |asteroid|
      if asteroid.vector.dist_to(pos) < asteroid.radius
        new_effects, new_asteroids = asteroid.hit!
        new_asteroids.each(&method(:add_asteroid))
        @effects.concat(new_effects)
        break
      end
    end
  end
end