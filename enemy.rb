class Enemy
  @@speed = 4
  attr_reader :x, :y, :radius
  def initialize(window)
    randint = rand(1..3)
    @radius = 50
    @x = rand(window.width - 2*@radius)+@radius
    @y = 0
    if randint ==1
      @image = Gosu::Image.new('SPRITES/enemysprite.png')
      @health = 3
      @pGo = 3
    elsif randint== 2
      @image = Gosu::Image.new('SPRITES/enemysprite2.png')
      @health = 2
      @pGo = 2
    elsif randint==3
      @image = Gosu::Image.new('SPRITES/enemysprite3.png')
      @health = 1
      @pGo = 1
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

  def speed_up
    @@speed += 0.5
  end

  def get_speed
    @@speed
  end

  def move
    @y += @@speed
  end

  def draw

    @image.draw(@x-@radius, @y-@radius, 1)


end
end
