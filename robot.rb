# ROBOT
class Factory 
  
  def initialize(@x, @y)
    @@Factory = Array.new(@x){Array.new(@y){' '}}
    i = 0
    j = 0
    @@Factory[0] = Array.new(@x){"*"}
    @@Factory[@x-1] = Array.new(@x){"*"}
    @@Factory = @@Factory.transpose
    @@Factory[0] = Array.new(@y){"*"}
    @@Factory[@y-1] = Array.new(@y){"*"}
    @@Factory = @@Factory.transpose
    @@Factory.each { |a| puts a.join(' ')}
  end

  def self.place_pkg(@x, @y, @d1, @d2, @type)
    puts "Enter x and y coordinates > 0, please try again." if (@x < 1 or @y < 1) return end
    puts "Enter package dimensions greater than zero, please try again." if (@d1 < 1) && (@d1 < 1) return end
    else
      @package = Array.new(@d1){Array.new(@d2){type}}
      i= 0
      j = 0
      loop do
        break unless @d1 > i
        loop do 
          break unless @d2 > j
          @@factory[x+i][y+j] = @package[i][j] 
          j+=1
        end
        i+=1
        j = 0
      end
    end
    @@Factory.each { |a| puts a.join(' ')}
  end
  
  def self.place_robot()
    puts "Enter x coordinate:"
    @x = STDIN.readline.chomp
    puts "Enter y coordinate:"
    @y = STDIN.readline.chomp
    puts "Enter x and y coordinates > 0, please try again." if (@x < 1 or @y < 1) return end
    puts "Enter orientation (N, E, S or W):"
    @dir = STDIN.readline.chomp
    @orientation = Hash.new(0)
    puts "Invalid orientation, please try again." if @orientation[@dir] == 0 return end
    @orientation["N"] = "^"
    @orientation["E"] = ">"
    @orientation["N"] = "V"
    @orientation["N"] = "<"
    
    while @@factory[@x][@y] != " "
      puts "Cannot place robot at chosen coordinates."
      puts "Enter x coordinate:"
      @x = STDIN.readline.chomp
      puts "Enter y coordinate:"
      @y = STDIN.readline.chomp
      puts "Enter x and y coordinates > 0, please try again." if (@x < 1 or @y < 1) return end
      puts "Enter direction (N, E, S or W):"
      @dir = STDIN.readline.chomp
      puts "Invalid orientation, please try again." if @orientation[@dir] == 0 return end
    end
      
    @@factory[@x][@y] = @orientation[@dir]    
    
    end

  def move_robot
    while l = STDIN.readline.chomp
    puts "got input '#{l}'"
  end
  
  
  class Book

    def self.add_to_shelf(book)
      @bookshelf = [] if @bookshelf == nil
      @bookshelf << book
      @bookshelf
    end

    def self.bookshelf
      @bookshelf
    end

    def initialize(title, page_count)
      @title = title
      @page_count = page_count
      Book.add_to_shelf(self)
    end

    attr_reader :title

    def long?
      if @page_count > 100
        "yes"
      else
        "no"
      end
    end

  end
  
x = y = d1 = d2 = 2
factory = [
  "****************************************",
  "*                                      *",
  "*                                      *",
  "*                                      *",
  "*                                      *",
  "*                                      *",
  "*                                      *",
  "*                                      *",
  "*                                      *",
  "****************************************"
]
package = Array.new(d1){Array.new(d2){'A'}}
i= 0
j = 0
loop do
  break unless d1 > i
  loop do 
    break unless d2 > j
    factory[x+i][y+j] = package[i][j] 
    j+=1
  end
  i+=1
  j = 0
end