class Timers

  class Timeout

    attr_reader :callback

    def initialize(time, callback)
      @time = time
      @callback = callback
    end

    def expired?(now)
      now >= @time
    end
  end

  def initialize
    @timers = []
  end

  def update
    now = Gosu::milliseconds
    @timers.delete_if do |timer|
      if timer.expired? now
        timer.callback.call
        true
      end
    end
  end

  def set_timeout(time, &block)
    @timers.push Timeout.new(Gosu::milliseconds + time, block)
  end

end