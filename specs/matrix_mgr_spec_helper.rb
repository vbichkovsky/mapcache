require File.dirname(__FILE__) + '/../matrix_manager.rb'

class MatrixManager
  attr_reader :matrix
end

module MatrixManagerSpecHelper

  def matrix_dump
    result = []
    @manager.matrix.each do |col, row, tile| 
      result[row] ||= []
      result[row][col] = tile
    end
    result
  end

  def stub_tile_wo_zoom
    Tile.stub!(:new).and_return {|x, y, zoom, subzoom| "#{x},#{y}"}
  end

  def stub_tile_with_zoom
    Tile.stub!(:new).and_return {|x, y, zoom, subzoom| "#{x},#{y},#{zoom}"}
  end

end
