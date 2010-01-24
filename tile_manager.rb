require 'tile_matrix.rb'
require 'tile_storage.rb'

class TileManager
  attr_reader :tile_row, :tile_col, :offset_x, :offset_y, :zoom

  TILE_WIDTH = 256

  def initialize(start_col, start_row, zoom, offset_x, offset_y)
    @zoom = zoom
    @tile_col = start_col
    @tile_row = start_row
    @offset_x = offset_x
    @offset_y = offset_y
    initialize_matrix
  end

  def zoom_in(x, y)
    @zoom += 1
    @offset_x, @tile_col = calc_start_and_offset_zoom_in(@tile_col, x, @offset_x, @width)
    @offset_y, @tile_row = calc_start_and_offset_zoom_in(@tile_row, y, @offset_y, @height)
    initialize_matrix
    resize(@width, @height)
  end

  def zoom_out(x, y)
    @zoom -= 1
    @offset_x, @tile_col = calc_start_and_offset_zoom_out(@tile_col, x, @offset_x, @width)
    @offset_y, @tile_row = calc_start_and_offset_zoom_out(@tile_row, y, @offset_y, @height)
    initialize_matrix
    resize(@width, @height)
  end

  def draw(dc)
    @matrix.each do |col, row, tile|
      draw_tile(dc, tile, TILE_WIDTH * (col - 1), TILE_WIDTH * (row - 1))
    end
    draw_cross(dc)
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
    @width = width.to_i
    @height = height.to_i
    new_width = (width.to_f / TILE_WIDTH).ceil + 2
    new_height = (height.to_f / TILE_WIDTH).ceil + 2
    if new_width < @matrix.width || new_height < @matrix.height
      @matrix.reduce(new_width, new_height)
    else
      if new_width > @matrix.width
        (@tile_col + @matrix.width..@tile_col + new_width - 1).each do |col|
          column = []
          (@tile_row..@tile_row + @matrix.height - 1).each do |row|
            column << TileStorage.tile_for(col, row, @zoom)
          end
          @matrix.add_column(column)
        end
      end
      if new_height > @matrix.height
        (@tile_row + @matrix.height..@tile_row + new_height - 1).each do |r|
          row = []
          (@tile_col..@tile_col + new_width - 1).each do |col|
            row << TileStorage.tile_for(col, r, @zoom)
          end
          @matrix.add_row(row)
        end
      end
    end
  end

  private

  def calc_start_and_offset_zoom_in(start_idx, cursor_pos, offset, viewport_size)
    middle_tile_idx = start_idx * 2 + 2 + (cursor_pos - offset).to_i / (TILE_WIDTH / 2)
    from_edge = 2 * ( (cursor_pos - offset).to_i % (TILE_WIDTH / 2) )
    calc_offset_and_first_idx(middle_tile_idx, viewport_size, from_edge)
  end

  def calc_start_and_offset_zoom_out(start_idx, cursor_pos, offset, viewport_size)
    cursor_tile_idx = start_idx + (cursor_pos - offset).to_i / TILE_WIDTH + 1
    middle_tile_idx = cursor_tile_idx / 2
    from_edge = ( (cursor_pos - offset).to_i % TILE_WIDTH + 
                  (cursor_tile_idx.even? ? 0 : TILE_WIDTH) ) / 2
    calc_offset_and_first_idx(middle_tile_idx, viewport_size, from_edge)
  end

  def calc_offset_and_first_idx(middle_idx, viewport_size, from_tile_edge)
    [ (viewport_size / 2 - from_tile_edge) % TILE_WIDTH,
      middle_idx - ( (viewport_size / 2 - from_tile_edge) / TILE_WIDTH ) - 1 ]
  end

  def initialize_matrix
    @matrix = TileMatrix.new
    @matrix[0,0] = TileStorage.tile_for(@tile_col, @tile_row, @zoom)
  end    

  def get_tiles(what, which)
    size = (what == :row ? @matrix.width - 1 : @matrix.height - 1)
    col = @tile_col
    row = @tile_row
    if which == :last
      what == :column ? col += @matrix.width - 1 : row += @matrix.height - 1
    end
    (0..size).map do |index|
      TileStorage.tile_for(col + (what == :row ? index : 0),
               row + (what == :column ? index : 0), @zoom)
    end
  end

  def draw_tile(dc, tile, x, y)
    dc.draw_bitmap(tile, x + @offset_x, y + @offset_y, false)
    dc.brush = Wx::TRANSPARENT_BRUSH
    dc.draw_rectangle(x + @offset_x, y + @offset_y, TILE_WIDTH, TILE_WIDTH)
  end

  def draw_cross(dc)
    if @width && @height
      dc.draw_line(@width / 2 - 5, @height / 2, @width / 2 + 6, @height / 2)
      dc.draw_line(@width / 2, @height / 2 - 5, @width / 2, @height / 2 + 6)
    end
  end

end
