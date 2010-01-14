require File.dirname(__FILE__) + '/../tile_manager.rb'

describe TileManager do

  def matrix_dump
    result = []
    @matrix.each {|col, row, tile| result << [col, row, tile]}
    result
  end

  before do
    @matrix = TileMatrix.new
    TileMatrix.stub!(:new).and_return(@matrix)
    TileStorage.stub!(:tile_for).and_return {|x, y| [x, y]}
    @manager = TileManager.new(nil, 100, 200)
    @initial_dump = matrix_dump
  end

  it 'initial 4x4 matrix dump' do
    @matrix.width.should == 4
    @matrix.height.should == 4
    @initial_dump.should == [
                    [0,0, [99, 199]],
                    [0,1, [99, 200]],
                    [0,2, [99, 201]],
                    [0,3, [99, 202]],
                    [1,0, [100, 199]],
                    [1,1, [100, 200]],
                    [1,2, [100, 201]],
                    [1,3, [100, 202]],
                    [2,0, [101, 199]],
                    [2,1, [101, 200]],
                    [2,2, [101, 201]],
                    [2,3, [101, 202]],
                    [3,0, [102, 199]],
                    [3,1, [102, 200]],
                    [3,2, [102, 201]],
                    [3,3, [102, 202]]
                   ]
  end

  it "resizing window without changing matrix" do
    @manager.resize(TileManager::TILE_WIDTH * 2, TileManager::TILE_WIDTH * 2)
    matrix_dump.should == @initial_dump
  end

  it "panning" do
  end

end
