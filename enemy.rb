class Enemy
  @@speed = 4
  attr_reader :x, :y, :radius
  def initialize(window, level)
    @radius = 50
    @x = rand(window.width - 2*@radius)+@radius
    @y = 0
    randint = rand((level/2).to_i..level)
    if randint <= 2
      @image = Gosu::Image.new('SPRITES/enemysprite3.png')
      @health = 1
      @pGo = 1
    elsif randint <= 4
      @image = Gosu::Image.new('SPRITES/enemysprite2.png')
      @health = 2
      @pGo = 2
    elsif randint > 4
      @image = Gosu::Image.new('SPRITES/enemysprite.png')
      @health = 3
      @pGo = 3
    end

    #@speed = 4
  end

  def decrease_hp
    @health -= 1
  end
  def get_health
    @health
  end

  def get_pt
    @pGo
  end

  def speed_up(level)
    @@speed += 0.1*level
  end

  def reset_speed
    @@speed = 4
  end

  def move
    @y += @@speed
  end

  def draw

    @image.draw(@x-@radius, @y-@radius, 1)


end
end
