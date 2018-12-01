class Enemy
  @@speed = 4
  attr_reader :x, :y, :radius
  def initialize(window)
    @radius = 50
    @x = rand(window.width - 2*@radius)+@radius
    @y = 0
    @image = Gosu::Image.new('SPRITES/enemysprite.png')
    #@speed = 4
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

