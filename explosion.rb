class Explosion
  def initialize(window,x,y)
    @x = x
    @y = y
    @radius = 30
    @images = Gosu::Image.load_tiles('SPRITES/explosion.png',16,16)
    @counter = 1
    @image_index=0
    @finished = false
  end
  def draw
    if @image_index < @images.count
      @images[@image_index].draw(@x-@radius,@y-@radius,2)
      @counter+=1
      print @counter
      if @counter==7
        print "hello"
        @image_index+=1
        @counter = 1
      end
    else
      @finished = true
    end

  end

  def getfinished
    return @finished
  end

end