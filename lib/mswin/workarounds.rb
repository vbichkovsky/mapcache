module Wx

  class DC
    def draw_bitmap(bitmap, x, y, draw_transp)
      m = MemoryDC.new
      m.select_object(bitmap)
      self.blit(x, y, bitmap.width, bitmap.height, m, 0, 0, self.logical_function, draw_transp)
      m.select_object(Wx::NULL_BITMAP)
    end
  end

end

