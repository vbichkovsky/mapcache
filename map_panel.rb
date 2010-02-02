require 'download_manager.rb'
require 'matrix_manager.rb'
require 'export_dialog.rb'
require 'mgmaps_export.rb'

class MapPanel < Wx::Panel
  
  def initialize(parent, config)
    super(parent, :style => Wx::NO_BORDER)

    DownloadManager.observer = self

    @mgr = MatrixManager.new(self.size.width, self.size.height, config)

    evt_paint {|event| draw_map}

    evt_size {|event| @mgr.resize(event.size.width, event.size.height)}

    evt_char do |event|
      case event.key_code
        when ?m : 
          @mgr.toggle_coverage
          draw_map
      when ?[ : 
          @mgr.coverage_zoom_out
          draw_map
      when ?] : 
          @mgr.coverage_zoom_in
          draw_map
      when ?e :
          d = ExportDialog.new(parent)
          if d.show_modal == Wx::ID_OK
            MGMapsExport.export(d.tiles_per_file, d.hash_size)
          end
      end
    end

    @pan = false

    evt_left_down do |event|
      @pan = true
      @start_x = event.x
      @start_y = event.y
      event.skip
    end

    evt_left_up {|event| @pan = false}

    evt_motion do |event|
      if @pan
        @mgr.pan(event.x - @start_x, event.y - @start_y)
        @start_x = event.x
        @start_y = event.y
        draw_map
      end
    end

    evt_mousewheel do |event|
      if event.wheel_rotation > 0
        @mgr.zoom_in(event.x, event.y)
      else
        @mgr.zoom_out(event.x, event.y)
      end
      draw_map
    end

    set_focus
  end

  def config
    @mgr.config
  end

  def draw_map
    paint {|dc| @mgr.draw(dc) }
  end    

  def tile_loaded(tile)
    puts "downloaded #{tile.url}"
    self.refresh
  end

end
