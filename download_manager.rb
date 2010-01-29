require 'net/http'
require 'thread'

class DownloadManager

  @queue = Queue.new
  Thread.new do
    loop {new_thread_from_queue if !@queue.empty?}
  end

  def self.enqueue(tile)
    puts "enqueued #{tile.url}"
    @queue << tile
  end

  def self.observer=(observer)
    @observer = observer
  end

  private

  def self.new_thread_from_queue
    Thread.new do
      tile = @queue.pop
      dir = File.dirname(tile.path)
      FileUtils.mkdir_p dir if !File.exist?(dir)
      download(tile)
      tile.load_image
      @observer.tile_loaded(tile)
    end
  end

  def self.download(tile)
    uri = URI.parse(tile.url)
    req = Net::HTTP::Get.new(uri.path, {"User-Agent" => "mapcache"})
    res = Net::HTTP.new(uri.host).start {|http| http.request(req)}
    if res.code == "200"
      File.open(tile.path, 'wb') {|f| f.write(res.body)}
    end
  end

end
