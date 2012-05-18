require 'gosu'
require 'observer'
require 'texplay'
require 'rquad'

prerequisites = %w(game_object stroids_state particle)
BASE_PATH = File.dirname(File.absolute_path(__FILE__))

prerequisites.each do |file|
  require File.join(BASE_PATH, 'stroids', file)
end

Dir[File.join(BASE_PATH, 'stroids', '*.rb')].each do |file|
  require file
end

if __FILE__ == $0
  Game.new.show
end