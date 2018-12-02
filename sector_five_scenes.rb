require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'fuel'
require_relative 'nuke'

# noinspection RubyScope,RubyResolve,RubyTooManyInstanceVariablesInspection
class SectorFiveScenes < Gosu::Window
  WIDTH = 1920
  HEIGHT = 1080
  ENEMY_FREQUENCY = 0.08
  FUEL_FREQUENCY = 0.002
  NUKE_FREQUENCY = 0.0001
  # noinspection RubyUnusedLocalVariable
  red_screen = Gosu::Color::RED
  # noinspection RubyUnusedLocalVariable
  game_timer = 0

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @background_image = Gosu::Image.new('SPRITES/homepage.png')
    @scene = :start
    @start_music = Gosu::Song.new('MUSIC/homepage-music.mp3')
    @start_music.play(true)
    @game_timer = 1
  end

  def initialize_game
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @player = Player.new(self)
    @enemies = []
    @bullets = []
    @explosions = []
    @nukes = []
    @scene = :game
    @background = Gosu::Image.new('SPRITES/bg2.png', tileable: true)
    @score = 0
    @lives = 3
    @game_music = Gosu::Song.new('MUSIC/background-music.mp3')
    @game_music.play(true)
    @rs_display = false
    @red_screen = Gosu::Color::RED
    @black_colour = Gosu::Color::BLACK
    @red_screen = Gosu::Color::RED
    @lives1 = Gosu::Image.new('SPRITES/lives1.png', tileable: true)
    @lives2 = Gosu::Image.new('SPRITES/lives2.png', tileable: true)
    @lives3 = Gosu::Image.new('SPRITES/lives3.png', tileable: true)
    # noinspection RubyArgCount
    @font = Gosu::Font.new(100)
    @fuels = []
    @game_timer = 1
    @explosion_sound = Gosu::Sample.new('MUSIC/explosion.aiff')
    @shooting_sound = Gosu::Sample.new('MUSIC/laser-beam.aiff')
    @nuke_sound = Gosu::Sample.new('MUSIC/nuke.wav')
    @life_sound = Gosu::Sample.new('MUSIC/extra-life.mp3')
    @death_sound = Gosu::Sample.new('MUSIC/death-sound.wav')
    @count = 0
    @game_quicker_speedup_counter = 0
  end

  def initialize_end
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @end_background = Gosu::Image.new('SPRITES/gameover-background.png')
    @scene = :end
    @end_music = Gosu::Song.new('MUSIC/gameover-music.mp3')
    @end_music.play(true)
    # noinspection RubyArgCount
    @font_lost = Gosu::Font.new(300)
  end

  def draw
    # noinspection RubyCaseWithoutElseBlockInspection
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

  def draw_end
    @end_background.draw(0,0,0)
    @font.draw(@score, 960, 480, 2)
  end

  def update
    # noinspection RubyCaseWithoutElseBlockInspection
    case @scene
    when :game
      update_game
    end
  end

  def button_down(id)
    # noinspection RubyCaseWithoutElseBlockInspection
    case @scene
    when :start
      button_down_start(id)
    when :game
      button_down_game(id)
    when :end
      button_down_end(id)
    end
  end

  def button_down_start(_id)
    initialize_game
  end

  def button_down_game(id)
    if id == Gosu::KbSpace
      @bullets.push Bullet.new(self, @player.getxCoord, @player.getyCoord, @player.getAngle)
      @shooting_sound.play
    end

  end

  def  button_down_end(id)
    if id == Gosu::KbP
      @game_timer = 1
      @enemies.each(&:reset_speed)
      initialize
      elsif id == Gosu::KbQ
        close!
    end
  end

  def update_game


    # Checks if end-game conditions have been met
    if @lives == 0 or @player.get_fuel <= 0
       initialize_end
    end

    @game_timer += 1
    # Takes player input
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)

    # Moves the player and decreases fuel
    @player.decrease_fuel
    @player.move

    # Adds enemies and fuels
    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY
    @fuels.push Fuel.new(self) if rand < FUEL_FREQUENCY
    @nukes.push Nuke.new(self) if rand < NUKE_FREQUENCY
    @fules.push Fule.new(self) if @player.get_fuel == 10

    # Moves enemies, bullets and fuel
    @enemies.each(&:move)
    @bullets.each(&:move)
    @fuels.each(&:move)
    @nukes.each(&:move)

    # Checking if enemies have b  een hit by the bullet
    @enemies.dup.each do |enemy|
      @bullets.dup.each do |bullet|
        distance = Gosu::distance(enemy.x, enemy.y  ,  bullet.x, bullet.y)
        if distance < enemy.radius + bullet.radius
          @bullets.delete bullet
          enemy.decrease_hp
          if enemy.get_health == 0
            @explosion_sound.play
            @explosions.push Explosion.new(self, enemy.x, enemy.y)
            @enemies.delete enemy
            if enemy.get_pt == 3
            @score += 1000
            elsif enemy.get_pt==2
              @score+= 600
              elsif enemy.get_pt == 1
              @score+= 300
          end
        end
      end
    end

    # Checks if the player collided with an enemy
    @enemies.dup.each do |enemy|
      distance = Gosu::distance(@player.x, @player.y, enemy.x, enemy.y)
      if distance < enemy.radius + @player.radius
        @enemies.delete enemy
        @explosions.push Explosion.new(self, enemy.x, enemy.y)
        @rs_display = true
        @lives -= 1
        @score += 500
        @death_sound.play
      end
    end

    # Checks if the player collected the fuel
    @fuels.dup.each do |fuel|
      distance = Gosu::distance(@player.x, @player.y, fuel.x, fuel.y)
      if distance < fuel.radius + @player.radius
        @player.reset_fuel
        @fuels.delete fuel
      end
    end

     @nukes.dup.each do |nuke|
        distance = Gosu::distance(@player.x, @player.y, nuke.x, nuke.y)
        if distance < nuke.radius + @player.radius
          @nukes.delete nuke
          @nuke_sound.play
          @enemies.dup.each do |enemy|
            @explosions.push Explosion.new(self, enemy.x, enemy.y)
            @enemies.delete enemy
          end
        end
      end

    # Ends explosion effect
    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.getfinished
    end

    # Removing either destroyed enemies or collided enemies
    @enemies.dup.each do |enemy|
      if enemy.y > HEIGHT + enemy.radius
        @enemies.delete enemy
      end
    end

    # removes bullets that exit the screen or hit an enemy
    @bullets.dup.each do |bullet|
      @bullets.delete bullet unless bullet.onscreen?
    end


    if @game_timer % (930 - @game_quicker_speedup_counter) == 0
      @enemies.each do |enemy|
        enemy.speed_up
        enemy.speed_up if @game_quicker_speedup_counter > 0
      end
      @game_timer = 1
      @count += 1
      if @count > 3 - (@game_quicker_speedup_counter / 100)
        enemy.reset_speed
        @count = 0
        if @lives < 3
          @lives += 1
          @life_sound.play
        end
        @game_quicker_speedup_counter += 100
      end
    end
  end

  def draw_game
    # Displays lives and score
    @lives1.draw(25, 50, 2) if @lives == 1
    @lives2.draw(25, 50, 2) if @lives == 2
    @lives3.draw(25, 50, 2) if @lives == 3
    @font.draw("Score: #{@score}", 1200, 50, 2)

    # Display player, background, enemies bullets, explosions, fuels
    @player.draw
    @background.draw(0, 0, -1)
    @enemies.each(&:draw)
    @bullets.each(&:draw)
    @explosions.each(&:draw)
    @fuels.each(&:draw)
    @nukes.each(&:draw)

    # Fuel bar display
    draw_quad(20, 1000, @black_colour, 220, 1000, @black_colour, 20, 1025, @black_colour, 220, 1025, @black_colour)
    draw_quad(20, 1000, @red_screen, 2*@player.get_fuel+20, 1000, @red_screen, 20, 1025,
              @red_screen, 2*@player.get_fuel+20, 1025, @red_screen)


    # Red splash screen upon player getting hit
    if @rs_display and @lives != 0
      draw_quad(0, 0, @red_screen, 1920, 0, @red_screen, 1920, 1080, @red_screen, 0, 1080, @red_screen)
    end
      @rs_display = false
    end
  end
end


window = SectorFiveScenes.new
window.show
