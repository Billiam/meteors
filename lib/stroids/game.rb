class Game < Gosu::Window
  MEDIA = File.realpath(File.join(BASE_PATH, '..', 'media'))

  attr_accessor :state, :height, :width

  # Display cursor
  def needs_cursor?
    true
  end

  def initialize
    # Disable caching by default
    # Large performance hit during all image creatiion
    TexPlay::set_options :caching => false

    # Disable antialiazing during image transform
    Gosu::enable_undocumented_retrofication

    @width = 800
    @height = 600

    super @width, @height, false
    self.caption = 'Meteors'

    @counter = FPSCounter.new self

    #Set current state to splash screen
    @state = SplashState.new self

    @background = TexPlay::create_blank_image(self, @width, @height, {:color => [0.08, 0.08, 0.08, 1]})
  end

  def state=(state)
    @state.teardown
    state.setup
    @state = state
  end

  #pass button events through to active state
  def button_up(id)
    @state.button_up id
  end

  def button_down(id)
    case id
      when Gosu::KbF1
        @counter.toggle_fps
      else
    end

    @state.button_down id
  end

  # Pass update through to active state
  def update
    @state.update
  end

  # Draw the state and state-independant items
  def draw
    @background.draw 0, 0, ZOrder::BACKGROUND
    @counter.update
    @state.draw
  end


  # Load and cache images from media path
  def load_image(name, options=[])
    @images ||= {}
    @images[name] ||= Gosu::Image.new self, File.join(MEDIA, "#{name}.png"), *options
  end

  # Load and cache sounds from media path
  def load_sound(name)
    @sounds ||= {}
    @sounds[name] ||= Gosu::Sample.new self, File.join(MEDIA, 'audio', "#{name}.wav")
  end


  def font_image(text, font = '04B09', size = 10)
    @font_images ||= {}
    @font_images[[text, font, size]] ||= Gosu::Image.from_text(self, text, font_path(font), size)
  end

  # Load and cache fonts from media path
  def load_font(name, size)
    @fonts ||= {}
    @fonts[[name,size]] ||= Gosu::Font.new self, font_path(name), size
  end

  #Create an overlay with texplay (expensive))
  def dark_overlay
    @overlay ||= TexPlay::create_blank_image(self, @width, @height, {:color => [0, 0, 0, 0.6 ]})
  end

  protected

  def font_path(name)
    File.join(MEDIA, 'fonts', "#{name}.ttf")
  end
end