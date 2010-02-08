class TileMatrix

  def initialize
    @columns = []
  end

  def [](col, row)
    @columns[col][row]
  end

  def[]=(col, row, value)
    @columns[col] ||= []
    @columns[col][row] = value
  end

  def width
    @columns.size
  end

  def height
    @columns[0].size
  end

  def each
    @columns.each_with_index do |row, col_idx|
      row.each_with_index do |value, row_idx|
        yield col_idx, row_idx, value
      end
    end
  end

  def shift_left(new_column)
    @columns.shift
    @columns.push(new_column)
  end

  def shift_right(new_column)
    @columns.delete_at(@columns.length - 1)
    @columns.unshift(new_column)
  end

  def shift_up(new_row)
    @columns.each_with_index do |c, i|
      c.shift
      c.push(new_row[i])
    end
  end

  def shift_down(new_row)
    @columns.each_with_index do |c, i|
      c.delete_at(c.length - 1)
      c.unshift(new_row[i])
    end
  end

  def reduce(width, height)
    @columns.slice!(width..@columns.length - 1)
    @columns.each do |c|
      c.slice!(height..c.length - 1)
    end
  end

  def add_column(new_column)
    @columns << new_column
  end

  def add_row(new_row)
    @columns.each_with_index do |c, i|
      c << new_row[i]
    end
  end

end
