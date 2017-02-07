require 'sketchup.rb'

def copy_obj(obj)
  c = obj.copy
  c.material = obj.material
  return c
end

def erase
  model = Sketchup.active_model
  model.entities.erase_entities model.entities.to_a
end

def move(group, dx, dy, dz)
  vector = Geom::Vector3d.new dx, dy, dz
  t = Geom::Transformation.translation vector
  group.transformation =  group.transformation*t
end

def rotate_x(group, x, y, z, angle)
  vector = Geom::Vector3d.new 1, 0, 0
  rotate(group, vector, x, y, z, angle)
end

def rotate_y(group, x, y, z, angle)
  vector = Geom::Vector3d.new 0, 1, 0
  rotate(group, vector, x, y, z, angle)
end

def rotate_z(group, x, y, z, angle)
  vector = Geom::Vector3d.new 0, 0, 1
  rotate(group, vector, x, y, z, angle)
end

def rotate(group, vector, x, y, z, angle)
  point = Geom::Point3d.new x, y, z
  angle = angle * Math::PI / 180
  t = Geom::Transformation.rotation point, vector, angle
  print group.transformation
  group.transformation =  group.transformation*t
end


def make_cube(group, lx, ly, lz)
  cube = group.entities.add_group
  cube.name = "cube"
  pt1 = [0, 0, 0]
  pt2 = [lx, 0, 0]
  pt3 = [lx, ly, 0]
  pt4 = [0, ly, 0]
  new_face = cube.entities.add_face pt1, pt2, pt3, pt4
  new_face.pushpull -lz
  return cube
end

def get_bom obj, map
  unless obj.respond_to?(:name)
    return
  end

  is_cube = false
  obj.entities.each do |e|
    if e.is_a? Sketchup::Edge
      is_cube = true
      break
    end
  end

  if is_cube
    a = obj.local_bounds.depth
    b = obj.local_bounds.width
    c = obj.local_bounds.height
    l = [a, b, c]
    min = l.min
    max = l.max
    l.delete(min)
    l.delete(max)
    mid = l[0]
    key = "#{min}x#{mid}"
    unless map[key]
      map[key] = {}
    end

    unless map[key][max]
      map[key][max] = 0
    end

    map[key][max] += 1
    return
  end

  obj.entities.each do |e|
    begin
      get_bom e, map
    rescue => ex
      puts "error: #{ex}"
    end
  end
end

def print_bom model
  map = {}
  get_bom model, map
  map.each do |k, v|
    total_length = 0
    puts " Lumber size: #{k}"
    v.each do |k, count|
      puts "    #{k} #{count} pieces"
      total_length += k*count
    end
    puts "Total length: #{Length.new(total_length)}"
  end
end
