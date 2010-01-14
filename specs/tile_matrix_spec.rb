require File.dirname(__FILE__) + '/../tile_matrix.rb'

describe TileMatrix do

  before do
    @matrix = TileMatrix.new
    @matrix[0,0] = 1
    @matrix[0,1] = 2
    @matrix[1,0] = 3
    @matrix[1,1] = 4
    @matrix[2,0] = 5
    @matrix[2,1] = 6
  end

  def matrix_contents
    results = []
    @matrix.each {|col, row, item| results << item }
    results
  end

  it 'initial size' do
    @matrix.width.should == 3
    @matrix.height.should == 2
  end

  it 'iterator' do
    results = []
    @matrix.each {|col, row, item| results << [col, row, item]}
    results.should == [[0, 0, 1], [0, 1, 2],
                       [1, 0, 3], [1, 1, 4],
                       [2, 0, 5], [2, 1, 6]]
  end

  it 'shift left' do
    @matrix.shift_left([7, 8])
    matrix_contents.should == [3, 4, 5, 6, 7, 8]
    @matrix.width.should == 3
  end

  it 'shift right' do
    @matrix.shift_right([7, 8])
    matrix_contents.should == [7, 8, 1, 2, 3, 4]
    @matrix.width.should == 3
  end

  it 'shift up' do
    @matrix.shift_up([7, 8, 9])
    matrix_contents.should == [2, 7, 4, 8, 6, 9]
    @matrix.height.should == 2
  end

  it 'shift down' do
    @matrix.shift_down([7, 8, 9])
    matrix_contents.should == [7, 1, 8, 3, 9, 5]
    @matrix.height.should == 2
  end

  it 'reduce' do
    @matrix.reduce(2, 1)
    matrix_contents.should == [1, 3]
    @matrix.width.should == 2
    @matrix.height.should == 1
  end

  it 'add column' do
    @matrix.add_column([7, 8])
    matrix_contents.should == [1, 2, 3, 4, 5, 6, 7, 8]
    @matrix.width.should == 4
  end

  it 'add row' do
    @matrix.add_row([7, 8, 9])
    matrix_contents.should == [1, 2, 7, 3, 4, 8, 5, 6, 9]
    @matrix.height.should == 3
  end

end
