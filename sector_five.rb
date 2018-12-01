require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'

class SectorFive < Gosu::Window
  WIDTH = 1920
  HEIGHT = 1080
  ENEMY_FREQUENCY = 0.03

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
    @background = Gosu::Image.new('SPRITES/bg.png', tileable: true)
    @score = 0
    @font = Gosu::Font.new(45)
    @lives = 3
  end

  def update
    close! if @lives == 0
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move

    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY

    @enemies.each {|enemy| enemy.move} # might crash!!
    @bullets.each {|bullet| bullet.move}

    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu::distance(enemy.x, enemy.y, bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @enemies.delete enemy
          @bullets.delete bullet
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
          @score += 100
        end
      end
    end

    @enemies.each do |enemy|
      distance = Gosu::distance(@player.x, @player.y, enemy.x, enemy.y)
      if distance < enemy.radius
        @enemies.delete enemy
        @explosions.push Explosion.new(self, enemy.x, enemy.y)
        @lives -= 1
      end
    end
    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.get_finished
    end
    @enemies.dup.each do |enemy|
      if enemy.y > HEIGHT + enemy.radius
        @enemies.delete enemy
      end
    end
    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end
  end

  def button_down(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
    end

  end

  def draw
    @player.draw
    @background.draw(0, 0, 0)
    @enemies.each {|enemy| enemy.draw}
    @bullets.each {|bullet| bullet.draw}
    @explosions.each {|explosion| explosion.draw}
    @font.draw("SCORE: #{@score}; LIVES: #{@lives}", 900, 20, 2)
  end
end

wind = SectorFive.new
wind.show

