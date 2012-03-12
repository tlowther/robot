# ROBOT

module Sim
  
  MOVES = {
    "N" => { :x =>  0, :y => -1 },
    "E" => { :x =>  1, :y =>  0 },
    "S" => { :x =>  0, :y =>  1 },
    "W" => { :x => -1, :y =>  0 }
  }

  class Factory
  
    ORIENTATION = { 
      "N" => "^",
      "E" => ">",
      "S" => "v",
      "W" => "<"
    }

    def initialize(x, y)
      @x = x
      @y = y
    
      @inventory = Inventory.new
    
      bottom_row = top_row = Array.new(@x) { "*" }
      internal_row = Array.new(@x) { " " }
      internal_row[0]  = "*"
      internal_row[-1] = "*"
    
      @floorplan = Array.new(@y) { Array.new(@x){' '} }
      @floorplan[0] =  top_row #inserts 'walls' top row of floor
      @floorplan[-1] = bottom_row #inserts 'walls' bottom row of floor

      (1..(@y-2)).each do |i| #inserts remaining internal rows
        @floorplan[i] = internal_row.dup
      end
    end
  
    def place_pkg(x, y, d1, d2, type)
      pkg = Package.new(x, y, d1, d2, type)
  
      if occupants(pkg, nil).nil? 
        fill_floor(x, y, d1, d2, pkg)
        @inventory.add(pkg)
      else
        err_msg_1(x, y, pkg)
      end
      self
    end
    
    def err_msg_1(x, y, pkg)
      print "Cannot place package at [#{x}, #{y}], "
      if !occupants(pkg)[0].include?('*') 
        print "clash with '#{occupants(pkg)[0].to_s}'"
        print " package at #{occupants(pkg)[0].loc}" 
        puts " of dimensions #{occupants(pkg)[0].dims}"
      else 
        puts "clash with wall ('*')"
      end
    end  
    
    def occupants(pkg, move)  
      existing_occ = []
      if move.nil?
        range_y = pkg.range[:y]
        range_x = pkg.range[:x]
      else
        range_y = pkg.next_range(move)[:y]
        range_x = pkg.next_range(move)[:x]
      end
      
      (range_y).each do |i|
         (range_x).each do |j|
          if ((@floorplan[i][j] != ' ') && (@floorplan[i][j] != pkg)) 
            existing_occ << @floorplan[i][j]
          end
        end
      end
      if existing_occ.empty?
        nil
      else
        existing_occ.each { |a| puts a}
        existing_occ
      end
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
    end
  
    def move_robot
      if @location.nil?
        return puts "No Robot present, use place_robot command to begin."
      end
      puts "Enter movement command (N, E, S, W):"
      dir = STDIN.readline.chomp.upcase
      unless MOVES.keys.include?(dir)
        puts "Invalid input, enter movement command (N, E, S, W)!"
        return nil
      end

      new_x = @location[0] + MOVES[dir][:x]
      new_y = @location[1] + MOVES[dir][:y]

      if @floorplan[new_y][new_x] == ' '
        @floorplan[new_y][new_x] = ORIENTATION[dir]
        @floorplan[@location[1]][@location[0]] = ' '
        @location = [new_x, new_y, ORIENTATION[dir]]
    
      elsif @floorplan[new_y][new_x] == '*'
        puts "Cannot move, try alternative direction (this_move => #{MOVES[dir]})." 
    
      else
        check = occupants(@floorplan[new_y][new_x], dir)
        
        if check.nil? 
          reloc_pkg(dir, @floorplan[new_y][new_x])
          @floorplan[new_y][new_x] = ORIENTATION[dir]
          @floorplan[@location[1]][@location[0]] = ' '
          @location = [new_x, new_y, ORIENTATION[dir]]
        else
          print "Cannot move to [#{new_x}, #{new_y}], "
          if !check.include?('*') 
            print "clash with '#{check[0].to_s}'"
            print " package at #{check[0].loc}" 
            puts " of dimensions #{check[0].dims}"
          else 
            puts "clash with wall ('*')"
          end
        end
      end
      self
    end
  
    def reloc_pkg(dir, pkg)    
      new_loc = [pkg.loc[0] + MOVES[dir][:x], pkg.loc[1] + MOVES[dir][:y]]
    
      #clear old package from floorplan
      fill_floor(pkg.loc[0], pkg.loc[1], pkg.dims[0], pkg.dims[1],' ')
    
      #insert relocated package into floorplan
      place_pkg(new_loc[0], new_loc[1], pkg.dims[0], pkg.dims[1], pkg.to_s)
      new_pkg = @floorplan[new_loc[1]][new_loc[0]]

      #replace old package information in inventory with new information
      @inventory.modify_inventory(pkg, new_pkg)        
    end

    private
    
    def fill_floor(x, y, d1, d2, item)
      (y..(y+d2-1)).each do |i|
        (x..(x+d1-1)).each do |j|
          @floorplan[i][j] = item
        end
      end
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

    def move_pkg?(dir, pkg_list)
      !pkg_list.intersect?(self, next_range(dir)[:x], next_range(dir)[:y])
    end

    def range
      { :x => @x..(@x+@d1-1), :y => @y..(@y+@d2-1) }
    end

    def next_range(dir)
      { 
        :x => (@x+MOVES[dir][:x])..(@x+MOVES[dir][:x]+@d1-1),
        :y => (@y+MOVES[dir][:y])..(@y+MOVES[dir][:y]+@d2-1) 
      }
    end
    
  end

  class Inventory

   	def initialize
      @pkg_list = []
    end

    def add(pkg)    
      @pkg_list << pkg
    end

    def show
       @pkg_list.each { |a| puts "[#{a.to_s}, #{a.dims}, #{a.loc}]" }
    end
  
    def modify_inventory(pkg, new_pkg)
      @pkg_list.each { |a| a = new_pkg if (a == pkg) }
      self 
    end

    def intersect?(pkg, range_x, range_y)
      @pkg_list.each do |a| 
        if a != pkg 
          return true if range_x.include?(a.range[:x])
          return true if range_y.include?(a.range[:y]) 
        end
      end
      false
    end
  
  end
  
end
