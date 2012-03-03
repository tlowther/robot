# ROBOT
class Factory 
  
  $Factory = Array.new(){Array.new(){}}
  
  $Location = Array.new(3)
  
  $Orientation = Hash.new(0)
  $Orientation["W"] = "^"
  $Orientation["D"] = ">"
  $Orientation["S"] = "V"
  $Orientation["A"] = "<"
  
  $Moves = Hash.new(0)
  $Moves["W"] = [0,-1]
  $Moves["A"] = [-1,0]
  $Moves["D"] = [1,0]
  $Moves["S"] = [0,1]
  
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
    $Moves.each { |a| puts a.join(' ')}
    $Orientation.each { |a| puts a.join(' ')}
  end

  def self.place_pkg(x, y, d1, d2, type)
    @x = x
    @y = y
    @d1 = d1
    @d2 = d2
    @type = type
    break if ((@x < 1) or (@y < 1))
    puts "Enter x and y coordinates > 0, please try again."
    end
    break if ((@d1 < 1) && (@d1 < 1))
    puts "Enter package dimensions greater than zero, please try again."
    end
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
  
  def self.place_robot()
    puts "Enter x coordinate:"
    @x = STDIN.readline.chomp
    puts "Enter y coordinate:"
    @y = STDIN.readline.chomp
    puts "Enter x and y coordinates > 0, please try again." if (@x < 1 or @y < 1) break end
    puts "Enter orientation (W=up,A=left,D=right,S=down):"
    @dir = STDIN.readline.chomp
    puts "Invalid orientation, please try again." if @@Orientation[@dir] == 0 break end
    if (@@Factory[@x][@y] != " ")
      puts "Cannot place robot at chosen coordinates."
      puts "Enter x coordinate:"
      @x = STDIN.readline.chomp
      puts "Enter y coordinate:"
      @y = STDIN.readline.chomp
      puts "Enter direction (W=up,A=left,D=right,S=down):"
      @dir = STDIN.readline.chomp
      if (@x < 1 or @y < 1) puts "Enter x and y coordinates > 0, please try again."
      end
      if (@@Orientation[@dir] == 0) puts "Invalid orientation, please try again."
      end
    end
    
      
    @@Factory[@x][@y] = @@Orientation[@dir]
    @@Location = [@x,@y,@@Orientation[@dir]]
  end

  def self.move_robot()
    while @l = STDIN.readline.chomp
      puts "Enter movement command (W=up,A=left,D=right,S=down):"
      puts "Invalid input, enter movement command (W=up,A=left,D=right,S=down):" if @@Moves[@l] == 0 return
      moves = @@Moves[@l]
      if @@Factory[@@Location[0] + moves[1], @@Location[1] + moves[1]] = ' ' then
        @@Factory[@@Location[0], @@Location[1]] = ' '
        @@Factory[@@Location[0] + moves[1], @@Location[1] + moves[1]] = @@Orientation[@l]
        else puts "Cannot move, try alternative direction." 
      end
      @@Factory.each { |a| puts a.join(' ')}
    end
  end
end
  
