require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'fuel'

class SectorFive < Gosu::Window
  WIDTH = 1920
  HEIGHT = 1080
  ENEMY_FREQUENCY = 0.08
  FUEL_FREQUENCY = 0.002
  red_screen = Gosu::Color::RED
  game_timer = 0

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @background_image = Gosu::Image.new('SPRITES/homepage.png')
    @scene = :start
    @start_music = Gosu::Song.new('homepage-music.mp3')
    @start_music.play(true)
  end

  def initialize_game
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
    @scene = :game
    @background = Gosu::Image.new('SPRITES/bg2.png', tileable: true)
    @score = 0
    @lives = 3
    @game_music = Gosu::Song.new('background-music.mp3')
    @game_music.play(true)
    @rs_display = false
    @red_screen = Gosu::Color::RED
    @lives1 = Gosu::Image.new('SPRITES/lives1.png', tileable: true)
    @lives2 = Gosu::Image.new('SPRITES/lives2.png', tileable: true)
    @lives3 = Gosu::Image.new('SPRITES/lives3.png', tileable: true)
    @font = Gosu::Font.new(100)
    @font_lost = Gosu::Font.new(200)
    @fuels = []
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

  def update
    case @scene
    when :game
      update_game
    when :end
      update_end
    end
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :game
      update_game
    when :end
      button_down_end(id)
    end
  end

  def button_down_start(id)
    initialize_game
  end

  def update_game
    if @lives == 0 or @player.get_fuel <= 0
      sleep(3)
      close!
    end

    @player.decrease_fuel
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    @player.move

    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY
    @fuels.push Fuel.new(self) if rand < FUEL_FREQUENCY

    @enemies.each {|enemy| enemy.move}
    @bullets.each {|bullet| bullet.move}
    @fuels.each {|fuel| fuel.move}

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

    def draw_game
      @lives1.draw(25, 50, 2) if @lives == 1
      @lives2.draw(25, 50, 2) if @lives == 2
      @lives3.draw(25, 50, 2) if @lives == 3
      @font.draw("SCORE: #{@score}", 1200, 50, 2)

      @player.draw
      @background.draw(0, 0, -1)
      @enemies.each {|enemy| enemy.draw}
      @bullets.each {|bullet| bullet.draw}
      @explosions.each {|explosion| explosion.draw}
      @fuels.each {|fuel| fuel.draw}


      draw_quad(20, 1000, @red_screen, 2*@player.get_fuel+20, 1000, @red_screen, 20, 1025, @red_screen, 2*@player.get_fuel+20, 1025, @red_screen)

      @font_lost.draw("YOU LOST!", 450, 500, 2) if @lives == 0 or @player.get_fuel <= 0
      if @rs_display and @lives != 0
        draw_quad(0, 0, @red_screen, 1920, 0, @red_screen, 1920, 1080, @red_screen, 0, 1080, @red_screen)
      end
      @rs_display = false
    end

  end
end

window = SectorFive.new
window.show
