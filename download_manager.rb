require 'net/http'
require 'thread'

class DownloadManager

  @@queue = Queue.new

  def self.enqueue(tile)
    puts "enqueued #{tile.url}"
    @@queue << tile
  end

  def self.set_observer(o)
    @@observer = o
  end

  def self.download(tile)
    uri = URI.parse(tile.url)
    req = Net::HTTP::Get.new(uri.path, {"User-Agent" => "mapcache"})
    res = Net::HTTP.new(uri.host).start {|http| http.request(req)}
    if res.code == "200"
      File.open(tile.path, 'wb') {|f| f.write(res.body)}
    end
  end

  Thread.new do
    loop do
      if !@@queue.empty?
        Thread.new do
          tile = @@queue.pop
          download(tile)
          tile.load_image
          @@observer.image_loaded(tile) if @@observer
        end
      end
    end
  end

end
