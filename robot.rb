# ROBOT
class Factory 
  
  $Factory = Array.new(){Array.new(){}}
  
  $Location = Array.new(3)
  
  $Orientation = Hash.new(0)
  $Orientation[1] = "^"
  $Orientation[3] = ">"
  $Orientation[4] = "V"
  $Orientation[2] = "<"
  
  $Moves = Hash.new(0)
  $Moves[1] = [0,-1]
  $Moves[2] = [-1,0]
  $Moves[3] = [1,0]
  $Moves[4] = [0,1]
  
  def initialize(x, y)
    @x = x
    @y = y
    $Factory = Array.new(@x){Array.new(@y){' '}}
    $Factory[0] = Array.new(@x){"*"}
    $Factory[@x-1] = Array.new(@x){"*"}
    $Factory = $Factory.transpose
    $Factory[0] = Array.new(@y){"*"}
    $Factory[@y-1] = Array.new(@y){"*"}
    $Factory = $Factory.transpose
    $Factory.each { |a| puts a.join(' ')}
  end

  def place_pkg(x, y, d1, d2, type)
    @x = x
    @y = y
    @d1 = d1
    @d2 = d2
    @type = type
    @package = Array.new(@d1){Array.new(@d2){@type}}
    i= 0
    j = 0
    loop do
      break unless (@d1 > i)
      loop do 
        break unless (@d2 > j)
        $Factory[x+i][y+j] = @package[i][j] 
        j+=1
      end
      i+=1
      j = 0
    end
    $Factory.each { |a| puts a.join(' ')}
  end
  
  def place_robot() 
    puts "Enter x coordinate:"
    @x = STDIN.readline.chomp
    @x = @x.to_i
    puts "Enter y coordinate:"
    @y = STDIN.readline.chomp
    @y = @y.to_i
#   puts "Enter x and y coordinates > 0, please try again." if (@x < 1 or @y < 1) break end
    puts "Enter orientation (1 = up, 2 = left, 3 = right, 4 = down):"
    @dir = STDIN.readline.chomp
#   puts "Invalid orientation, please try again." if $Orientation[@dir] == 0 break end
    @dir = @dir.to_i
    $Factory[@x][@y] = $Orientation[@dir]
    $Location = [@x,@y,$Orientation[@dir]]
    $Factory.each { |a| puts a.join(' ')}
  end
end  
  def move_robot()
    while @l = STDIN.readline.chomp
      puts "Enter movement command ((1 = up, 2 = left, 3 = right, 4 = down):"
      puts "Invalid input, enter movement command (1 = up, 2 = left, 3 = right, 4 = down):" if $Moves[@l] == 0 return
      moves = $Moves[@l]
      if $Factory[$Location[0] + moves[1], $Location[1] + moves[1]] = ' ' then
        $Factory[$Location[0], $Location[1]] = ' '
        $Factory[$Location[0] + moves[1], $Location[1] + moves[1]] = $Orientation[@l]
        else puts "Cannot move, try alternative direction." 
      end
      $Factory.each { |a| puts a.join(' ')}
    end
  end
end
