$: << 'stroids'

require 'gosu'
require 'ship'
require 'asteroid'
require 'shot'
class Game < Gosu::Window

  GAME_WIDTH = 800
  GAME_HEIGHT = 600
  def initialize
    @width = GAME_WIDTH
    @height = GAME_HEIGHT

    super @width, @height, false
    self.caption = "stroids"

    @tick = 1.0
    @ship = Ship.new(self)
    @ship.warp(400,300)
    @asteroids = []
    @shots = []

    10.times do
      asteroid = Asteroid.new(self)
      asteroid.x = rand 800
      asteroid.y = rand 600

      @asteroids << asteroid
    end

  end

  def objects
    (@asteroids + @shots).push(@ship)
  end

  def wrap_objects
    objects.each do |item|
      item.x %= @width
      item.y %= @height
    end
  end

  def update
    if button_down? Gosu::KbX
      @tick = 5.0
      @ship.hyper = true
    else
      @tick = 1.0
      @ship.hyper = false
    end


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

    objects.each {|item| item.update @tick }

    # Check collision

    @shots = @shots.reject do |shot|
      shot.is_dead?
    end

    wrap_objects
  end

  def draw
    objects.each {|item| item.draw }
  end
end

Game.new.show