require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosions'

class SectorFive < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
  ENEMY_FREQUENCY = 0.05

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @background_image = Gosu::Image.new('SPRITES/desert-background.png')
    @scene = :start
  end

  def update
    case @scene
    when :game
      update_game
    when :end
      update_end
    end
  end

  def button_down(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @Player.y, @player_angle)
    end
  end

  def draw
    case @scene
    when :start
      draw_start
    when :game
      draw_game
    when :end
      draw_end
    end
  end

  def draw_start
    @background_image.draw(0,0,0)
  end

  def draw_game
    @player.draw
    @enemies.each {|enemy| enemy.draw}
    @bullets.each {|bullet| bullet.draw}
    @explosions.each {|explosion| explosion.draw}
  end



end

wind = SectorFive.new
wind.show
