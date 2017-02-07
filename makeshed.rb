require 'sketchup.rb'
require 'utils.rb'

class Shed
  attr_accessor :lumber_w, :lumber_t
  attr_reader :width, :height, :length
  def initialize(width, length, height)
    @width = width
    @length = length
    @height = height
    self.lumber_t = 1.5
    self.lumber_w = 3.5
    @material = "#6e2701"
  end


  def make()
    shed = Sketchup.active_model.entities.add_group

    # skid size 4x4
    skid_sz = 4
    skids  = make_skids(shed, skid_sz)

    floor = make_frame(shed, @width, @length, 7, "floor", "#330000")
    # move floor above skids
    move(floor, 0, 0, skid_sz)

    # make walls
    left = make_frame(shed, @width, @length, 6, "left_wall", @material)
    # rotate

    rotate_y(left, 0, 0, 0, -90)
    #rotate_x(left, 0, self.lumber_t, 0, 90)
    # move wall above skids
    move(left, skid_sz+self.lumber_w, 0, -self.lumber_w)

    right = copy_obj(left)
    move(right, 0, 0 ,self.lumber_w - @width)

    w = @width-2*self.lumber_w
    back = make_frame(shed, @width, w, 6, "back_wall", @material)
    move(back, 0, 0, skid_sz+self.lumber_w)
    rotate_z(back, 0, 0, 0, 90)
    rotate_y(back, 0, 0, 0, -90)
    move(back, 0, self.lumber_w-@width, -self.lumber_w)

    front = copy_obj(back)
    move(back, 0, 0, self.lumber_w-@length)
    print_bom Sketchup.active_model
    return shed
  end

  def make_frame(shed, width, length, joists, name, material)
    frame = shed.entities.add_group
    frame.name = name
    frame.material = material

    band1 = make_cube(frame, self.lumber_t, length, self.lumber_w)
    band2 = copy_obj(band1)
    move(band2, width - self.lumber_t, 0, 0)

    # add joists
    l = width - 2*self.lumber_t
    gap = (length - self.lumber_t)/(joists-1)
    joists.times do |i|
      y = i*gap
      joist = make_cube(frame, l, self.lumber_t, self.lumber_w)
      move(joist, self.lumber_t, y, 0)
    end
    return frame
  end

  def make_skids(shed, sz)
    skids = shed.entities.add_group
    skids.name = "skids"
    skids.material = "#330000"

    x = (@width-sz)/2.0
    s1 = make_cube(skids, sz, @length, sz)
    s2 = copy_obj(s1)
    move(s2, x, 0, 0)
    s3 = copy_obj(s2)
    move(s3, x, 0, 0)
    return skids
  end
end


erase
shed = Shed.new(7*12, 8*12, 8*12).make()
