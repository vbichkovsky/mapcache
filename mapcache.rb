#!/usr/bin/ruby

require 'rubygems'
require 'wx'
require 'tile_manager.rb'
require 'matrix_manager.rb'
require 'yaml'

class MapFrame < Wx::Frame

  def draw_map
    paint {|dc| @matrix_mgr.draw(dc) }
  end

  def load_config
    if File.exist?('config.yml')
      YAML::load_file('config.yml')
    else
      {'width' => 512, 'height' => 512, 'col' => 288, 'row' => 155,
        'offset_x' => 0, 'offset_y' => 0, 'zoom' => 9}
    end
  end

  def save_config
    config = {'width' => self.size.width,
      'height' => self.size.height,
      'col' => @matrix_mgr.tile_col,
      'row' => @matrix_mgr.tile_row,
      'offset_x' => @matrix_mgr.offset_x,
      'offset_y' => @matrix_mgr.offset_y,
      'zoom' => @matrix_mgr.zoom }
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

    @tile_mgr = TileManager.new(self)
    @matrix_mgr = MatrixManager.new(config['col'], config['row'], config['zoom'], 
                                    config['offset_x'], config['offset_y'], @tile_mgr)
    @matrix_mgr.resize(self.size.width, self.size.height)

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
        @matrix_mgr.pan(event.x - @start_x, event.y - @start_y)
        @start_x = event.x
        @start_y = event.y
        draw_map
      end
    end

    evt_mousewheel do |event|
      if event.wheel_rotation > 0
        @matrix_mgr.zoom_in(event.x, event.y)
      else
        @matrix_mgr.zoom_out(event.x, event.y)
      end
      draw_map
    end

    evt_paint {|event| draw_map}

    evt_size {|event| @matrix_mgr.resize(event.size.width, event.size.height)}

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



