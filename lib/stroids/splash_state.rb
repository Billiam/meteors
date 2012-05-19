class SplashState < StroidsState
  def initialize(window)
    super window

    @asteroids = []
    @effects = []
    @new_asteroids = []

    @heading = window.font_image(' TOTALLY NOT ASTEROIDS', 'KOMIKABG', 84)
    @title_font = window.load_font('04B20', 32)

    @background = window.dark_overlay


    @waves = WaveManager.new self, window
    @waves.set_wave 10
  end

  def add_asteroid asteroid
    asteroid.add_observer(self, :asteroid_updated)
    @asteroids << asteroid
  end

  def moving_objects
    @asteroids + @effects
  end

  # Callback when asteroids are destroyed
  def asteroid_updated (asteroid, new_asteroids)
    @new_asteroids += new_asteroids
  end

  def update
    @asteroids.each(&:update)

    wrap_objects

    # remove asteroids
    @asteroids.reject! do |asteroid|
      unless asteroid.is_live?
        @effects += asteroid.effect
      end
    end

    # remove effects
    @effects.reject! do |effect|
      effect.is_dead?
    end

    #add newly spawned asteroids
    @new_asteroids.each{|item| add_asteroid(item)}
    @new_asteroids = []

    #update effects
    @effects.each(&:update)
  end

  def wrap_objects
    moving_objects.each do |item|
      item.vector.x %= @window.width
      item.vector.y %= @window.height
    end
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

  def click (mouse_x, mouse_y)
    pos = RQuad::Vector.new(mouse_x, mouse_y)
    @asteroids.each do |asteroid|
      if asteroid.vector.dist_to(pos) < asteroid.radius
        asteroid.hit!
        break
      end
    end
  end
end