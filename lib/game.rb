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


class Game < Gosu::Window

  GAME_WIDTH = 800
  GAME_HEIGHT = 600

  def initialize
    @width = GAME_WIDTH
    @height = GAME_HEIGHT
    @tick = 1.0

    Gosu::enable_undocumented_retrofication

    super @width, @height, false
    self.caption = "stroids"

    @collider = Collider.new @width, @height
    @waves = WaveManager.new self
    @counter = FPSCounter.new self
    @score = Score.new self
    @splash = true

    @title_font = Gosu::Font.new self, '04b_20', 32
  end

  def start_game
    @splash = false
    @running = true

    @asteroids = []
    @effects = []

    #buffer to hold newly spawned asteroids until the next round
    @new_asteroids = []

    @shots = []

    @ship = Ship.new(self)
    @ship.warp(400,300)

    @score.reset
    @waves.reset
  end

  def objects
    (@asteroids + @shots + [@ship])
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

  # Wrap objects at screen edges
  def wrap_objects
    objects.each do |item|
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
          @running = false
          @splash = true
        else
          exit
        end
      else
    end
  end

  def update
    return unless @running

    # Handle bullettime
    if button_down? Gosu::KbX
      @tick = 5.0
      @ship.hyper = true
    else
      @tick = 1.0
      @ship.hyper = false
    end

    # Ship navigation
    if button_down? Gosu::KbLeft
      @ship.turn_left @tick
    elsif button_down? Gosu::KbRight
      @ship.turn_right @tick
    end

    if button_down? Gosu::KbUp
      @ship.thrust = true
    else
      @ship.thrust = false
    end

    #move all objects
    objects.each {|item| item.update @tick }

    #wrap objects at screen edges
    wrap_objects

    #update collider data and check for collisions
    @collider.update @asteroids, @shots, @ship
    @collider.notify_collisions

    # check for player death
    unless @ship.is_live?
      game_over
      return
    end

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

    @effects.reject! do |effect|
      effect.is_dead?
    end

    #add newly spawned asteroids
    @new_asteroids.each{|item| add_asteroid(item)}
    @new_asteroids = []

    #update effects
    @effects.each{|effect| effect.update @tick}

    # Go to next wave
    # TODO: Add delay
    @waves.next_wave if @asteroids.empty?
  end

  def game_over
    @running = false
  end


  def splash_screen
    image = Gosu::Image.from_text(self, "TOTALLY NOT ASTEROIDS", "Komika Boogie", 84)
    image.draw 175, 120, 50
    @title_font.draw("press SPACE to start", 175, 345, 50, 0.3, 0.3)
  end

  def end_screen
    image = Gosu::Image.from_text(self, " Game Over!", "Komika Boogie", 128)
    image.draw 175, 120, 50

    @title_font.draw("Final score: #{@score.score}", 175, 345, 50, 0.5, 0.5)
    accuracy = @ship.statistics.shots == 0 ? 100 : (@ship.statistics.asteroids / @ship.statistics.shots.to_f * 100).floor

    #draw statistics
    pos = 385
    [
      "Shots: #{@ship.statistics.shots}",
      "Kills: #{@ship.statistics.asteroids}",
      "Accuracy: %.1f%" % accuracy,
      "Fuel Used: %.1f lbs" % @ship.statistics.fuel,
    ].each {|item|
      @title_font.draw item, 175, pos, 50, 0.3, 0.3
      pos += 20
    }
  end

  def draw
    #Update the fps counter
    @counter.update
    #Draw objects
    if @running
      @score.draw
      objects.each(&:draw)
      @effects.each(&:draw)
    else
      #TODO: move to overlays
      if @splash
        splash_screen
      else
        end_screen
      end
    end
  end
end

Game.new.show