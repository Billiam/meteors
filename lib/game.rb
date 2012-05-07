$: << 'stroids'

require 'gosu'
require 'collider'
require 'wave_manager'
require 'ship'
require 'asteroid'
require 'shot'
require 'score'
require 'rquad'
require 'fps_counter'

require 'game_over'
require 'splash'


class Game < Gosu::Window
  attr_accessor :ship

  GAME_WIDTH = 800
  GAME_HEIGHT = 600

  def initialize
    @width = GAME_WIDTH
    @height = GAME_HEIGHT
    @tick = 1.0
    @started = false

    Gosu::enable_undocumented_retrofication

    super @width, @height, false
    self.caption = "stroids"

    @collider = Collider.new @width, @height
    @waves = WaveManager.new self

    @counter = FPSCounter.new self

    @score = Score.new self

    @asteroids = []
    @shots = []
    @effects = []

    # Instantiate overlays
    @title_font = Gosu::Font.new self, '04b_20', 32
    gameover_overlay = GameOver.new self, @title_font
    splash_overlay = SplashScreen.new self, @title_font
    splash_overlay.visible = true

    @overlays = {
        :score => @score,
        :splash => splash_overlay,
        :game_over => gameover_overlay,
    }
  end


  # Initialize game state
  def start_game
    @running = true
    @started = true
    @overlays[:score].visible = true
    @overlays[:game_over].visible = false
    @overlays[:splash].visible = false

    #Reset objects and state
    @asteroids = []
    @effects = []
    @shots = []

    #buffer to hold newly spawned asteroids until the next round
    @new_asteroids = []

    @ship = Ship.new(self)
    @ship.warp(400,300)

    @score.reset
    @waves.reset
  end

  #Player score accessor
  def score
    @score.score
  end

  def objects
    (@asteroids + @shots + [@ship]).compact
  end

  # Add an asteroid
  def add_asteroid(asteroid)
    asteroid.add_observer(self, :asteroid_updated)
    @asteroids << asteroid
  end

  def add_shot(shots)
    @shots.concat shots
    @ship.active_shots += shots.length
  end

  # Callback when asteroids are destroyed
  def asteroid_updated (asteroid, new_asteroids)
    @new_asteroids += new_asteroids
    # Add points
    unless asteroid.is_live?
      @score.add asteroid.points
      @ship.statistics.asteroids += 1
    end
  end
;;;;;;;
  # Wrap objects at screen edges
  def wrap_objects
    (objects + @effects).each do |item|
      item.vector.x %= @width
      item.vector.y %= @height
    end
  end

  # Button down event listeren
  def button_down(id)
    case id
      when Gosu::KbSpace
        start_game unless @running
      when Gosu::KbF1
        @counter.toggle_fps
      when Gosu::KbZ
        add_shot @ship.fire if @running && @ship.can_fire?
      when Gosu::KbF2
        @asteroids.each {|i| i.hit! nil} if @running
      when Gosu::KbEscape
        # return to splash screen
        if @running
          splash
        else
          exit
        end
      else
    end
  end


  def update
    return unless @started

    # Handle bullettime
    if button_down?(Gosu::KbX) && @running
      @tick = 5.0
      @ship.hyper = true
    else
      #reset tick on release or game end
      @tick = 1.0
      @ship.hyper = false
    end

    if button_down?(Gosu::KbUp) && @running
      @ship.thrust = true
    else
      @ship.thrust = false
    end

    if @running
      # Ship navigation
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
    if ! @ship.is_live? && @running
      @effects += @ship.effect
      game_over
    end

    #update effects
    @effects.each{|effect| effect.update @tick}

    # Go to next wave
    # TODO: Add delay
    @waves.next_wave if @asteroids.empty? && @running
  end

  def game_over
    @overlays[:game_over].visible = true
    @overlays[:score].visible = false
    @running = false
  end

  def splash
    @ship.health = 0
    @overlays[:score].visible = false
    @overlays[:splash].visible = true
    @running = false
    @splash = true
  end

  def draw
    #Update the fps counter
    @counter.update

    @overlays.each do |name, overlay|
      overlay.draw
    end

    objects.each(&:draw)
    @effects.each(&:draw)
  end
end

Game.new.show