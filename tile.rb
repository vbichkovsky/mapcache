require 'fileutils'

class Tile
  attr_reader :col, :row, :zoom
  
  def initialize(col, row, zoom, cov_zoom)
    @col = col
    @row = row
    @zoom = zoom
    if File.exist?(path)
      load_image
    else
      DownloadManager.enqueue(self)
    end
    create_coverage(cov_zoom)
  end

  def create_coverage(cov_zoom)
    if !cov_zoom
      @mask = nil
    else
      @mask = Wx::Bitmap.new(TILE_WIDTH, TILE_WIDTH)
      @mask.draw do |dc| 
        dc.pen = Wx::TRANSPARENT_PEN
        dc.brush = Wx::WHITE_BRUSH
        dc.draw_rectangle(0, 0, TILE_WIDTH, TILE_WIDTH)
        draw_subtiles(dc, cov_zoom - zoom)
      end
    end
  end

  def load_image
    image = Wx::Image.new(path, Wx::BITMAP_TYPE_PNG)
    @bitmap = Wx::Bitmap.from_image(image)
  end

  def draw(dc, x, y)
    dc.pen = Wx::TRANSPARENT_PEN
    dc.logical_function = Wx::COPY
    if @bitmap
      dc.draw_bitmap(@bitmap, x, y, false)
    else
      dc.brush = Wx::GREY_BRUSH
      dc.draw_rectangle(x, y, TILE_WIDTH, TILE_WIDTH)
    end
    if @mask
      dc.logical_function = Wx::AND
      dc.draw_bitmap(@mask, x, y, false)
    end
  end

  def path
    Tile.path_for(@col, @row, @zoom)
  end

  def url
    server = (@col + 2 * @row) % 4
    galileo = "Galileo"[0, (3 * @col + @row) % 8]
    "http://mt#{server}.google.com/vt/lyrs=m@115&hl=en&x=#{@col}&y=#{@row}&z=#{@zoom}&s=#{galileo}"
  end

  def self.path_for(col, row, zoom)
    "maps/GoogleMap_#{zoom}/#{col}_#{row}.mgm"
  end

  private

  def draw_subtiles(dc, subzoom)
    dc.brush = Wx::GREEN_BRUSH
    scale = 2 ** subzoom
    (0..scale - 1).each do |subcol|
      (0..scale - 1).each do |subrow|
        if File.exist?(Tile.path_for(@col * scale + subcol, 
                                     @row * scale + subrow, 
                                     zoom + subzoom) )
            dc.draw_rectangle(subcol * TILE_WIDTH / scale, 
                              subrow * TILE_WIDTH / scale, 
                              TILE_WIDTH / scale, TILE_WIDTH / scale)
        end
      end
    end
  end    

end
