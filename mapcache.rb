#!/usr/bin/ruby

require 'gtk2'
require 'tile_manager.rb'
require 'yaml'

$offset_x = 0
$offset_y = 0
$start_x = 0
$start_y = 0
$pan = false

area = Gtk::DrawingArea.new
tile_manager = TileManager.new(area, 290, 156)

area.add_events(Gdk::Event::BUTTON_PRESS_MASK |
                Gdk::Event::BUTTON_MOTION_MASK |
                Gdk::Event::BUTTON_RELEASE_MASK
                )

area.signal_connect('button_press_event') do |w, e|
  $start_x = e.x
  $start_y = e.y
  $pan = true
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

config = {'width' => 512, 'height' => 512}
if File.exist?('config.yml')
  config = YAML::load_file('config.yml')
end

window = Gtk::Window.new
window.add(area)
window.resize(config['width'], config['height'])

window.signal_connect('delete_event') do
  size = window.size
  config['width'] = size[0]
  config['height'] = size[1]
  open('config.yml', 'w') { |f| YAML.dump(config, f) }
  Gtk.main_quit
end

window.signal_connect('configure_event') do |w, e|
  tile_manager.resize(e.width, e.height)
end

window.show_all

Gtk.main
