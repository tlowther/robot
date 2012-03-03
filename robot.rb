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
    
    # STILL NEED TO SWAP x AND Y
    @factory = Array.new(@x) { Array.new(@y){' '} }
    @factory[0] = Array.new(@x) { "*" }
    @factory[@x-1] = Array.new(@x) { "*" }
    @factory = @factory.transpose # only works on square areas
    @factory[0] = Array.new(@y){ "*" }
    @factory[@y-1] = Array.new(@y){ "*" }
    @factory = @factory.transpose # only works on square areas
  end

  def place_pkg(x, y, d1, d2, type)
    (x..(x+d1-1)).each do |i|
      (y..(y+d2-1)).each do |j|
        @factory[i][j] = type
      end
    end
    self
  end
  
  def show_factory
    @factory.each { |a| puts a.join(' ') }
    self
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
    dir = STDIN.readline.chomp
    if ORIENTATION[dir].nil?
      puts "Invalid orientation, please try again."
      return nil
    end
    @factory[x][y] = ORIENTATION[dir]
    @location = [x,y,ORIENTATION[dir]]
    self
  end

  def move_robot_forever
    while true do
      move_robot
      show_factory
    end
    puts "Execution never gets here!"
  end
  
  def move_robot
    puts "Enter movement command (N, E, S, W):"
    l = STDIN.readline.chomp
    unless MOVES.keys.include?(l)
      puts "Invalid input, enter movement command (N, E, S, W)!"
      return nil
    end
    this_move = MOVES[l]

    new_x = @location[0] + this_move[0]
    new_y = @location[1] + this_move[1]

    if @factory[new_x][new_y] == ' '
      @factory[new_x][new_y] = ORIENTATION[l]
      @factory[@location[0]][@location[1]] = ' '
      @location = [new_x, new_y, ORIENTATION[l]]
    else
      puts "Cannot move, try alternative direction (this_move => #{this_move})." 
    end
    self
  end
  
end 

# class Floor
#   
#   def initialise(x,y)
#     @plan = Array.new(@y) { Array.new(@x){' '} }
#   end
#   
#   def show
#     
#   end
#   
#   def get(x,y)
#     @plan[x][y]
#   end
# 
#   def set(x,y,value)
#     @plan[x][y] = value
#   end
#   
# end


