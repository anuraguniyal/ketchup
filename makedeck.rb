require 'sketchup.rb'
require 'utils.rb'

class Deck
  def initialize(width, length, height, cornerspace, box_height)
    @width = width
    @length = length
    @height = height
    @box_height = box_height
    @cornerspace = cornerspace
    @lumber_t = 1.5
    @lumber_w = 5.5
    @material = "#6e2701"
  end


  def make()
    deck = Sketchup.active_model.entities.add_group

    # skid size 4x4
    post_sz = 4
    posts  = make_posts(deck, post_sz)

    floor = make_floor3(deck, @width + @cornerspace, @length)
    move(floor, 0, 0, @height)
    return deck
  end

  def make_floor3(deck, width, length)
    # horizontal strips with vertical box
    floor = deck.entities.add_group
    floor.name = "floor"
    floor.material = @material

    border1 = make_cube(floor, @lumber_w, @length,@lumber_t)
    border2 = copy_obj(border1)
    move(border2, width - @lumber_w, 0, 0)
    stripes = make_vert_stripes(floor, length, width-2*@lumber_w)
    #move(stripes, 0, @lumber_w, 0)
    rotate_z(stripes, 0, 0, 0, 90)
    move(stripes, 0, -width+self.lumber_w, 0)

    # make box wall
    box_wall_border1 = make_cube(floor, @lumber_t, @lumber_w, @box_height)
    move(box_wall_border1, @width, 0 , 0)
    box_wall_border2 = copy_obj(box_wall_border1)
    move(box_wall_border2, 0, length - @lumber_w, 0)

    box_wall = make_vert_stripes(floor, @box_height, length-2*@lumber_w)
    move(box_wall, @width+@lumber_t, @lumber_w, 0)
    rotate_y(box_wall, 0, 0, 0, -90)

    # make box top
    box_top_border1 = make_cube(floor, @cornerspace, @lumber_w, @lumber_t)
    move(box_top_border1, @width, 0, @box_height)
    box_top_border2 = copy_obj(box_top_border1)
    move(box_top_border2, 0, length - @lumber_w, 0)

    box_top = make_vert_stripes(floor, @cornerspace, length-2*@lumber_w)
    move(box_top, @width, @lumber_w, @box_height)
    return floor
  end

  def make_floor2(deck, width, length)
    # simple vertical strips with border in middle too
    floor = deck.entities.add_group
    floor.name = "floor"
    floor.material = @material

    border1 = make_cube(floor, width, @lumber_w, @lumber_t)
    border2 = copy_obj(border1)
    border3 = copy_obj(border1)
    move(border2, 0, length - @lumber_w, 0)
    move(border3, 0, length/2, 0)
    stripes1 = make_vert_stripes(floor, width, (length/2)-2*@lumber_w)
    move(stripes1, 0, @lumber_w+length/2, 0)
    stripes2 = make_vert_stripes(floor, width, (length/2)-@lumber_w)
    move(stripes2, 0, @lumber_w, 0)

    # make box wall
    box_wall_border1 = make_cube(floor, @lumber_t, @lumber_w, @box_height)
    move(box_wall_border1, @width, 0 , 0)
    box_wall_border2 = copy_obj(box_wall_border1)
    move(box_wall_border2, 0, length - @lumber_w, 0)
    box_wall_border3 = copy_obj(box_wall_border1)
    move(box_wall_border3, -1, length/2, self.lumber_t)

    box_wall = make_vert_stripes(floor, @box_height, length-2*@lumber_w)
    move(box_wall, @width+@lumber_t, @lumber_w, 0)
    rotate_y(box_wall, 0, 0, 0, -90)

    # make box top
    box_top_border1 = make_cube(floor, @cornerspace, @lumber_w, @lumber_t)
    move(box_top_border1, @width, 0, @box_height)
    box_top_border2 = copy_obj(box_top_border1)
    move(box_top_border2, 0, length - @lumber_w, 0)
    box_top_border3 = copy_obj(box_top_border1)
    move(box_top_border3, 0, length/2, 0)

    box_top1 = make_vert_stripes(floor, @cornerspace, (length/2)-2*@lumber_w)
    move(box_top1, @width, @lumber_w+length/2, @box_height)
    box_top2 = make_vert_stripes(floor, @cornerspace, (length/2)-@lumber_w)
    move(box_top2, @width, @lumber_w, @box_height)
    return floor
  end
  def make_floor1(deck, width, length)
    # simple vertical strips with borders
    floor = deck.entities.add_group
    floor.name = "floor"
    floor.material = @material

    border1 = make_cube(floor, width, @lumber_w, @lumber_t)
    border2 = copy_obj(border1)
    move(border2, 0, length - @lumber_w, 0)
    stripes = make_vert_stripes(floor, width, length-2*@lumber_w)
    move(stripes, 0, @lumber_w, 0)

    # make box wall
    box_wall_border1 = make_cube(floor, @lumber_t, @lumber_w, @box_height)
    move(box_wall_border1, @width, 0 , 0)
    box_wall_border2 = copy_obj(box_wall_border1)
    move(box_wall_border2, 0, length - @lumber_w, 0)

    box_wall = make_vert_stripes(floor, @box_height, length-2*@lumber_w)
    move(box_wall, @width+@lumber_t, @lumber_w, 0)
    rotate_y(box_wall, 0, 0, 0, -90)

    # make box top
    box_top_border1 = make_cube(floor, @cornerspace, @lumber_w, @lumber_t)
    move(box_top_border1, @width, 0, @box_height)
    box_top_border2 = copy_obj(box_top_border1)
    move(box_top_border2, 0, length - @lumber_w, 0)

    box_top = make_vert_stripes(floor, @cornerspace, length-2*@lumber_w)
    move(box_top, @width, @lumber_w, @box_height)
    return floor
  end

  def make_vert_stripes(floor, width, length)
    # add stripes
    stripes = floor.entities.add_group
    stripes.name = "stripes"
    n = (width/@lumber_w).to_i + 1
    remain = width
    n.times do |i|
      x = i*@lumber_w
      w = @lumber_w
      if remain <= 0
        break
      end
      remain -= w
      if remain < 0
        w = remain + @lumber_w
      end
      slat = make_cube(stripes, w, length, @lumber_t)
      move(slat, x, 0, 0)
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
