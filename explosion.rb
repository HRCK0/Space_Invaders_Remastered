class Explosion
  def initialize(window,x,y)
    @x = x
    @y = y
    @radius = 30
    @images = Gosu::Image.load_tiles('SPRITES/explosion.png',16,16)
    @image_index = 0
    @finished = false
  end

  def get_finished
    @finished
  end

  def draw
    if @image_index < @images.count
      @images[@image_index].draw(@x-@radius,@y-@radius,2)
      @image_index += 1
    else
      @finished = true
    end

  end

end