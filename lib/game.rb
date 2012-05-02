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

  def wrap_objects
    @objects.each do |item|
      item.x %= @width
      item.y %= @height
    end
  end

  def update
    if button_down? Gosu::KbLeft
      @ship.turn_left
    elsif button_down? Gosu::KbRight
      @ship.turn_right
    end

    if button_down? Gosu::KbUp
        @ship.accelerate
    end

    if button_down? Gosu::KbSpace
      @shots.concat @ship.fire
    end

    @asteroids.each {|item| item.update }
    @shots.each {|item| item.update }
    @ship.update

    # Check collision

    @shots.reject do |shot|
      shot.is_dead?
    end

    wrap_objects
  end

  def draw
    @asteroids.each {|item| item.draw }
    @shots.each {|item| item.draw }
    @ship.draw

  end
end

Game.new.show