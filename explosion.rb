# noinspection RubyResolve,RubyInstanceVariableNamingConvention
class Explosion
  def initialize(window,x,y)
    @x = x
    @y = y
    @radius = 30
    @images = Gosu::Image.load_tiles('SPRITES/explosion.png',62,62)
    @counter = 1
    @image_index=0
    @finished = false
  end
  def draw
    if @image_index < @images.count
      @images[@image_index].draw(@x-@radius,@y-@radius,2)
      @counter+= 1
      if @counter==4
        @image_index+=1
        @counter = 1
      end
    else
      @finished = true
    end

  end

  def getfinished
    @finished
  end

end