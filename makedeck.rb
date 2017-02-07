require 'sketchup.rb'
require 'utils.rb'

class Deck
  attr_accessor :lumber_w, :lumber_t
  attr_reader :width, :height, :length, :box_height
  def initialize(width, length, height, cornerspace, box_height)
    @width = width
    @length = length
    @height = height
    @box_height = box_height
    @cornerspace = cornerspace
    self.lumber_t = 1.5
    self.lumber_w = 5.5
    @material = "#6e2701"
  end


  def make()
    deck = Sketchup.active_model.entities.add_group

    # skid size 4x4
    post_sz = 4
    posts  = make_posts(deck, post_sz)

    floor = make_floor(deck, @width + @cornerspace, @length)
    move(floor, 0, 0, @height)
    return deck
  end

  def make_floor(deck, width, length)
    floor = deck.entities.add_group
    floor.name = "floor"
    floor.material = @material

    border1 = make_cube(floor, width, self.lumber_w, self.lumber_t)
    border2 = copy_obj(border1)
    move(border2, 0, length - self.lumber_w, 0)
    stripes = make_vert_stripes(floor, width, length-2*self.lumber_w)
    move(stripes, 0, self.lumber_w, 0)

    # make box wall
    box_wall_border1 = make_cube(floor, self.lumber_t, self.lumber_w, self.box_height)
    move(box_wall_border1, self.width, 0 , 0)
    box_wall_border2 = copy_obj(box_wall_border1)
    move(box_wall_border2, 0, length - self.lumber_w, 0)

    box_wall = make_vert_stripes(floor, self.box_height, length-2*self.lumber_w)
    move(box_wall, self.width+self.lumber_t, self.lumber_w, 0)
    rotate_y(box_wall, 0, 0, 0, -90)

    # make box top
    box_top_border1 = make_cube(floor, @cornerspace, self.lumber_w, self.lumber_t)
    move(box_top_border1, self.width, 0, self.box_height)
    box_top_border2 = copy_obj(box_top_border1)
    move(box_top_border2, 0, length - self.lumber_w, 0)

    box_top = make_vert_stripes(floor, @cornerspace, length-2*self.lumber_w)
    move(box_top, @width, self.lumber_w, self.box_height)
    return floor
  end

  def make_vert_stripes(floor, width, length)
    # add stripes
    stripes = floor.entities.add_group
    stripes.name = "stripes"
    n = (width/self.lumber_w).to_i + 1
    remain = width
    n.times do |i|
      x = i*self.lumber_w
      w = self.lumber_w
      remain -= w
      if remain < 0
        w = remain + self.lumber_w
      end
      slat = make_cube(stripes, w, length, self.lumber_t)
      move(slat, x, 0, 0)
      if remain < 0
        break
      end
    end
    return stripes
  end

  def make_posts(deck, sz)
    posts = deck.entities.add_group
    posts.name = "postss"
    posts.material = "#fff"

    x = (@width-sz)/2.0
    height = 8*12
    p1 = make_cube(posts, sz, sz, height)
    move(p1, 0, @length - sz, 0)
    p2 = make_cube(posts, sz, sz, height)
    move(p2, @width/2, @length - sz, 0)
    p3 = make_cube(posts, sz, sz, height)
    move(p3, @width, @length, 0)
    p4 = make_cube(posts, sz, sz, height)
    move(p4, @width, @length/2, 0)
    return posts
  end
end


erase
deck = Deck.new(10*12, 11*12, 7.5, 3*12, 19).make()
