require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'fuel'
require_relative 'nuke'

class SectorFive < Gosu::Window
  WIDTH = 1920
  HEIGHT = 1080
  ENEMY_FREQUENCY = 0.08
  FUEL_FREQUENCY = 0.002
  NUKE_FREQUENCY = 0.0008
  @@x = 20
  @@y = 20
  @@bullet_frequency = 10
  @@bulb_counter_blue = 50
  @@bulb_counter_red = 50
  @@blue_bulb_change = true
  @@red_bulb_change = true
  @@nuke_collected = false
  red_screen = Gosu::Color::RED
  #game_timer = 0

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
    @background = Gosu::Image.new('SPRITES/bg.png', tileable: true)
    @score = 0
    @lives = 3
    @rs_display = false
    @red_screen = Gosu::Color::RED
    @black_colour = Gosu::Color::BLACK
    @red_screen = Gosu::Color::RED

    # UI
    @hub = Gosu::Image.new('UI/hub.png', tileable: true)
    @hub_nuke1 = Gosu::Image.new('UI/hub_nuke1.png', tileable: true)
    @hub_nuke2 = Gosu::Image.new('UI/hub_nuke2.png', tileable: true)
    @empty_bars = Gosu::Image.new('UI/hp fuel bar.png', tileable: true)
    @hp_bar = Gosu::Image.new('UI/hp bar.png', tileable: true)
    @fuel_bar = Gosu::Image.new('UI/fuel bar.png', tileable: true)
    @hub_red_end = Gosu::Image.new('UI/red end.png', tileable: true)
    @hub_blue_end = Gosu::Image.new('UI/blue end.png', tileable: true)
    @glowing_bulb = Gosu::Image.new('UI/glowing bulb.png', tileable: true)
    @red_bar = Gosu::Image.new('UI/hp bar.png', tileable: true)
    @blue_bar = Gosu::Image.new('UI/fuel bar.png', tileable: true)

    @font = Gosu::Font.new(100)
    @fuels = []
    @game_timer = 1
    @file_highest_score= open('record.txt').read

    #Sounds and Music
    @game_music = Gosu::Song.new('MUSIC/background-music.mp3')
    @game_music.play(true)
    @explosion_sound = Gosu::Sample.new('MUSIC/explosion.aiff')
    @shooting_sound = Gosu::Sample.new('MUSIC/laser-beam.aiff')
    @nuke_sound = Gosu::Sample.new('MUSIC/nuke.wav')
    @life_sound = Gosu::Sample.new('MUSIC/extra-life.mp3')
    @death_sound = Gosu::Sample.new('MUSIC/death-sound.wav')

    @count = 0
    @level = 1
  end

  def initialize_end
    self.caption = 'Space Invaders - Remastered (404 Games)'
    @end_background = Gosu::Image.new('SPRITES/gameover-background.png')
    @scene = :end
    @end_music = Gosu::Song.new('MUSIC/gameover-music.mp3')
    @end_music.play(true)
    @font_lost = Gosu::Font.new(300)
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

  def draw_end
    @end_background.draw(0,0,0)
    @font.draw(@score, 960, 480, 2)

    read_high_score = open('record.txt').read

    if read_high_score.to_i < @score
      @font.draw("NEW HIGH SCORE:  #{@score}", 300, 620, 2)
      File.open('record.txt', 'w+') do |file|
        file.write(@score)
        file.close
      end
    else
      @font.draw("High Score:  #{read_high_score}", 460, 620, 2)
    end
  end


  def update
    case @scene
    when :game
      update_game
    end
  end

  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :game
      button_down_game(id)
    when :end
      button_down_end(id)
    end
  end

  def button_down_start(id)
    initialize_game
  end

  def button_down_game(id)
    if id == Gosu::KbSpace and @@nuke_collected
      @@nuke_collected = false
      @nuke_sound.play
      @enemies.dup.each do |enemy|
        @explosions.push Explosion.new(self, enemy.x, enemy.y)
        @score += 300
        @enemies.delete enemy
      end
    end
  end

  def  button_down_end(id)
    if id == Gosu::KbP
      @game_timer = 1
      @enemies.each do |enemy|
        enemy.reset_speed
      end
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

    # Game length in fps (@gamer_timer=60 == 1 second)
    @game_timer += 1

    # Takes player input
    @player.turn_left if button_down?(Gosu::KbLeft)
    @player.turn_right if button_down?(Gosu::KbRight)
    @player.accelerate if button_down?(Gosu::KbUp)
    if @game_timer % @@bullet_frequency == 0
      @bullets.push Bullet.new(self, @player.getxCoord, @player.getyCoord, @player.getAngle)
      @shooting_sound.play
    end


    # Moves the player and decreases fuel
    @player.decrease_fuel
    @player.move

    # Adds enemies and fuels
    @enemies.push Enemy.new(self, @level) if rand < ENEMY_FREQUENCY


    @fuels.push Fuel.new(self) if rand < FUEL_FREQUENCY
    @nukes.push Nuke.new(self) if rand < NUKE_FREQUENCY
    # @fuels.push Fuel.new(self) if @player.get_fuel == 10

    # Moves enemies, bullets and fuel
    @enemies.each do |enemy|
      enemy.move_xy(@@x, @@y)
      @@x += 100
      @@y += 100
    end
    @@x = 20
    @@y = 20

    @bullets.each {|bullet| bullet.move}
    @fuels.each {|fuel| fuel.move}
    @nukes.each {|nuke| nuke.move}

    # Checking if enemies have been hit by the bullet
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
          #@@bullet_frequency -= 1 if @@bullet_frequency > 1
          @fuels.delete fuel
        end
      end

      #Checks if the player collected the nuke
      @nukes.dup.each do |nuke|
        distance = Gosu::distance(@player.x, @player.y, nuke.x, nuke.y)
        if distance < nuke.radius + @player.radius
          @@nuke_collected = true
          @nukes.delete nuke
        end
      end

      # Ends explosion effect
      @explosions.dup.each do |explosion|
        @explosions.delete explosion if explosion.getfinished()
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

      # Level updater
      if @game_timer % (510) == 0
        @enemies.each do |enemy|
          enemy.speed_up(@level)
        end
        @game_timer = 1
        @count += 1
        if @count > 3
          enemy.reset_speed
          @count = 0
          @level += 1
          if @lives < 10
            @lives += 1
            @life_sound.play
          end
        end
      end
    end

    def draw_game

      # @font.draw("SCORE: #{@score}", 1200, 50, 2)
      @font.draw("Score: #{@score}", 1200, 50, 2)

      # Display player, background, enemies bullets, explosions, fuels
      @player.draw
      @background.draw(0, 0, -1)
      @enemies.each {|enemy| enemy.draw}
      @bullets.each {|bullet| bullet.draw}
      @explosions.each {|explosion| explosion.draw}
      @fuels.each {|fuel| fuel.draw}
      @nukes.each {|nuke| nuke.draw}

      #UI
      #Draws Nuke on Hub if collected
      @hub.draw(20, 950, 3)
      if @@nuke_collected
        if @game_timer % 5 == 0
          @hub_nuke1.draw(20, 950, 3)
        else
          @hub_nuke2.draw(20, 950, 3)
        end
      end

      # HP and Fuel Bards
      @empty_bars.draw(173, 958, 3)
      @empty_bars.draw(173, 994, 3)
      @hub_red_end.draw(322, 955, 3)

      #Low HP bulb notification
      if @lives <= 2 && @@bulb_counter_red > 0 && @@red_bulb_change
        @glowing_bulb.draw(322, 944, 3)
        @@bulb_counter_red -= 1
      else
        @hub_red_end.draw(322, 955, 3)
        @@bulb_counter_red += 1 if @lives <= 2
        @@red_bulb_change = false
        @@red_bulb_change = true if @@bulb_counter_red == 50
      end

      # Low fuel bulb notification
      if @player.get_fuel < 30 && @@bulb_counter_blue > 0 && @@blue_bulb_change
        @glowing_bulb.draw(322, 980, 3)
        @@bulb_counter_blue -= 1
      else
        @hub_blue_end.draw(322, 991, 3)
        @@bulb_counter_blue += 1 if @player.get_fuel < 30
        @@blue_bulb_change = false
        @@blue_bulb_change = true if @@bulb_counter_blue == 50
      end

      #Draws appropriate number of bars for HP and Fuel
      for i in 0..@lives-1
        @red_bar.draw(173 + 15*i, 958, 3)
      end

      for j in 0..(@player.get_fuel / 10).to_i
        @blue_bar.draw(173+15*j, 994, 3)
      end


      # Red splash screen upon player getting hit
      if @rs_display and @lives != 0
        draw_quad(0, 0, @red_screen, 1920, 0, @red_screen, 1920, 1080, @red_screen, 0, 1080, @red_screen)
      end
      @rs_display = false
    end
  end
end

window = SectorFive.new
window.show
