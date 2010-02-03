require 'yaml'

class MapFrame < Wx::Frame

  DEFAULT_CONFIG = {'width' => 512, 'height' => 512, 'left' => 0, 'top' => 0,
    'map' => {'left_col' => 288, 'top_row' => 155, 'offset_x' => 0, 'offset_y' => 0, 
      'zoom' => 9, 'show_cov' => true, 'cov_zoom' => 10} }

  def initialize
    config = load_config
    super(nil, :title => "mapcache 0.1", 
          :pos => [config['left'], config['top']],
          :size => [config['width'], config['height']] )

    @status = Wx::StatusBar.new(self)
    @status.fields_count = 3
    @status.set_status_text("press F1 for help", 2)
    self.status_bar = @status

    box = Wx::HBoxSizer.new
    @panel = MapPanel.new(self, config['map'])
    box.add(@panel, 1, Wx::EXPAND)
    self.sizer = box

    evt_close do |event| 
      save_config
      destroy
    end

    show
  end

  def set_zoom(value)
    @status.set_status_text("zoom: #{value}", 0)
  end

  def set_coverage_zoom(value)
    text = value ? "coverage: #{value}" : ""
    @status.set_status_text(text, 1)
  end

  private 

  def load_config
    File.exist?('config.yml') ? YAML::load_file('config.yml') : DEFAULT_CONFIG
  end

  def save_config
    config = {
      'left' => self.position.x,
      'top' => self.position.y,
      'width' => self.size.width,
      'height' => self.size.height,
      'map' => @panel.config
    }
   open('config.yml', 'w') { |f| YAML.dump(config, f) }
  end

end
