require 'fileutils'
require 'download_manager.rb'

class Tile

  TILE_WIDTH = 256

  def initialize(x, y, zoom)
    @x = x
    @y = y
    @zoom = zoom
    if File.exist?(self.path)
      load_image
    else
      dir = File.dirname(self.path)
      FileUtils.mkdir_p dir if !File.exist?(dir)
      DownloadManager.enqueue(self)
    end
  end

  def load_image
    image = Wx::Image.new(path, Wx::BITMAP_TYPE_PNG)
    @bitmap = Wx::Bitmap.from_image(image)
  end

  def draw(dc, x, y)
    if @bitmap
      dc.draw_bitmap(@bitmap, x, y, false) 
      dc.brush = Wx::TRANSPARENT_BRUSH
      dc.draw_rectangle(x, y, TILE_WIDTH, TILE_WIDTH)
    else
      dc.brush = Wx::GREY_BRUSH
      dc.draw_rectangle(x, y, TILE_WIDTH, TILE_WIDTH)
    end
  end

  def path
    "maps/GoogleMap_#{@zoom}/#{@x}_#{@y}.mgm"
  end

  def url
    server = (@x + 2 * @y) % 4
    galileo = "Galileo"[0, (3 * @x + @y) % 8]
    "http://mt#{server}.google.com/vt/lyrs=m@115&hl=en&x=#{@x}&y=#{@y}&z=#{@zoom}&s=#{galileo}"
  end

end
