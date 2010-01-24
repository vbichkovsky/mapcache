require 'net/http'
require 'fileutils'

class Tile

  TILE_WIDTH = 256

  def initialize(x, y, zoom)
    image = Wx::Image.new(path_to_tile(x, y, zoom), Wx::BITMAP_TYPE_PNG)
    @bitmap = Wx::Bitmap.from_image(image)
  end

  def draw(dc, x, y)
    dc.draw_bitmap(@bitmap, x, y, false)
    dc.brush = Wx::TRANSPARENT_BRUSH
    dc.draw_rectangle(x, y, TILE_WIDTH, TILE_WIDTH)
  end

  private

  def path_to_tile(x, y, zoom)
    result = "maps/GoogleMap_#{zoom}/#{x}_#{y}.mgm"
    if !File.exist?(result)
      dir = File.dirname(result)
      FileUtils.mkdir_p dir if !File.exist?(dir)
      download(url(x, y, zoom), result)
    end
    result
  end

  def url(x, y, zoom)
    server = (x + 2 * y) % 4
    galileo = "Galileo"[0, (3 * x + y) % 8]
    "http://mt#{server}.google.com/vt/lyrs=m@115&hl=en&x=#{x}&y=#{y}&z=#{zoom}&s=#{galileo}"
  end

  def download(url, filename)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path, {"User-Agent" => "Opera/9.64 (Windows NT 5.1; U; en) Presto/2.1.1"})
    res = Net::HTTP.new(uri.host).start {|http| http.request(req)}
    if res.code == "200"
      File.open(filename, 'wb') {|f| f.write(res.body)}
    end
  end
end
