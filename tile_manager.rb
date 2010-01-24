require 'tile_matrix.rb'
require 'tile.rb'

class TileManager
  attr_reader :tile_row, :tile_col, :offset_x, :offset_y, :zoom

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
      tile.draw(dc, Tile::TILE_WIDTH * (col - 1) + @offset_x, Tile::TILE_WIDTH * (row - 1) + @offset_y)
    end
  end

  def pan(dx, dy)
    @offset_x += dx
    @offset_y += dy

    if @offset_x < 0
      @offset_x = Tile::TILE_WIDTH + @offset_x
      @tile_col += 1
      @matrix.shift_left(get_tiles(:column, :last) )
    elsif @offset_x >= Tile::TILE_WIDTH
      @offset_x -= Tile::TILE_WIDTH
      @tile_col -= 1
      @matrix.shift_right(get_tiles(:column, :first) )
    end

    if @offset_y < 0
      @offset_y = Tile::TILE_WIDTH + @offset_y
      @tile_row += 1
      @matrix.shift_up(get_tiles(:row, :last) )
    elsif @offset_y >= Tile::TILE_WIDTH
      @offset_y -= Tile::TILE_WIDTH
      @tile_row -= 1
      @matrix.shift_down(get_tiles(:row, :first) )
    end
  end

  def resize(width, height)
    @width = width.to_i
    @height = height.to_i
    new_width = (width.to_f / Tile::TILE_WIDTH).ceil + 2
    new_height = (height.to_f / Tile::TILE_WIDTH).ceil + 2
    if new_width < @matrix.width || new_height < @matrix.height
      @matrix.reduce(new_width, new_height)
    else
      if new_width > @matrix.width
        (@tile_col + @matrix.width..@tile_col + new_width - 1).each do |col|
          column = []
          (@tile_row..@tile_row + @matrix.height - 1).each do |row|
            column << Tile.new(col, row, @zoom)
          end
          @matrix.add_column(column)
        end
      end
      if new_height > @matrix.height
        (@tile_row + @matrix.height..@tile_row + new_height - 1).each do |r|
          row = []
          (@tile_col..@tile_col + new_width - 1).each do |col|
            row << Tile.new(col, r, @zoom)
          end
          @matrix.add_row(row)
        end
      end
    end
  end

  private

  def calc_start_and_offset_zoom_in(start_idx, cursor_pos, offset, viewport_size)
    middle_tile_idx = start_idx * 2 + 2 + (cursor_pos - offset).to_i / (Tile::TILE_WIDTH / 2)
    from_edge = 2 * ( (cursor_pos - offset).to_i % (Tile::TILE_WIDTH / 2) )
    calc_offset_and_first_idx(middle_tile_idx, viewport_size, from_edge)
  end

  def calc_start_and_offset_zoom_out(start_idx, cursor_pos, offset, viewport_size)
    cursor_tile_idx = start_idx + (cursor_pos - offset).to_i / Tile::TILE_WIDTH + 1
    middle_tile_idx = cursor_tile_idx / 2
    from_edge = ( (cursor_pos - offset).to_i % Tile::TILE_WIDTH + 
                  (cursor_tile_idx.even? ? 0 : Tile::TILE_WIDTH) ) / 2
    calc_offset_and_first_idx(middle_tile_idx, viewport_size, from_edge)
  end

  def calc_offset_and_first_idx(middle_idx, viewport_size, from_tile_edge)
    [ (viewport_size / 2 - from_tile_edge) % Tile::TILE_WIDTH,
      middle_idx - ( (viewport_size / 2 - from_tile_edge) / Tile::TILE_WIDTH ) - 1 ]
  end

  def initialize_matrix
    @matrix = TileMatrix.new
    @matrix[0,0] = Tile.new(@tile_col, @tile_row, @zoom)
  end    

  def get_tiles(what, which)
    size = (what == :row ? @matrix.width - 1 : @matrix.height - 1)
    col = @tile_col
    row = @tile_row
    if which == :last
      what == :column ? col += @matrix.width - 1 : row += @matrix.height - 1
    end
    (0..size).map do |index|
      Tile.new(col + (what == :row ? index : 0),
               row + (what == :column ? index : 0), @zoom)
    end
  end

end
