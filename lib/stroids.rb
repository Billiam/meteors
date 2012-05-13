require 'gosu'
require 'observer'
require 'texplay'

require './stroids/game_object'
require './stroids/stroids_state'
require './stroids/particle'


Dir["./stroids/*.rb"].each do |file|
  require file
end

if __FILE__ == $0
  Game.new.show
end