require 'tile_matrix.rb'
require 'tile_storage.rb'

class TileManager
  attr_reader :tile_row, :tile_col, :offset_x, :offset_y

  TILE_WIDTH = 256

  def initialize(area, start_col, start_row, offset_x, offset_y)
    @tile_col = start_col
    @tile_row = start_row
    @offset_x = offset_x
    @offset_y = offset_y
    @area = area
    @matrix = TileMatrix.new
    @matrix[0,0] = TileStorage.tile_for(@tile_col, @tile_row)
  end

  def draw
    @matrix.each do |col, row, tile|
      draw_tile(tile, TILE_WIDTH * (col - 1), TILE_WIDTH * (row - 1))
    end
  end

  def pan(dx, dy)
    @offset_x += dx
    @offset_y += dy

    if @offset_x < 0
      @offset_x = TILE_WIDTH + @offset_x
      @tile_col += 1
      @matrix.shift_left(get_tiles(:column, :last) )
    elsif @offset_x >= TILE_WIDTH
      @offset_x -= TILE_WIDTH
      @tile_col -= 1
      @matrix.shift_right(get_tiles(:column, :first) )
    end

    if @offset_y < 0
      @offset_y = TILE_WIDTH + @offset_y
      @tile_row += 1
      @matrix.shift_up(get_tiles(:row, :last) )
    elsif @offset_y >= TILE_WIDTH
      @offset_y -= TILE_WIDTH
      @tile_row -= 1
      @matrix.shift_down(get_tiles(:row, :first) )
    end
  end

  def resize(width, height)
    new_width = (width.to_f / TILE_WIDTH).ceil + 2
    new_height = (height.to_f / TILE_WIDTH).ceil + 2
    if new_width < @matrix.width || new_height < @matrix.height
      @matrix.reduce(new_width, new_height)
    else
      if new_width > @matrix.width
        (@tile_col + @matrix.width..@tile_col + new_width - 1).each do |col|
          column = []
          (@tile_row..@tile_row + @matrix.height - 1).each do |row|
            column << TileStorage.tile_for(col, row)
          end
          @matrix.add_column(column)
        end
      end
      if new_height > @matrix.height
        (@tile_row + @matrix.height..@tile_row + new_height - 1).each do |r|
          row = []
          (@tile_col..@tile_col + new_width - 1).each do |col|
            row << TileStorage.tile_for(col, r)
          end
          @matrix.add_row(row)
        end
      end
    end
  end

  private

  def get_tiles(what, which)
    size = (what == :row ? @matrix.width - 1 : @matrix.height - 1)
    col = @tile_col
    row = @tile_row
    if which == :last
      what == :column ? col += @matrix.width - 1 : row += @matrix.height - 1
    end
    (0..size).map do |index|
      TileStorage.tile_for(col + (what == :row ? index : 0),
               row + (what == :column ? index : 0))
    end
  end

  def draw_tile(tile, x, y)
    @area.window.draw_pixbuf(@area.style.fg_gc(@area.state), tile,
                            0, 0, x + @offset_x, y + @offset_y,
                            -1, -1, Gdk::RGB::Dither::NONE, 0, 0)
    @area.window.draw_rectangle(@area.style.fg_gc(@area.state), false,
                                x + @offset_x, y + @offset_y, TILE_WIDTH - 1,
                                TILE_WIDTH - 1)
  end

end
