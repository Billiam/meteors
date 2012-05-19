class PlayState < StroidsState
  attr_reader :ship, :asteroids, :lives, :score

  def initialize(window)
    super

    @width = window.width
    @height = window.height

    @tick = 1.0

    #Game ob
    @collider = Collider.new @width, @height
    @waves = WaveManager.new self, window
    @score = Score.new window

    @overlays = [
        @score,
        Lives.new(self, window),
        BullettimeOverlay.new(window)
    ]

    @bullettime_instance = nil
    @bullettime_sound = window.load_sound('matrix')

    @lives = 3

    start
  end

  # Initialize game state
  def start
    #Reset objects and state
    @active = true

    @asteroids = []
    @effects = []
    @shots = []

    #buffer to hold newly spawned asteroids until the next round
    @new_asteroids = []

    @ship = Ship.new @window
    @ship.warp(400,300)

    @score.reset
    @waves.reset
  end

  # List of moving objects that wrap ot screen edges
  def moving_objects
    @asteroids + @effects + @shots + [@ship]
  end

  def round_complete?
    @asteroids.empty? && @active
  end

  # Wrap objects at screen edges
  def wrap_objects
    moving_objects.each do |item|
      item.vector.x %= @width
      item.vector.y %= @height
    end
  end

  # Callback from
  def add_shot(shots)
    @shots.concat shots
    #@ship.active_shots += shots.length
  end

  def button_down(id)
    case id
      when Gosu::KbZ
        add_shot @ship.fire if @ship.can_fire?
      when Gosu::KbP
        @window.state = PauseState.new @window, self
      when Gosu::KbX
        bullettime_on if @active
      when Gosu::KbEscape
        @window.state = SplashState.new @window
      when Gosu::KbF2
        @asteroids.each(&:hit!) if @active
      else
    end
  end

  def bullettime_on
    @tick = 5.0
    #Is this necessary?
    @ship.hyper = true
    @bullettime_instance = @bullettime_sound.play 0.1
  end

  def bullettime_off
    @tick = 1.0
    @ship.hyper = false
    @bullettime_instance.stop if @bullettime_instance
  end

  def button_up(id)
    case id
      when Gosu::KbX
        bullettime_off
      else
    end
  end

  def objects
    (@asteroids + @shots + [@ship]).compact
  end

  def update_counter
    @tick_count += 1/@tick
  end

  def update
    super

    if @ship.is_live?
      @ship.thrust = button_down? Gosu::KbUp

      if button_down? Gosu::KbLeft
        @ship.turn_left @tick
      elsif button_down? Gosu::KbRight
        @ship.turn_right @tick
      end
    end

    #move all objects
    objects.each {|item| item.update @tick }

    #wrap objects at screen edges
    wrap_objects

    #update collider data and check for collisions
    @collider.update @asteroids, @shots, @ship
    @collider.notify_collisions

    #expire shots
    @shots = @shots.reject do |shot|
      ! shot.is_live?
    end

    @ship.active_shots = @shots.length

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

    # check for player death
    if ! @ship.is_live? && @active
      @active = false
      ship_explode!
    end

    #update effects
    @effects.each{|effect| effect.update @tick}

    # Go to next wave
    @waves.update
  end

  def ship_explode!
    bullettime_off
    @ship.thrust = false
    @effects += @ship.effect
    @lives -= 1
    if @lives < 1
       later 3*60 do
        @window.state = GameoverState.new(@window, self)
      end
    else
      later 3*60 do
        @active = true
        @ship.spawn
        @ship.warp(400,300)
      end
    end
  end


  # Add an asteroid
  def add_asteroid(asteroid)
    asteroid.add_observer(self, :asteroid_updated)
    @asteroids << asteroid
  end


  # Callback when asteroids are destroyed
  def asteroid_updated (asteroid, new_asteroids)
    @new_asteroids += new_asteroids
    #Add points
    unless asteroid.is_live?
      @score.add(asteroid.points)
      @ship.statistics.asteroids += 1
    end
  end

  def draw
    (objects + @effects + @overlays).each(&:draw)
  end
end