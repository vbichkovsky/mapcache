#!/usr/bin/ruby

require 'rubygems'
require 'wx'
require 'download_manager.rb'
require 'matrix_manager.rb'
require 'yaml'

class MapPanel < Wx::Panel
  
  def initialize(parent, mgr)
    super(parent, :style => Wx::NO_BORDER)
    @mgr = mgr

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

  def draw_map
    paint {|dc| @mgr.draw(dc) }
  end    

end

class MapFrame < Wx::Frame

  def draw_map
    @panel.draw_map
  end

  def load_config
    if File.exist?('config.yml')
      YAML::load_file('config.yml')
    else
      {'width' => 512, 'height' => 512, 'left_col' => 288, 'top_row' => 155,
        'offset_x' => 0, 'offset_y' => 0, 'zoom' => 9, 'show_cov' => true,
        'cov_zoom' => 10}
    end
  end

  def save_config
    config = {'width' => self.size.width,
      'height' => self.size.height,
      'left_col' => @matrix_mgr.left_col,
      'top_row' => @matrix_mgr.top_row,
      'offset_x' => @matrix_mgr.offset_x,
      'offset_y' => @matrix_mgr.offset_y,
      'zoom' => @matrix_mgr.zoom,
      'show_cov' => @matrix_mgr.show_coverage,
      'cov_zoom' => @matrix_mgr.coverage_zoom}
   open('config.yml', 'w') { |f| YAML.dump(config, f) }
  end

  def tile_loaded(tile)
    puts "downloaded #{tile.url}"
    self.refresh
  end

  def initialize
    config = load_config
    super(nil, :title => "Map cache", :pos => [150, 25], 
          :size => [config['width'], config['height']])

    DownloadManager.observer = self

    @matrix_mgr = MatrixManager.new(config['left_col'], config['top_row'], config['zoom'], 
                                    config['offset_x'], config['offset_y'], 
                                    config['width'], config['height'], config['show_cov'],
                                    config['cov_zoom'])
    box = Wx::HBoxSizer.new
    @panel = MapPanel.new(self, @matrix_mgr)
    box.add(@panel, 1, Wx::EXPAND)
    self.sizer = box

    evt_close do |event| 
      save_config
      destroy
    end

    show
  end
end

Wx::App.run do 
  MapFrame.new
end



