class FPSCounter
  attr_accessor :show_fps
  attr_reader :fps

  def initialize(window)
    @font = window.load_font('BITLOW', 28)
    @frames_counter = 0
    @milliseconds_before = Gosu::milliseconds
    @show_fps = false
    @fps = 0
  end

  def toggle_fps
    @show_fps = !@show_fps
  end

  def update
    @frames_counter += 1
    if Gosu::milliseconds - @milliseconds_before >= 1000
      @fps = @frames_counter.to_f / ((Gosu::milliseconds - @milliseconds_before) / 1000.0)
      @frames_counter = 0
      @milliseconds_before = Gosu::milliseconds
    end
    @font.draw('%.1f' % fps, 600, 5, ZOrder::OVERLAY, 0.5, 0.5) if @show_fps
  end
end