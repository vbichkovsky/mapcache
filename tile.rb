class Tile
  
  def initialize(x, y, zoom)
    @x = x
    @y = y
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
    "maps/GoogleMap_#{@zoom}/#{@x}_#{@y}.mgm"
  end

  def url
    server = (@x + 2 * @y) % 4
    galileo = "Galileo"[0, (3 * @x + @y) % 8]
    "http://mt#{server}.google.com/vt/lyrs=m@115&hl=en&x=#{@x}&y=#{@y}&z=#{@zoom}&s=#{galileo}"
  end

end
