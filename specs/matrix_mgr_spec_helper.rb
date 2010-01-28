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

  def tm_stub_wo_zoom
    mgr = stub("tile manager")
    mgr.stub!(:get_tile).and_return {|x, y, zoom| "#{x},#{y}"}
    mgr
  end

  def tm_stub_with_zoom
    mgr = stub("tile manager")
    mgr.stub!(:get_tile).and_return {|x, y, zoom| "#{x},#{y},#{zoom}"}
    mgr
  end

end
