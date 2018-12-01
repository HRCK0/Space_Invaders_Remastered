class Nuke
  SPEED = 2
  attr_reader :x, :y, :radius
  def initialize(window)
    @radius = 40
    @x = rand(window.width - 2*@radius)+@radius
    @y = 0
    @image = Gosu::Image.new('SPRITES/nuke.png')
  end

  def move
    @y += SPEED
  end

  def draw
    @image.draw(@x-@radius, @y-@radius, 0)
  end
end
