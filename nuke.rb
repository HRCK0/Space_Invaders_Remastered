class Nuke
  SPEED = 5
  attr_reader :x, :y, :radius
  def initialize(window)
    @radius = 40
    @x = rand(window.width - 2*@radius)+@radius
    @y = 0
  end

  def move
    @y += SPEED
  end

  def draw
    rando = rand(4)
    if rando%2 == 0
      @image = Gosu::Image.new('SPRITES/nuke.png')
      @image.draw(@x-@radius, @y-@radius, 0)
    elsif rando%2 ==1
      @image = Gosu::Image.new('SPRITES/nuke2.png')
      @image.draw(@x-@radius, @y-@radius, 0)
    end

  end
end
