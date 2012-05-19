class BullettimeOverlay

  def initialize(window, percent = 1.0)
    @window = window
    @percent = percent
  end

  def draw_rect(x,y,w,h,c)
    @window.draw_quad(x,y,c, x+w,y,c,x,y+h,c,x+w,y+h,c)
  end

  def update

  end

  def draw
    draw_rect(300, 10, 100 * @percent, 10, 0x66ffffff)
  end
end