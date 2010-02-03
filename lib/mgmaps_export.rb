require 'pathname'

class MGMapsExport

  MAPS_ROOT = Pathname.new("maps")
  EXPORT_ROOT = Pathname.new("export")

  def self.export(tiles_per_file, hash_size)
    if EXPORT_ROOT.exist?
      error_dlg('Cannot export: export directory already exists!')
      return
    end

    files = Dir['maps/*/*.mgm']

    catch :cancelled do
      if tiles_per_file > 1
        export_as_mtpf(files, tiles_per_file)
      elsif hash_size > 1
        export_as_hashed(files, hash_size)
      else
        export_as_copy(files)
      end

      create_conf_file(tiles_per_file, hash_size)
      success_msg
    end
  end

  private

  def self.error_dlg(msg)
      Wx::MessageDialog.new(Wx::THE_APP.top_window, msg, 'Export',
                            Wx::OK|Wx::ICON_ERROR).show_modal
  end

  def self.success_msg
      Wx::MessageDialog.new(Wx::THE_APP.top_window, 'Export completed', 'Export',
                            Wx::OK|Wx::ICON_INFORMATION).show_modal
  end

  def self.confirm(msg)
      Wx::MessageDialog.new(Wx::THE_APP.top_window, msg, 'Export',
                            Wx::YES_NO|Wx::ICON_QUESTION).show_modal == Wx::ID_YES
  end

  def self.create_conf_file(tiles_per_file, hash_size)
    File.open('export/cache.conf', 'w') do |file|
      file.puts "version=3"
      file.puts "tiles_per_file=#{tiles_per_file}"
      file.puts "hash_size=#{hash_size}"
    end
  end

  def self.export_each_file(files)
    progress = Wx::ProgressDialog.new('Export', 'Processing files...', 
                                      files.size, Wx::THE_APP.top_window,
                                      Wx::PD_AUTO_HIDE | Wx::PD_APP_MODAL | 
                                      Wx::PD_CAN_ABORT | Wx::PD_REMAINING_TIME)
    files_done = 0
    files.each do |file|
      yield file
      files_done += 1
      if !progress.update(files_done)
        if confirm('Cancel export?') 
          progress.destroy
          throw :cancelled
        else
          progress.resume
        end
      end
    end
  end

  def self.export_as_copy(files)
    export_each_file(files) do |file|
      src = Pathname.new(file)
      dest = EXPORT_ROOT + src.relative_path_from(MAPS_ROOT)
      FileUtils.mkdir_p dest.dirname
      FileUtils.cp file, dest
    end
  end

  def self.export_as_hashed(files, hash_size)
    export_each_file(files) do |file|
      src = Pathname.new(file)
      x, y = src.basename('.mgm').to_s.split('_').map{|n| n.to_i}
      subdir = Pathname.new( ((x * 256 + y) % hash_size).to_s )
      zoomdir = src.relative_path_from(MAPS_ROOT).dirname
      dest = EXPORT_ROOT + zoomdir + subdir + src.basename
      FileUtils.mkdir_p dest.dirname
      FileUtils.cp file, dest
    end    
  end

  def self.export_as_mtpf(files, tiles_per_file)
    tpf_x, tpf_y = tpf_xy(tiles_per_file)

    export_each_file(files) do |file|
      src = Pathname.new(file)
      x, y = src.basename('.mgm').to_s.split('_').map{|n| n.to_i}
      dest_x = x / tpf_x
      dest_y = y / tpf_y
      rel_x = x % tpf_x
      rel_y = y % tpf_y

      zoomdir = src.relative_path_from(MAPS_ROOT).dirname
      dest = EXPORT_ROOT + zoomdir + Pathname.new("#{dest_x}_#{dest_y}.mgm")
      blank_mtpf_file(dest, tiles_per_file) if !File.exists?(dest)
      add_tile_to_file(src, dest, rel_x, rel_y)
    end    
  end

  def self.tpf_xy(tpf)
    log2 = (Math.log(tpf) / Math.log(2)).to_i
    if log2.even?
      tpf_x = Math.sqrt(tpf).to_i
      tpf_y = tpf_x
    else
      tpf_x = Math.sqrt(tpf * 2).to_i
      tpf_y = tpf_x / 2
    end
    [tpf_x, tpf_y]
  end

  def self.blank_mtpf_file(dest, tiles_per_file)
    FileUtils.mkdir_p dest.dirname if !dest.dirname.exist?
    File.open(dest, 'w') { |f| f.write 0.chr * (2 + 6 * tiles_per_file) }
  end

  def self.add_tile_to_file(src, dest, rel_x, rel_y)
    File.open(dest, 'r+') do |file|
      count = file.read(2).unpack('n').first + 1
      file.seek(0, IO::SEEK_END)
      file.write(IO.read(src))
      pos = file.pos
      file.rewind
      file.write [count].pack('n')
      file.pos = 2 + 6 * (count - 1)
      file.write rel_x.chr
      file.write rel_y.chr
      file.write [pos].pack('N')
    end
  end

end
