require 'sketchup.rb'
require 'utils.rb'

def register_makebed
  #return if $_makebed_registered
  # # Add a menu item to launch our plugin.
  UI.menu("Plugins").add_item("Make Bed") {
    # # Show the Ruby Console at startup so we can
    # # see any programming errors we may make.
    SKETCHUP_CONSOLE.show
    $_makebed_registered = true
    prompts = ["Bed width (in.)", "Bed length (in.)", "Bed height (in.)", "Lumber Width", "Lumber Length"]
    defaults = [60, 80, 15.5, 1.5, 3.5]
    input = UI.inputbox(prompts, defaults, "Enter the size of bed.")
    next unless input
    UI.messagebox("Making a bed #{input[0]}x#{input[1]}")
    bed = Bed.new(input[0].to_i, input[1].to_i, input[2].to_i)
    bed.lumber_w = input[3].to_i
    bed.lumber_h = input[4].to_i
    bed.make
  }
end

class Bed
  attr_accessor :lumber_w, :lumber_l, :slat_w, :slat_h
  attr_reader :width, :height, :length
  def initialize(width, length, height)
    @width = width
    @length = length
    @height = height
    self.lumber_w = 1.5
    self.lumber_l = 2.5
    self.slat_w = 0.625#0.75
    self.slat_h = 2.5

  end


  def make(cover)
    frame = make_frame(cover)
    #make_boards
    print_bom Sketchup.active_model
    return frame
  end


  def make_frame(cover)
    frame = Sketchup.active_model.entities.add_group
    box1 = make_box(frame, self.width/2, self.length/2, self.height, false, cover)
    box2 = make_box(frame, self.width/2, self.length/2, self.height, true, cover)
    move(box2, 0, self.length/2, 0)
    box3 = make_box(frame, self.width/2, self.length/2, self.height, true, cover)
    rotate_z(box3, 0, self.length/4, 0, 180)
    box4 = make_box(frame, self.width/2, self.length/2, self.height, false, cover)
    rotate_z(box4, 0, self.length/2, 0, 180)
    return frame
  end

  def make_box(frame, width, length, height, leg, cover)
    bw = self.lumber_w
    bl = self.lumber_l
    box = frame.entities.add_group
    box.name = "box"

    zbar1 = make_cube(box, bl, bw, height)
    zbar2 = zbar1.copy
    zbar3 = zbar1.copy
    zbar4 = zbar1.copy
    move(zbar2, width - bl, 0, 0)
    move(zbar3, width - bl, length - bw, 0)
    move(zbar4, 0, length - bw, 0)

    ybar1 = make_cube(box, bw, length-2*bw, bl)
    ybar2 = ybar1.copy
    ybar3 = ybar1.copy
    move(ybar1, 0, bw, 0)
    move(ybar2, 0, bw, height - bl)
    move(ybar3, width - bw, bw, height - bl)

    xbar1 = make_cube(box, width-2*bl, bw, bl)
    xbar2 = xbar1.copy
    xbar3 = xbar1.copy
    xbar4 = xbar1.copy
    move(xbar1, bl, 0, 0)
    move(xbar2, bl, length - bw, 0)
    move(xbar3, bl, length - bw, height - bl)
    move(xbar4, bl, 0, height - bl)

    # add slats
    slat_z = height# - self.slat_w
    slat_x = 0
    n_slats = 6
    w = length - 2*self.slat_h
    # (n+1)*gap + n*bl = w => gap = (w-n*bl)/(n+1)
    gap = (w-n_slats*self.slat_h)/(n_slats+1)
    puts "slat gap: #{gap}"
    n_slats.times do |i|
      slat = make_cube(box, width, self.slat_h, self.slat_w)
      move(slat, slat_x, self.slat_h + bw+gap*(i+1)+i*self.slat_h, slat_z)
    end

    if cover == 0
    add_vertical_boards(box, width, height, length, leg)
    end
    if cover == 2
    add_mixed_boards(box, width, height, length, leg)
    end
    if cover == 1
    add_horiz_boards(box, width, height, length, leg)
    end

    return box
 end

 def add_horiz_boards(box, width, height, length, leg)
    # add boards to cover
    color = "#6e2701"
    n=5
    board_t = 0.625
    board_w = 3.375
    gap = 0
    y = -board_t
    if leg
      y = length
    end
    n.times do |i|
      horiz = make_cube(box, width, board_t, board_w)
      move(horiz, 0, y, i*(board_w+gap))
      horiz.material = color
    end

    y = -board_t
    if leg
      y = 0
    end

    n.times do |i|
      #next if i < 3
      horiz = make_cube(box, board_t, length+board_t, board_w)
      move(horiz, width, y, i*(board_w+gap))
      horiz.material = color
    end

    return box
  end


 def add_mixed_boards(box, width, height, length, leg)
    # add boards to cover
    color = "#6e2701"
    board_t = 0.625
    board_w = 3.375
    gap = 0
    h=height-2*board_w
    y = -board_t
    if leg
      y = length
    end
    9.times do |i|
      vert = make_cube(box, board_w, board_t, h)
      move(vert, i*(board_w+gap), y, board_w)
      vert.material = color
    end

    gap=0
    12.times do |i|
      vert = make_cube(box, board_t, board_w, h)
      move(vert, width, -board_t + i*(board_w+gap), board_w)
      vert.material = color
    end

    horiz_x = make_cube(box, width, board_t, board_w)
    move(horiz_x, 0, y, height-board_w)
    horiz_x.material = color

    horiz_y = make_cube(box, board_t, length+board_t, board_w)
    move(horiz_y, width, -board_t, height-board_w)
    horiz_y.material = color

    horiz_x = make_cube(box, width, board_t, board_w)
    move(horiz_x, 0, y, 0)
    horiz_x.material = color

    horiz_y = make_cube(box, board_t, length+board_t, board_w)
    move(horiz_y, width, -board_t, 0)
    horiz_y.material = color
    return box
  end

 def add_vertical_boards(box, width, height, length, leg)
    # add boards to cover
    color = "#6e2701"
    board_t = 0.625
    board_w = 3.375
    gap = 0
    h=height+1
    y = -board_t
    if leg
      y = length
    end
    9.times do |i|
      vert = make_cube(box, board_w, board_t, h)
      move(vert, i*(board_w+gap), y, 0)
      vert.material = color
    end

    12.times do |i|
      vert = make_cube(box, board_t, board_w, h)
      move(vert, width, -board_t + i*(board_w+gap), 0)
      vert.material = color
    end

    return box
  end

  def make_boards
    head_board = make_head_board(self.width, self.height*2)
    move(head_board, -self.width/2, -self.lumber_w, 0)
    leg_board = make_leg_board(self.width, self.height)
    move(leg_board, -self.width/2, self.length, 0)
  end

  def make_head_board(width, height)
    board = Sketchup.active_model.entities.add_group
    left = make_cube(board, self.lumber_l, self.lumber_w, height)
    right = left.copy
    move(right, width - self.lumber_l, 0, 0)
    bottom = make_cube(board, width-2*self.lumber_l, self.lumber_w, self.lumber_l)
    top = bottom.copy
    move(top, self.lumber_l, 0, height - self.lumber_l)
    move(bottom, self.lumber_l, 0, height/2 - self.lumber_l)

    mid1 = make_cube(board, self.lumber_l, self.lumber_w, height/2-self.lumber_l)
    mid2 = mid1.copy
    move(mid1, width/3, 0, height/2)
    move(mid2, 2*width/3, 0, height/2)
    return board
  end

  def make_leg_board(width, height)
    board = Sketchup.active_model.entities.add_group
    left = make_cube(board, self.lumber_l, self.lumber_w, height)
    right = left.copy
    move(right, width - self.lumber_l, 0, 0)
    bottom = make_cube(board, width-2*self.lumber_l, self.lumber_w, self.lumber_l)
    top = bottom.copy
    move(top, self.lumber_l, 0, height - self.lumber_l)
    move(bottom, self.lumber_l, 0, 0)

    mid1 = make_cube(board, self.lumber_l, self.lumber_w, height-2*self.lumber_l)
    mid2 = mid1.copy
    move(mid1, width/3, 0, self.lumber_l)
    move(mid2, 2*width/3, 0, self.lumber_l)
    return board
  end

end

erase
bed = Bed.new(60, 80, 14.5).make(1)
bed = Bed.new(60, 80, 14.5).make(0)
move(bed, 100, 0, 0)
bed = Bed.new(60, 80, 14.5).make(2)
move(bed, 0, 100, 0)
register_makebed
