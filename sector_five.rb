require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'

class SectorFive < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @player = Player.new(self)
  end

  def update
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move
  end

end

wind = SectorFive.new
wind.show
