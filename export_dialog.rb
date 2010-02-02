class ExportDialog < Wx::Dialog

  def tiles_per_file
    @tpf_choice.string_selection.to_i
  end

  def hash_size
    @hs_choice.string_selection.to_i
  end
  
  def initialize(parent)
    super(parent, :title => 'Export')
    grid = Wx::FlexGridSizer.new(2, 2, 5, 5)

    label = Wx::StaticText.new(self, :label => "Tiles per file")
    @tpf_choice = Wx::Choice.new(self, :choices => %w(1 8 16 32 64 256))
    grid.add(label, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)
    grid.add(@tpf_choice, 0, Wx::GROW|Wx::ALL, 5)
    
    label = Wx::StaticText.new(self, :label => "Hash size")
    @hs_choice = Wx::Choice.new(self, :choices => %w(1 5 11 23 47 97))    
    grid.add(label, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)
    grid.add(@hs_choice, 0, Wx::GROW|Wx::ALL, 5)

    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    sizer.add(grid, 0, Wx::ALL, 5)
    
    button_sizer = create_button_sizer(Wx::OK|Wx::CANCEL)
    sizer.add(button_sizer, 0, Wx::ALIGN_CENTER_VERTICAL|Wx::ALL, 5)

    self.sizer = sizer
    sizer.fit(self)

    evt_choice(@tpf_choice) {|event| @hs_choice.string_selection = '1' if tiles_per_file != 1}
    evt_choice(@hs_choice) {|event| @tpf_choice.string_selection = '1' if hash_size != 1}
  end
end
