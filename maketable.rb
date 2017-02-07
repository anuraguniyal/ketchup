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

    skids  = make_skids(shed)

    print_bom Sketchup.active_model
    return table
  end

  def make_skids(shed)
    skids = shed.entities.add_group
    frame.name = "skids"
    frame.material = "#330000"

    # skid size 4x4
    sz = 4

    x = (@width-sz)/2.0
    s1 = make_cube(skids, sz, @length, sz)
    s2 = copy_obj(s1)
    move(s2, x, 0, 0)
    s3 = copy_obj(s2)
    move(s3, x, 0, 0)
    return skids
  end


erase
shed = Shed.new(7*12, 8*12, 8*12).make()
