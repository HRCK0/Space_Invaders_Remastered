# noinspection RubyInstanceVariableNamingConvention
class Life
  SPEED = 6
  attr_reader :x, :y, :radius
  def initialize(window)
    @radius = 50
    @x = rand(window.width - 2*@radius)+@radius
    @y = 0
    @image = Gosu::Image.new('SPRITES/fuel.png')
  end

  def move
    @y += SPEED
  end

  def draw
    @image.draw(@x-@radius, @y-@radius, 1)
  end
end
