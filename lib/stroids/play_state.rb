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
    @lives = 0

    @overlays = [
        @score,
        Lives.new(self, window),
        Bullettime.new(window)
    ]

    init_sound

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
      when Gosu::KbZ
        add_shot @ship.fire if @ship.can_fire?
      when Gosu::KbP
        @window.state = PauseState.new @window, self
      when Gosu::KbX
        bullettime_on if @active
      when Gosu::KbEscape
        @window.state = SplashState.new @window
      when Gosu::KbF2
        hit_all_asteroids!
      else
    end
  end


  def button_up(id)
    case id
      when Gosu::KbX
        bullettime_off
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
    end
  end

  def draw
    visible_items.each(&:draw)
  end

  protected

  def init_sound
    @bullettime_instance = nil
    @bullettime_sound = @window.load_sound('matrix')
  end

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

    bullettime_off  # stay?

    @lives -= 1

    if @lives < 1
      later(3*60) {@window.state = GameoverState.new(@window, self)}
    else
      later(3*60) {respawn_ship}
    end
  end

  def respawn_ship
    @active = true
    @ship.spawn
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