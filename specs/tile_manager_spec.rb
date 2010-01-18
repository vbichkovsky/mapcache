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
    @manager = TileManager.new(nil, 99, 199, 0, 0)
    @manager.resize(TileManager::TILE_WIDTH * 3, TileManager::TILE_WIDTH * 2)
    @initial_dump = matrix_dump
  end

  it 'initial matrix dump' do
    @matrix.width.should == 5
    @matrix.height.should == 4
    @initial_dump.should == [
                             ["99,199", "100,199", "101,199", "102,199", "103,199"],
                             ["99,200", "100,200", "101,200", "102,200", "103,200"],
                             ["99,201", "100,201", "101,201", "102,201", "103,201"],
                             ["99,202", "100,202", "101,202", "102,202", "103,202"]
                            ]
  end

  it "resizing window without changing matrix" do
    @manager.resize(TileManager::TILE_WIDTH * 3 - 10, TileManager::TILE_WIDTH * 2 - 10)
    matrix_dump.should == @initial_dump
  end

  it "resizing - growing in width" do
    @manager.resize(TileManager::TILE_WIDTH * 3 + 10, TileManager::TILE_WIDTH * 2)
    @matrix.width.should == 6
    @matrix.height.should == 4
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199", "103,199", "104,199"],
                           ["99,200", "100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["99,201", "100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["99,202", "100,202", "101,202", "102,202", "103,202", "104,202"]
                          ]
  end

  it "resizing - growing in both width and height" do
    @manager.resize(TileManager::TILE_WIDTH * 3 + 10, TileManager::TILE_WIDTH * 2 + 10)
    @matrix.width.should == 6
    @matrix.height.should == 5
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199", "103,199", "104,199"],
                           ["99,200", "100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["99,201", "100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["99,202", "100,202", "101,202", "102,202", "103,202", "104,202"],
                           ["99,203", "100,203", "101,203", "102,203", "103,203", "104,203"]
                          ]
  end

  it "resizing - reducing width" do
    @manager.resize(TileManager::TILE_WIDTH * 2, TileManager::TILE_WIDTH * 2)
    @matrix.width.should == 4
    @matrix.height.should == 4
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199"],
                           ["99,200", "100,200", "101,200", "102,200"],
                           ["99,201", "100,201", "101,201", "102,201"],
                           ["99,202", "100,202", "101,202", "102,202"]
                          ]
  end    

  it "resizing - reducing both width and height" do
    @manager.resize(TileManager::TILE_WIDTH * 2, TileManager::TILE_WIDTH)
    @matrix.width.should == 4
    @matrix.height.should == 3
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199"],
                           ["99,200", "100,200", "101,200", "102,200"],
                           ["99,201", "100,201", "101,201", "102,201"]
                          ]
  end    

  it "panning without changing matrix" do
    @manager.pan(TileManager::TILE_WIDTH - 10, TileManager::TILE_WIDTH - 20)
    matrix_dump.should == @initial_dump
    @manager.offset_x.should == TileManager::TILE_WIDTH - 10
    @manager.offset_y.should == TileManager::TILE_WIDTH - 20
  end

  it "panning by 1 column to the right" do
    @manager.pan(TileManager::TILE_WIDTH, 0)
    matrix_dump.should == [
                           ["98,199", "99,199", "100,199", "101,199", "102,199"],
                           ["98,200", "99,200", "100,200", "101,200", "102,200"],
                           ["98,201", "99,201", "100,201", "101,201", "102,201"],
                           ["98,202", "99,202", "100,202", "101,202", "102,202"]
                          ]
    @manager.offset_x.should == 0
  end

  it "panning by 1 column right, 1 row down" do
    @manager.pan(TileManager::TILE_WIDTH + 10, TileManager::TILE_WIDTH + 12)
    matrix_dump.should == [
                           ["98,198", "99,198", "100,198", "101,198", "102,198"],
                           ["98,199", "99,199", "100,199", "101,199", "102,199"],
                           ["98,200", "99,200", "100,200", "101,200", "102,200"],
                           ["98,201", "99,201", "100,201", "101,201", "102,201"]
                          ]
    @manager.offset_x.should == 10
    @manager.offset_y.should == 12
  end

  it "panning by 1 column to the left" do
    @manager.pan(-1, 0)
    matrix_dump.should == [
                           ["100,199", "101,199", "102,199", "103,199", "104,199"],
                           ["100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["100,202", "101,202", "102,202", "103,202", "104,202"]
                          ]
    @manager.offset_x.should == TileManager::TILE_WIDTH - 1
  end

  it "panning by 1 column left, 1 row up" do
    @manager.pan(-12, -3)
    matrix_dump.should == [
                           ["100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["100,202", "101,202", "102,202", "103,202", "104,202"],
                           ["100,203", "101,203", "102,203", "103,203", "104,203"]
                          ]
    @manager.offset_x.should == TileManager::TILE_WIDTH - 12
    @manager.offset_y.should == TileManager::TILE_WIDTH - 3
  end

  it "cumulative panning" do
    @manager.pan(10, 12)
    matrix_dump.should == @initial_dump
    @manager.pan(TileManager::TILE_WIDTH - 3, TileManager::TILE_WIDTH - 6)
    matrix_dump.should == [
                           ["98,198", "99,198", "100,198", "101,198", "102,198"],
                           ["98,199", "99,199", "100,199", "101,199", "102,199"],
                           ["98,200", "99,200", "100,200", "101,200", "102,200"],
                           ["98,201", "99,201", "100,201", "101,201", "102,201"]
                          ]
    @manager.offset_x.should == 7
    @manager.offset_y.should == 6
  end

end
