require File.dirname(__FILE__) + '/../tile_manager.rb'

describe TileManager do

  def matrix_dump
    result = []
    @matrix.each do |col, row, tile| 
      result[row] ||= []
      result[row][col] = tile
    end
    result
  end

  before do
    @matrix = TileMatrix.new
    TileMatrix.stub!(:new).and_return(@matrix)
    TileStorage.stub!(:tile_for).and_return {|x, y| "#{x},#{y}"}
    @manager = TileManager.new(nil, 100, 200)
    @initial_dump = matrix_dump
  end

  it 'initial matrix dump' do
    @matrix.width.should == 4
    @matrix.height.should == 4
    @initial_dump.should == [
                             ["99,199", "100,199", "101,199", "102,199"],
                             ["99,200", "100,200", "101,200", "102,200"],
                             ["99,201", "100,201", "101,201", "102,201"],
                             ["99,202", "100,202", "101,202", "102,202"]
                            ]
  end

  it "resizing window without changing matrix" do
    @manager.resize(TileManager::TILE_WIDTH * 2 - 1, TileManager::TILE_WIDTH * 2 - 1)
    matrix_dump.should == @initial_dump
  end

  it "resizing - growing in width" do
    @manager.resize(TileManager::TILE_WIDTH * 2, TileManager::TILE_WIDTH * 2 - 1)
    @matrix.width.should == 5
    @matrix.height.should == 4
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199", "103,199"],
                           ["99,200", "100,200", "101,200", "102,200", "103,200"],
                           ["99,201", "100,201", "101,201", "102,201", "103,201"],
                           ["99,202", "100,202", "101,202", "102,202", "103,202"]
                          ]
  end

  it "resizing - growing in both width and height" do
    @manager.resize(TileManager::TILE_WIDTH * 2, TileManager::TILE_WIDTH * 2)
    @matrix.width.should == 5
    @matrix.height.should == 5
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199", "103,199"],
                           ["99,200", "100,200", "101,200", "102,200", "103,200"],
                           ["99,201", "100,201", "101,201", "102,201", "103,201"],
                           ["99,202", "100,202", "101,202", "102,202", "103,202"],
                           ["99,203", "100,203", "101,203", "102,203", "103,203"]
                          ]
  end

  it "resizing - reducing width" do
    @manager.resize(TileManager::TILE_WIDTH - 1, TileManager::TILE_WIDTH * 2 - 1)
    @matrix.width.should == 3
    @matrix.height.should == 4
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199"],
                           ["99,200", "100,200", "101,200"],
                           ["99,201", "100,201", "101,201"],
                           ["99,202", "100,202", "101,202"]
                          ]
  end    

  it "resizing - reducing both width and height" do
    @manager.resize(TileManager::TILE_WIDTH - 1, TileManager::TILE_WIDTH - 1)
    @matrix.width.should == 3
    @matrix.height.should == 3
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199"],
                           ["99,200", "100,200", "101,200"],
                           ["99,201", "100,201", "101,201"]
                          ]
  end    

  it "panning" do
  end

end
