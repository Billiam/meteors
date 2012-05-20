class Bullettime
  include Observable

  DURATION = 3 * 60

  def initialize(window)
    @window = window

    @bullettime = false
    @used = 0.0

    init_sound
  end

  def reset!
    @used = 0.0
  end

  #restore a percentage of bullettime
  # 100 will fully restore bullettime mode
  def restore(percent=1.0)
    percent /= 100
    @used = [0.0, @used - DURATION * percent].max
  end

  def can_enable?
    percent > 0
  end

  def disable
    @sound_instance.stop if @sound_instance
    set_bullettime(false)
  end

  def enable
    if can_enable?
      @sound_instance = @sound.play 0.1
      set_bullettime(true)
    end
  end

  def update
    if @bullettime
      @used += 1
      disable if @used >= DURATION
    end
  end

  def draw
    draw_bordered_rect(300, 10, 100, 10, 1, 0xff999999, ZOrder::GUI)
    draw_rect(300, 10, 100 * percent, 10, 0x33ffffff, ZOrder::GUI)
  end

  protected

  def init_sound
    @sound_instance = nil
    @sound = @window.load_sound('matrix')
  end

  def draw_bordered_rect(x, y, w, h, thickness, color, z=0)
    draw_rect(x, y, w, thickness, color, z)
    draw_rect(x + w, y, thickness, h + thickness, color, z)
    draw_rect(x, y + h, w, thickness, color, z)
    draw_rect(x, y, thickness, h + thickness, color, z)
  end

  def draw_rect(x,y,w,h,c,z=0)
    @window.draw_quad(x,y,c, x+w,y,c,x,y+h,c,x+w,y+h,c, z)
  end

  def percent
    1 - @used / DURATION
  end

  def set_bullettime(enable)
    @bullettime = enable
    changed
    notify_observers enable
  end
end