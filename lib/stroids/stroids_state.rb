class StroidsState
  def initialize(window)
    @timers = {}
    @tick_count = 0.0
    @window = window
  end

  def button_up(id)
  end

  def button_down(id)
  end

  def setup
  end

  def update_counter
    @tick_count += 1
  end

  def update
    update_counter
    run_timers
  end

  def run_timers
    @timers.delete_if do |time, callback|
      if time < @tick_count
        callback.call
        true
      end
    end
  end

  def teardown
  end

  def draw
  end

  def later(time, &block)
    @timers[time + @tick_count] = block
  end

  def button_down? id
    @window.button_down? id
  end

  def button_up? id
    @window.button_up? id
  end
end