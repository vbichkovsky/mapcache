require File.dirname(__FILE__) + '/matrix_mgr_spec_helper.rb'

describe MatrixManager, "usual panning and resizing" do
  include MatrixManagerSpecHelper

  before do
    @manager = MatrixManager.new(99, 199, 9, 0, 0, TILE_WIDTH * 3, TILE_WIDTH * 2, tm_stub_wo_zoom)
    @initial_dump = matrix_dump
  end

  it 'initial matrix dump' do
    @manager.matrix.width.should == 5
    @manager.matrix.height.should == 4
    @initial_dump.should == [
                             ["99,199", "100,199", "101,199", "102,199", "103,199"],
                             ["99,200", "100,200", "101,200", "102,200", "103,200"],
                             ["99,201", "100,201", "101,201", "102,201", "103,201"],
                             ["99,202", "100,202", "101,202", "102,202", "103,202"]
                            ]
  end

  it "resizing window without changing matrix" do
    @manager.resize(TILE_WIDTH * 3 - 10, TILE_WIDTH * 2 - 10)
    matrix_dump.should == @initial_dump
  end

  it "resizing - growing in width" do
    @manager.resize(TILE_WIDTH * 3 + 10, TILE_WIDTH * 2)
    @manager.matrix.width.should == 6
    @manager.matrix.height.should == 4
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199", "103,199", "104,199"],
                           ["99,200", "100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["99,201", "100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["99,202", "100,202", "101,202", "102,202", "103,202", "104,202"]
                          ]
  end

  it "resizing - growing in both width and height" do
    @manager.resize(TILE_WIDTH * 3 + 10, TILE_WIDTH * 2 + 10)
    @manager.matrix.width.should == 6
    @manager.matrix.height.should == 5
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199", "103,199", "104,199"],
                           ["99,200", "100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["99,201", "100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["99,202", "100,202", "101,202", "102,202", "103,202", "104,202"],
                           ["99,203", "100,203", "101,203", "102,203", "103,203", "104,203"]
                          ]
  end

  it "resizing - reducing width" do
    @manager.resize(TILE_WIDTH * 2, TILE_WIDTH * 2)
    @manager.matrix.width.should == 4
    @manager.matrix.height.should == 4
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199"],
                           ["99,200", "100,200", "101,200", "102,200"],
                           ["99,201", "100,201", "101,201", "102,201"],
                           ["99,202", "100,202", "101,202", "102,202"]
                          ]
  end    

  it "resizing - reducing both width and height" do
    @manager.resize(TILE_WIDTH * 2, TILE_WIDTH)
    @manager.matrix.width.should == 4
    @manager.matrix.height.should == 3
    matrix_dump.should == [
                           ["99,199", "100,199", "101,199", "102,199"],
                           ["99,200", "100,200", "101,200", "102,200"],
                           ["99,201", "100,201", "101,201", "102,201"]
                          ]
  end    

  it "panning without changing matrix" do
    @manager.pan(TILE_WIDTH - 10, TILE_WIDTH - 20)
    matrix_dump.should == @initial_dump
    @manager.offset_x.should == TILE_WIDTH - 10
    @manager.offset_y.should == TILE_WIDTH - 20
  end

  it "panning by 1 column to the right" do
    @manager.pan(TILE_WIDTH, 0)
    matrix_dump.should == [
                           ["98,199", "99,199", "100,199", "101,199", "102,199"],
                           ["98,200", "99,200", "100,200", "101,200", "102,200"],
                           ["98,201", "99,201", "100,201", "101,201", "102,201"],
                           ["98,202", "99,202", "100,202", "101,202", "102,202"]
                          ]
    @manager.offset_x.should == 0
  end

  it "panning by 1 column right, 1 row down" do
    @manager.pan(TILE_WIDTH + 10, TILE_WIDTH + 12)
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
    @manager.offset_x.should == TILE_WIDTH - 1
  end

  it "panning by 1 column left, 1 row up" do
    @manager.pan(-12, -3)
    matrix_dump.should == [
                           ["100,200", "101,200", "102,200", "103,200", "104,200"],
                           ["100,201", "101,201", "102,201", "103,201", "104,201"],
                           ["100,202", "101,202", "102,202", "103,202", "104,202"],
                           ["100,203", "101,203", "102,203", "103,203", "104,203"]
                          ]
    @manager.offset_x.should == TILE_WIDTH - 12
    @manager.offset_y.should == TILE_WIDTH - 3
  end

  it "cumulative panning" do
    @manager.pan(10, 12)
    matrix_dump.should == @initial_dump
    @manager.pan(TILE_WIDTH - 3, TILE_WIDTH - 6)
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

