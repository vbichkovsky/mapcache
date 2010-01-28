class Tile
  attr_reader :col, :row, :zoom
  
  def initialize(col, row, zoom)
    @col = col
    @row = row
    @zoom = zoom
  end

  def load_image
    image = Wx::Image.new(path, Wx::BITMAP_TYPE_PNG)
    @bitmap = Wx::Bitmap.from_image(image)
  end

  def draw(dc, x, y, width, height)
    if @bitmap
      dc.draw_bitmap(@bitmap, x, y, false) 
      dc.brush = Wx::TRANSPARENT_BRUSH
      dc.draw_rectangle(x, y, width, height)
    else
      dc.brush = Wx::GREY_BRUSH
      dc.draw_rectangle(x, y, width, height)
    end
  end

  def path
    "maps/GoogleMap_#{@zoom}/#{@col}_#{@row}.mgm"
  end

  def url
    server = (@col + 2 * @row) % 4
    galileo = "Galileo"[0, (3 * @col + @row) % 8]
    "http://mt#{server}.google.com/vt/lyrs=m@115&hl=en&x=#{@col}&y=#{@row}&z=#{@zoom}&s=#{galileo}"
  end

end
