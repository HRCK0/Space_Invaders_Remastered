class Power_Up

  SPEED = 2.5
  attr_reader :x, :y, :radius

  def initialize(xcord, ycord)
    @radius = 30
    @x = xcord
    @y = ycord
    @image = Gosu::Image.new('SPRITES/power_up.png')
  end

  def move
    @y += SPEED
  end

  def draw
    @image.draw(@x-@radius, @y-@radius, 1)
  end
end
