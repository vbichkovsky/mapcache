class MapPanel < Wx::Panel
  
  def initialize(parent, config)
    super(parent, :style => Wx::NO_BORDER)
    @pan = false
    DownloadManager.observer = self
    @mgr = MatrixManager.new(self.size.width, self.size.height, config)

    evt_paint {|event| draw_map}
    
    evt_size {|event| resize_map(event.size.width, event.size.height) }

    evt_char do |event|
      case event.key_code
        when ?m : toggle_coverage
        when ?[ : coverage_zoom_out
        when ?] : coverage_zoom_in
        when ?e : export_dialog
        when Wx::K_F1: about_box
      end
    end

    evt_left_down do |event| 
      pan_start(event.x, event.y)
      event.skip
    end

    evt_left_up {|event| pan_end}

    evt_motion {|event| pan(event.x, event.y) }

    evt_mousewheel do |event|
      if event.wheel_rotation > 0
        zoom_in(event.x, event.y)
      else
        zoom_out(event.x, event.y)
      end
    end

    parent.set_zoom(@mgr.zoom)
    parent.set_coverage_zoom(@mgr.cov_value)

    set_focus
  end

  def config
    @mgr.config
  end

  def tile_loaded(tile)
    self.refresh
  end

  private

  def draw_map
    paint {|dc| @mgr.draw(dc) }
  end

  def toggle_coverage
    draw_with_hourglass { @mgr.toggle_coverage }
    parent.set_coverage_zoom(@mgr.cov_value)
  end

  def zoom_in(x, y)
    draw_with_hourglass { @mgr.zoom_in(x, y) }
    parent.set_zoom(@mgr.zoom)
    parent.set_coverage_zoom(@mgr.cov_value)
  end

  def zoom_out(x, y)
    draw_with_hourglass { @mgr.zoom_out(x, y) }
    parent.set_zoom(@mgr.zoom)
    parent.set_coverage_zoom(@mgr.cov_value)
  end

  def coverage_zoom_in
    draw_with_hourglass { @mgr.coverage_zoom_in }
    parent.set_coverage_zoom(@mgr.cov_value)
  end

  def coverage_zoom_out
    draw_with_hourglass { @mgr.coverage_zoom_out }
    parent.set_coverage_zoom(@mgr.cov_value)
  end

  def export_dialog
    d = ExportDialog.new(parent)
    if d.show_modal == Wx::ID_OK
      MGMapsExport.export(d.tiles_per_file, d.hash_size)
    end
  end

  def resize_map(width, height)
    @mgr.resize(width, height)
  end

  def pan_start(x, y)
    @pan = true
    @start_x = x
    @start_y = y
  end

  def pan_end
    @pan = false
  end

  def pan(x, y)
    if @pan
      @mgr.pan(x - @start_x, y - @start_y)
      @start_x = x
      @start_y = y
      draw_map
    end
  end

  def draw_with_hourglass
    self.cursor = Wx::HOURGLASS_CURSOR
    yield
    draw_map
    self.cursor = Wx::NULL_CURSOR    
  end

  def about_box
    box = Wx::AboutDialogInfo.new
    box.name = "mapcache"
    box.version = "0.1"
    box.description = IO.read('README')
    box.add_developer 'Valentine Bichkovsky'
    Wx::about_box(box)
  end

end
