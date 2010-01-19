#!/usr/bin/ruby

require 'gtk2'
require 'tile_manager.rb'
require 'yaml'

$offset_x = 0
$offset_y = 0
$start_x = 0
$start_y = 0
$pan = false

config = {'width' => 512, 'height' => 512, 'col' => 288, 'row' => 155,
  'offset_x' => 0, 'offset_y' => 0, 'zoom' => 9}

if File.exist?('config.yml')
  config = YAML::load_file('config.yml')
end

area = Gtk::DrawingArea.new
tile_manager = TileManager.new(area, config['col'], config['row'], config['zoom'],
                               config['offset_x'], config['offset_y'])

area.add_events(Gdk::Event::BUTTON_PRESS_MASK |
                Gdk::Event::BUTTON_MOTION_MASK |
                Gdk::Event::BUTTON_RELEASE_MASK |
                Gdk::Event::SCROLL_MASK
                )

area.signal_connect('button_press_event') do |w, e|
  $start_x = e.x
  $start_y = e.y
  $pan = true
end

area.signal_connect('scroll_event') do |w, e|
  tile_manager.zoom_in(e.x, e.y) if e.direction == Gdk::EventScroll::Direction::UP
end

area.signal_connect('button_release_event') do |w, e|
  $pan = false
end

area.signal_connect('motion_notify_event') do |w, e|
  if $pan
    tile_manager.pan(e.x - $start_x, e.y - $start_y)
    $start_x = e.x
    $start_y = e.y
    w.signal_emit('expose_event', nil)
  end
end

area.signal_connect('expose_event') do
  tile_manager.draw
end

window = Gtk::Window.new
window.add(area)
window.resize(config['width'], config['height'])

 window.signal_connect('delete_event') do
   size = window.size
   config['width'] = size[0]
   config['height'] = size[1]
   config['col'] = tile_manager.tile_col
   config['row'] = tile_manager.tile_row
   config['offset_x'] = tile_manager.offset_x
   config['offset_y'] = tile_manager.offset_y
   config['zoom'] = tile_manager.zoom
   open('config.yml', 'w') { |f| YAML.dump(config, f) }
   Gtk.main_quit
 end

window.signal_connect('configure_event') do |w, e|
  tile_manager.resize(e.width, e.height)
end

window.show_all
tile_manager.draw

Gtk.main
