# ROBOT

module Sim
  
  MOVES = {
    "N"  => { :x =>  0, :y => -1, :rx =>  0, :ry =>  1 },
    "E"  => { :x =>  1, :y =>  0, :rx => -1, :ry =>  0 },
    "S"  => { :x =>  0, :y =>  1, :rx =>  0, :ry => -1 },
    "W"  => { :x => -1, :y =>  0, :rx =>  1, :ry =>  0 },
    "R"  => { :r => 0},
    "P" => { :cr => 0}
  }

  class Factory
  
    ORIENTATION = { 
      "N" => "^",
      "E" => ">",
      "S" => "v",
      "W" => "<"
    }
    
    REVERSE = { 
      "N" => "S",
      "E" => "W",
      "S" => "N",
      "W" => "E"
    }
    
    def initialize(x, y)
      @x = x
      @y = y
    
      @inventory = Inventory.new
      
      # creates blank floor with walls defined as '*' character
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
      # create new package
      pkg = Package.new(x, y, d1, d2, type)
  
      # check if insertion space is already occupied, insert if empty, 
      # return err_msg_1 if occupied
      if occupants(pkg, nil).nil? 
        fill_floor(x, y, d1, d2, pkg)
        @inventory.add(pkg)
      else
        err_msg_1(x, y, occupants(pkg, nil))
      end
      self
    end
    
    def occupants(pkg, move)  
      existing_occ = []

      # occupants performs checking for package placement and for package 
      # movement, 'move' is set to nil when placement is required or to the 
      # movement direction when package movement is required. This determines
      # the range of places in the floorplan to check for occupants.
      if move.nil? 
        (pkg.range[:y]).each do |i|
          (pkg.range[:x]).each do |j|
            if @floorplan[i][j] != ' '
              existing_occ << @floorplan[i][j]
            end
          end
        end
      else
        (pkg.next_range(move)[:y]).each do |i|
           (pkg.next_range(move)[:x]).each do |j|
             unless [' ', '*', pkg, @location[2] ].include?(@floorplan[i][j])
               existing_occ << @floorplan[i][j]
             end
           end
        end
      end
      if existing_occ.empty?
        nil
      else
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
      @location = [x, y, ORIENTATION[dir], dir]
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
      puts "Enter movement command (N, E, S, W or R (reverse)):"
      dir = STDIN.readline.chomp.upcase
      unless MOVES.keys.include?(dir)
        puts "Invalid input, enter movement command (N, E, S, W)!"
        return nil
      end
     
      if ORIENTATION.keys.include?(dir) 
        forward(dir)
      elsif dir == 'R'
        backward
      elsif dir == 'P'
        pull
      end
      self
    end
        
    def reloc_pkg(dir, pkg)

      new_loc = [pkg.loc[0] + MOVES[dir][:x], pkg.loc[1] + MOVES[dir][:y]]
    
      #clear old package from floorplan
      fill_floor(pkg.loc[0], pkg.loc[1], pkg.dims[0], pkg.dims[1],' ')
    
      #insert relocated package into floorplan
      place_pkg(new_loc[0], new_loc[1], pkg.dims[0], pkg.dims[1], pkg.to_s)

      # #clear old package from floorplan
      # fill_floor(pkg.loc[0], pkg.loc[1], pkg.dims[0], pkg.dims[1],' ')
      #     
      # #insert relocated package into floorplan
      # mod_pkg = pkg.move_pkg(dir)
      # puts "#{mod_pkg}"
      # fill_floor(mod_pkg.loc[0], mod_pkg.loc[0], mod_pkg.dims[0], 
      #   mod_pkg.dims[1], mod_pkg.to_s)      
    end

    private
    
    def forward(dir)

      new_x = @location[0] + MOVES[dir][:x]
      new_y = @location[1] + MOVES[dir][:y]
      next_loc = @floorplan[new_y][new_x]

      if next_loc == ' '
        reassign(new_x, new_y, dir)
      elsif next_loc == '*'
        reassign(@location[0],@location[1],dir)
        print "Cannot move, try alternative direction "
        puts  "(current direction => #{ORIENTATION[dir]})." 
      else
        if occupants(next_loc, dir).nil? 
          reloc_pkg(dir, next_loc)
          reassign(new_x, new_y, dir)  
        else
          reassign(@location[0],@location[1],dir)
          err_msg_2(new_x, new_y, occupants(next_loc, dir))
        end
      end
    end
    
    def backward

      new_x = @location[0] + MOVES[@location[3]][:rx]
      new_y = @location[1] + MOVES[@location[3]][:ry]
      dir = @location[3]
      next_loc = @floorplan[new_y][new_x]

      if next_loc == ' '
        reassign(new_x, new_y, dir)
      elsif next_loc == '*'
        print "Cannot move, try alternative direction "
        puts  "(current direction => Reverse #{ORIENTATION[dir]})." 
      else
        if occupants(next_loc, REVERSE[dir]).nil? 
          reloc_pkg(REVERSE[dir], next_loc)
          reassign(new_x, new_y, dir)  
        else
          err_msg_2(new_x, new_y, occupants(next_loc, REVERSE[dir]))
        end
      end
    end
    
    def pull

      new_x = @location[0] + MOVES[@location[3]][:rx]
      new_y = @location[1] + MOVES[@location[3]][:ry]
      prev_x = @location[0] + MOVES[@location[3]][:x]
      prev_y = @location[1] + MOVES[@location[3]][:y]
      dir = @location[3]
      next_loc = @floorplan[new_y][new_x]
      prev_loc = @floorplan[prev_y][prev_x]
      
      if prev_loc != ' ' && prev_loc != '*'     
        if next_loc == ' '
          if occupants(prev_loc, REVERSE[dir]).nil?
            reassign(new_x, new_y, dir)
            reloc_pkg(REVERSE[dir], prev_loc)
          else
            err_msg_2(prev_x, prev_y, occupants(prev_loc, REVERSE[dir]))
          end
        elsif next_loc == '*'
          print "Cannot move, try alternative direction "
          puts  "(current direction => Reverse #{ORIENTATION[dir]})."   
        else
          if occupants(next_loc, REVERSE[dir]).nil?         
            if occupants(prev_loc, REVERSE[dir]).nil?
              reloc_pkg(REVERSE[dir], next_loc)
              reassign(new_x, new_y, dir)
              reloc_pkg(REVERSE[dir], prev_loc)
            else
              err_msg_2(prev_x, prev_y, occupants(prev_loc, REVERSE[dir]))
            end
          else
            err_msg_2(new_x, new_y, occupants(next_loc, REVERSE[dir]))
          end          
        end
      else
        err_msg_3(prev_loc)
      end
    end
    
    def fill_floor(x, y, d1, d2, item)
      (y..(y+d2-1)).each do |i|
        (x..(x+d1-1)).each do |j|
          @floorplan[i][j] = item
        end
      end
    end
    
    def reassign(new_x, new_y, dir)
      @floorplan[@location[1]][@location[0]] = ' '
      @floorplan[new_y][new_x] = ORIENTATION[dir]
      @location = [new_x, new_y, ORIENTATION[dir], dir]
    end
    
    def err_msg_1(x, y, check)
      print "Cannot place package at [#{x}, #{y}], "
      if !check.include?('*') 
        print "clash with '#{check[0].to_s}'"
        print " package at #{check[0].loc}" 
        puts " of dimensions #{check[0].dims}"
      else 
        puts "clash with wall ('*')"
      end
    end  
    
    def err_msg_2(new_x, new_y, check)
      print "Cannot move to [#{new_x}, #{new_y}], "
      if !check.include?('*') 
        print "clash with '#{check[0].to_s}'"
        print " package at #{check[0].loc}" 
        puts " of dimensions #{check[0].dims}"
      else 
        puts "clash with wall ('*')"
      end
    end
    
    def err_msg_3(check)
      if check == '*' 
        puts "Cannot pull wall. Try alternative command."
      
      elsif check == ' ' 
        puts "No package to pull. Try alternative command."
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

    # def move_pkg(dir)
    #   @x = @x + MOVES[dir][:x]
    #   @y = @y + MOVES[dir][:y]
    # end

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
