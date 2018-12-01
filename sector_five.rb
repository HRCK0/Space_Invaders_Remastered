require 'gosu'

class SectorFive < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = 'Sector Five'
  end
end

wind = SectorFive.new
wind.show