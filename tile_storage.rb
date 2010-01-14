require 'net/http'
require 'fileutils'

class TileStorage

  def self.tile_for(x, y)
    Gdk::Pixbuf.new(path_to_tile(x, y))
  end    

  private

  def self.path_to_tile(x, y)
    result = "maps/GoogleMap_9/#{x}_#{y}.mgm"
    if !File.exist?(result)
      dir = File.dirname(result)
      FileUtils.mkdir_p dir if !File.exist?(dir)
      download(url(x, y), result)
    end
    result
  end

  def self.url(x, y)
    z = 9
    server = (x + 2 * y) % 4
    galileo = "Galileo"[0, (3 * x + y) % 8]
    "http://mt#{server}.google.com/vt/lyrs=m@115&hl=en&x=#{x}&y=#{y}&z=#{z}&s=#{galileo}"
  end

  def self.download(url, filename)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path, {"User-Agent" => "Opera/9.64 (Windows NT 5.1; U; en) Presto/2.1.1"})
    res = Net::HTTP.new(uri.host).start {|http| http.request(req)}
    if res.code == "200"
      File.open(filename, 'wb') {|f| f.write(res.body)}
    end
  end
end
