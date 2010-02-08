require 'httpclient'
require 'thread'
require 'monitor'

class DownloadManager

  @http = HTTPClient.new
  @lock = Monitor.new
  @queue = Queue.new
  @thread = Thread.new do
    loop do
      sleep if @queue.empty?
      new_thread_from_queue
    end
  end

  def self.enqueue(tile)
    @queue << tile
    @thread.run
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
      @lock.synchronize { @observer.tile_loaded(tile) }
    end
  end

  def self.download(tile)
    res = @http.get(tile.url, {}, {"User-Agent" => "mapcache"})
    if res.status == 200
      File.open(tile.path, 'wb') {|f| f.write(res.content)}
    end
  end

end
