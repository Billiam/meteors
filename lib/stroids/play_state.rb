class PlayState < StroidsState
  attr_reader :ship, :asteroids, :lives, :score

  def initialize(window)
    super

    @width = window.width
    @height = window.height

    @tick = 1.0

    @collider = Collider.new @width, @height
    @waves = WaveManager.new self, window
    @score = Score.new window
    @bullettime = Bullettime.new(window)
    @bullettime.add_observer(self, :bullettime_updated)

    @lives = 0

    @overlays = [
        @score,
        Lives.new(self, window),
        @bullettime
    ]

    start
  end

  # Initialize game state
  def start
    @lives = 3

    #Reset objects and state
    @active = true

    @asteroids = []
    @effects = []
    @shots = []

    @ship = Ship.new @window
    @ship.warp(400,300)
    @bullettime.add_observer(@ship, :bullettime_updated)

    @score.reset
    @waves.reset
  end


  def round_complete?
    @asteroids.empty? && @active
  end

  # Callback from
  def add_shot(shots)
    @shots.concat shots
  end

  def button_down(id)
    case id
      when Gosu::KbSpace
        add_shot @ship.fire if @ship.can_fire?
      when Gosu::KbP
        @window.state = PauseState.new @window, self
      when Gosu::KbLeftShift
        @bullettime.enable if @active
      when Gosu::KbEscape
        @window.state = SplashState.new @window
      when Gosu::KbF2
        hit_all_asteroids!
      else
    end
  end


  def button_up(id)
    case id
      when Gosu::KbLeftShift
        @bullettime.disable
      else
    end
  end

  #callback when bullettime changes
  def bullettime_updated(enabled)
    if enabled
      @tick = 5.0
    else
      @tick = 1.0
    end
  end

  def update_counter
    @tick_count += 1/@tick
  end

  def update
    super

    parse_input
    move_objects
    effects, new_asteroids = check_collisions
    expire_objects

    @ship.active_shots = @shots.length
    @bullettime.update

    # add spawned items
    @effects.concat effects
    new_asteroids.each {|a| add_asteroid(a)}
    #update effects
    @effects.each{|e| e.update(@tick)}

    # check for player death
    handle_player_death

    # Go to next wave
    @waves.update if round_complete?
  end

  # Add an asteroid
  def add_asteroid(asteroid)
    asteroid.add_observer(self, :asteroid_destroyed)
    @asteroids << asteroid
  end

  #Callback when asteroids are destroyed
  def asteroid_destroyed (asteroid)
    #Add points
    unless asteroid.is_live?
      @score.add(asteroid.points)
      @ship.statistics.asteroids += 1
      @bullettime.restore(2.0)
    end
  end

  def draw
    visible_items.each(&:draw)
  end

  protected

  # List of moving objects that wrap at screen edges
  def moving_objects
    @asteroids + @effects + @shots + [@ship]
  end

  def gameplay_objects
    (@asteroids + @shots + [@ship]).compact
  end

  def visible_items
    (gameplay_objects + @effects + @overlays)
  end

  def parse_input
    return unless @ship.is_live?

    @ship.thrust = button_down? Gosu::KbUp

    if button_down? Gosu::KbLeft
      @ship.turn_left @tick
    elsif button_down? Gosu::KbRight
      @ship.turn_right @tick
    end
  end

  # Wrap objects at screen edges
  def wrap_objects
    moving_objects.each do |item|
      item.vector.x %= @width
      item.vector.y %= @height
    end
  end

  def move_objects
    #move all objects
    gameplay_objects.each {|item| item.update(@tick)}

    #wrap objects at screen edges
    wrap_objects
  end

  def check_collisions
    #update collider data and check for collisions
    @collider.update(@asteroids, @shots, @ship)
    @collider.notify_collisions
  end

  def expire_objects
    [@shots, @asteroids, @effects].each do |set|
      set.reject! {|item| ! item.is_live?}
    end
  end

  def handle_player_death
    return if @ship.is_live? || ! @active
    @active = false

    @bullettime.disable

    @lives -= 1

    if @lives < 1
      later(3*60) {@window.state = GameoverState.new(@window, self)}
    else
      later(3*60) {respawn_ship}
    end
  end

  def respawn_ship
    @bullettime.reset!
    @active = true
    @ship.spawn!
    @ship.warp(400,300)
  end


  def hit_all_asteroids!
    return unless @active
    new_asteroids = []
    @asteroids.each do |asteroid|
      new_effects, spawned = asteroid.hit!
      @effects.concat(new_effects)
      new_asteroids.concat(spawned)
    end
    new_asteroids.each(&method(:add_asteroid))

  end



end