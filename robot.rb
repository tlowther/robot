# ROBOT
class Factory
  
  ORIENTATION = { 
    "N" => "^",
    "E" => ">",
    "S" => "v",
    "W" => "<"
  }

  MOVES = {
    "N" => [ 0,-1],
    "E" => [ 1, 0],
    "S" => [ 0, 1],
    "W" => [-1, 0]
  }
  
  def initialize(x, y)
    @x = x
    @y = y
    
    bottom_row = top_row = Array.new(@x) { "*" }
    internal_row = Array.new(@x) { " " }
    internal_row[0] = "*"
    internal_row[-1]= "*"
    
    @floorplan = Array.new(@y) { Array.new(@x){' '} }
    @floorplan[0] =  top_row #inserts 'walls' top row of floor
    @floorplan[-1] = bottom_row #inserts 'walls' bottom row of floor

    (1..(@y-2)).each do |i| #inserts remaining internal rows
      @floorplan[i] = internal_row.dup
    end
  end
  
  def place_pkg(x, y, d1, d2, type)
    pkg = Package.new(x, y, d1, d2, type)
    (y..(y+d2-1)).each do |i|
      (x..(x+d1-1)).each do |j|
        @floorplan[i][j] = pkg
      end
    end
    self
  end
  
  def to_s
    nil
  end
  def show
    @floorplan.each { |a| puts a.join(' ') }
    nil
  end
  
  def place_robot
    puts "Enter x coordinate:"
    x = STDIN.readline.chomp.to_i
    puts "Enter y coordinate:"
    y = STDIN.readline.chomp.to_i
    if (x < 1 || y < 1)
      puts "Enter x and y coordinates > 0, please try again."
      return nil
    end
    puts "Enter orientation (N, E, S, W):"
    dir = STDIN.readline.chomp.upcase
    if ORIENTATION[dir].nil?
      puts "Invalid orientation, please try again."
      return nil
    end
    @floorplan[y][x] = ORIENTATION[dir]
    @location = [x,y,ORIENTATION[dir]]
    self
  end

  def move_robot_forever
    while true do
      move_robot
      show
    end
    puts "Execution never gets here!"
  end
  
  def move_robot
    puts "Enter movement command (N, E, S, W):"
    l = STDIN.readline.chomp.upcase
    unless MOVES.keys.include?(l)
      puts "Invalid input, enter movement command (N, E, S, W)!"
      return nil
    end
    this_move = MOVES[l]

    new_x = @location[0] + this_move[0]
    new_y = @location[1] + this_move[1]

    if @floorplan[new_y][new_x] == ' '
      @floorplan[new_y][new_x] = ORIENTATION[l]
      @floorplan[@location[1]][@location[0]] = ' '
      @location = [new_x, new_y, ORIENTATION[l]]
    
    elsif @floorplan[new_y][new_x] == '*'
      puts "Cannot move, try alternative direction (this_move => #{this_move})." 
    
    else 
      print "Cannot move to [#{new_x}, #{new_y}], "
      print "package at #{@floorplan[new_y][new_x].loc} " 
      puts "of dimensions #{@floorplan[new_y][new_x].dims}"
    
    end
    self
  end
  
end 

class Package
  
  def initialize(x, y, d1, d2, type)
    @x = x
    @y = y
    @d1 = d1
    @d2 = d2
    @type = type
  end
  
  def to_s
    @type
  end
  
  def dims
    [@d1, @d2]
  end

  def loc
    [@x, @y]
  end  

end