describe MatrixManager, "zooming" do
  include MatrixManagerSpecHelper

  before do
    @manager = MatrixManager.new(99, 199, 8, 0, 0, TILE_WIDTH, TILE_WIDTH, tm_stub_with_zoom)
  end

  it 'initial values' do
    @manager.matrix.width.should == 3
    @manager.matrix.height.should == 3
    matrix_dump.should == [
                             ["99,199,8", "100,199,8", "101,199,8"],
                             ["99,200,8", "100,200,8", "101,200,8"],
                             ["99,201,8", "100,201,8", "101,201,8"]
                            ]
    @manager.offset_x.should == 0
    @manager.offset_y.should == 0
  end

  it 'zooming in' do
    @manager.zoom_in(TILE_WIDTH / 3, TILE_WIDTH / 5)
    matrix_dump.should == [
                           ["200,399,9", "201,399,9", "202,399,9"], 
                           ["200,400,9", "201,400,9", "202,400,9"], 
                           ["200,401,9", "201,401,9", "202,401,9"]
                          ]
    @manager.offset_x.should == 214
    @manager.offset_y.should == 26
  end

  it 'zooming out' do
    @manager.zoom_out(TILE_WIDTH / 3, TILE_WIDTH / 5)
    matrix_dump.should == [
                           ["49,99,7", "50,99,7", "51,99,7"], 
                           ["49,100,7", "50,100,7", "51,100,7"], 
                           ["49,101,7", "50,101,7", "51,101,7"]
                          ]
    @manager.offset_x.should == 86
    @manager.offset_y.should == 103
  end

  it 'zooming in for MAX_ZOOM' do
    z = MAX_ZOOM
    @manager = MatrixManager.new(99, 199, z, 15, 16, TILE_WIDTH, TILE_WIDTH, tm_stub_with_zoom)
    (init_dump = matrix_dump).should == [
                           ["99,199,#{z}", "100,199,#{z}", "101,199,#{z}"],
                           ["99,200,#{z}", "100,200,#{z}", "101,200,#{z}"],
                           ["99,201,#{z}", "100,201,#{z}", "101,201,#{z}"]
                          ]
    @manager.offset_x.should == 15
    @manager.offset_y.should == 16

    @manager.zoom_in(76, 54)
    matrix_dump.should == init_dump
    @manager.offset_x.should == 15
    @manager.offset_y.should == 16
  end

  it 'zooming out for zoom = 0' do
    @manager = MatrixManager.new(0, 0, 0, 15, 16, TILE_WIDTH, TILE_WIDTH, tm_stub_with_zoom)
    (init_dump = matrix_dump).should == [
                                         ["0,0,0", "0,0,0", "0,0,0"],
                                         ["0,0,0", "0,0,0", "0,0,0"],
                                         ["0,0,0", "0,0,0", "0,0,0"]
                                        ]
    @manager.offset_x.should == 15
    @manager.offset_y.should == 16

    @manager.zoom_out(76, 54)
    matrix_dump.should == init_dump
    @manager.offset_x.should == 15
    @manager.offset_y.should == 16
  end

end

describe MatrixManager, "wraparound" do
  include MatrixManagerSpecHelper

  before do
    @manager = MatrixManager.new(0, 0, 2, 0, 0, TILE_WIDTH * 2, TILE_WIDTH * 2, tm_stub_with_zoom)
  end

  it 'initial matrix' do
    matrix_dump.should == [
                           ["0,0,2", "1,0,2", "2,0,2", "3,0,2"],
                           ["0,1,2", "1,1,2", "2,1,2", "3,1,2"],
                           ["0,2,2", "1,2,2", "2,2,2", "3,2,2"],
                           ["0,3,2", "1,3,2", "2,3,2", "3,3,2"]
                          ]
  end

  it 'resize' do
    @manager.resize(TILE_WIDTH * 3, TILE_WIDTH * 3)
    matrix_dump.should == [
                           ["0,0,2", "1,0,2", "2,0,2", "3,0,2", "0,0,2"],
                           ["0,1,2", "1,1,2", "2,1,2", "3,1,2", "0,1,2"],
                           ["0,2,2", "1,2,2", "2,2,2", "3,2,2", "0,2,2"],
                           ["0,3,2", "1,3,2", "2,3,2", "3,3,2", "0,3,2"],
                           ["0,0,2", "1,0,2", "2,0,2", "3,0,2", "0,0,2"]
                          ]
  end

  it 'pan' do
    @manager.pan(-1, -1)
    matrix_dump.should == [
                           ["1,1,2", "2,1,2", "3,1,2", "0,1,2"], 
                           ["1,2,2", "2,2,2", "3,2,2", "0,2,2"], 
                           ["1,3,2", "2,3,2", "3,3,2", "0,3,2"], 
                           ["1,0,2", "2,0,2", "3,0,2", "0,0,2"]
                          ]
  end

  it 'zoom out' do
    @manager.zoom_out(15, 16)
    matrix_dump.should == [
                           ["1,1,1", "0,1,1", "1,1,1", "0,1,1"], 
                           ["1,0,1", "0,0,1", "1,0,1", "0,0,1"], 
                           ["1,1,1", "0,1,1", "1,1,1", "0,1,1"], 
                           ["1,0,1", "0,0,1", "1,0,1", "0,0,1"]
                          ]
  end

end
