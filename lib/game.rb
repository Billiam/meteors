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

    @title_font = Gosu::Font.new(self, 'DokChampa', 24)
  end

  def start_game
    @splash = false
    @running = true

    @asteroids = []
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

  # Callback when asteroids are destroyed
  def asteroid_updated (asteroid, new_asteroids)
    @new_asteroids += new_asteroids
    # Add points
    unless asteroid.is_live?
      @score.add asteroid.points
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
        @shots.concat(@ship.fire)
      when Gosu::KbF2
        @asteroids.each {|i| i.hit! nil}
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

    # remove asteroids
    @asteroids.reject! do |asteroid|
      ! asteroid.is_live?
    end

    #add newly spawned asteroids
    @new_asteroids.each{|item| add_asteroid(item)}
    @new_asteroids = []

    @waves.next_wave if @asteroids.empty?
  end

  def game_over
    @running = false
  end

  def splash_screen
    @title_font.draw("GAME!", 175, 120, 50, 2.8, 2.8)
    @title_font.draw("press SPACE to start", 216, 345, 50, 1, 1)
  end

  def end_screen
    @title_font.draw("GAME OVER!", 175, 120, 50, 2.8, 2.8)
    @title_font.draw("Final score: #{@score.score}", 216, 345, 50, 2.8, 2.8)
  end

  def draw
    #Update the fps counter
    @counter.update
    @score.draw
    #Draw objects
    if @running
      objects.each {|item| item.draw }
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