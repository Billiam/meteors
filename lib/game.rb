$: << 'stroids'

require 'gosu'
require 'collider'
require 'ship'
require 'asteroid'
require 'shot'
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

    @asteroids = []
    @shots = []

    @ship = Ship.new(self)
    @ship.warp(400,300)

    # Temp asteroid creation code
    10.times do
      asteroid = Asteroid.new(self)
      asteroid.warp rand(800), rand(600.0)

      @asteroids_quad
      @asteroids << asteroid

      @collider = Collider.new @width, @height
    end


    @counter = FPSCounter.new self
  end

  def objects
    (@asteroids + @shots + [@ship])
  end

  def wrap_objects
    objects.each do |item|
      item.vector.x %= @width
      item.vector.y %= @height
    end
  end

  # Button dows event listeren
  def button_down(id)
    @counter.show_fps = true if id === Gosu::KbF1
  end

  def update
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
        @ship.accelerate
    end

    if button_down? Gosu::KbZ
      @shots.concat @ship.fire
    end

    #move all objects
    objects.each {|item| item.update @tick }

    #wrap objects at screen edges
    wrap_objects

    @collider.update @asteroids, @shots, @ship
    @collider.notify_collisions

    #expire shots
    @shots = @shots.reject do |shot|
      ! shot.is_live?
    end

    @asteroids.reject! do |asteroid|
      ! asteroid.is_live?
    end

  end

  def draw
    @counter.update

    objects.each {|item| item.draw }
  end
end

Game.new.show