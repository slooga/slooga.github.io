#!/usr/bin/env ruby
$props = ['some trees sway and', 'a squrrle jumps over your head', '']
$zhealth = 2
$selected_item = nil
$inventory = []
$map = {
    :forest => {
        :desc => "you're are lost in a forest, the trees sway and bushes blow in the wind",
        :exits => {
            'east' => :forest_east,
            'west' => :forest_west,
            'north' => :forest_north,
         }
    },
    :caveeast => {
      :desc =>"it gets dark spider creep across your face!",
      :items => ['staff'],
      :hidden_items => ['hammer'],
      :enemies => ['zap'],
      :exits => {
       'west' => :cave
      }
    },
    :cave => {
      :desc =>"the gemstone swirls around & flys into your hands (woosh)",
      :items => ['gemstone'],
      :hidden_items => ['hammer'],
      :enemies => ['zapper'],
      :exits => {
       'west' => :forest_northnorthnorthnorth,
       'east' => :caveeast,
      }
    },
    :forest_northnorthnorthnorth => {
      :desc => "a green gemstone glows in a cave to enter cave go east",
      :exits => {
        'south' => :forest_northnorthnorth,
        'east' => :cave,
      }
    },   
    :forest_northnorthnorth => {
      :desc => "you run right past the horse.  There is a green and brown tree swaying with a book in it.",
      :items => ['book'],
      :exits => {
        'south' => :forest_northnorth,
        'north' => :forest_northnorthnorthnorth,
      }
    },   
    :forest_northnorth => {
      :desc => "you run right into the horse slam! you're hurt",
      :exits => {
        'south' => :forest_north,
        'north' => :forest_northnorthnorth,
      }
    },
    :forest_north => {
        :desc => 'you see a horse in the distance with yellow eyes green trees sway',
        :exits =>   {
            'east' =>  :forest_east,
            'west' =>  :forest_west,
            'north' => :forest_northnorth,
          }
    },
    :forest_east => {
        :desc => ['the forest grows dark and shadows show in the',
                  'dim light'],
        :exits => {
            'west' => :forest,
        }
    },
    :forest_west => {
        :desc => [
             "you shiver a tornado is heading right torwards you from the west",
             "run!",
             "a person picks you up and puts you in a bag",
             "you struggle in the bag",
             "you wake on the forest floor",
        ],
        :exits => {
            'east' => :forest,
            'west' => :tornado,
        }
    },
    :tornado => {
        :desc => 'you are dead, you ran into the tornado',
        :exits => {}
    }
}

$objects = {
  'book' => {
    'text' => [
      'this is line 1',
      'this is line 2'
    ]
  }
}

$mapped_commands = {
  '^' => 'north',
  'v' => 'soutu',
  '>' => 'east',
  '<' => 'west',
  'n' => 'north',
  's' => 'south',
  'e' => 'east',
  'w' => 'west',
  'm' => 'map',
  'o' => 'options'
}

DIRECTIONS = ['north', 'south', 'east', 'west'].freeze
OPTIONAL_STUFF_IN_ROOMS = [
  :items,
  :hidden_items,
  :enemies,
]

def initialize_map(map)
  map.keys.each do |room_key|
    room = map[room_key]
    OPTIONAL_STUFF_IN_ROOMS.each do |key|
      if !room[key]
        room[key] = []
      end
    end
  end
end


def get_command
  words = gets.strip.downcase.split(' ')
  cmd = words.first
  args = words[1..-1]
  if $mapped_commands[cmd]
    cmd = $mapped_commands[cmd]
  end
  return cmd, args
end

def display_help
  puts "north = ^"
  puts "south = v"
  puts "east  = >"
  puts "west  = <"
  puts "look shows you the area you're in again"
  puts "quit exits the game"
  puts "help displays this list of commands"
  puts "m = map_display" 
  puts "db = display backpack"
  puts "o = options" 
end

def look_at_room(room_name)
  room = $map[room_name]
  puts room_name
  if room[:desc].is_a?(String)
    desc = room[:desc]
  else
    desc = room[:desc].join("\n")
  end
  puts desc
  $location = room_name
  exits = room[:exits]
  if exits.size == 0
    puts "there are no exits, you're stuck!"
  else
    puts "possible exits: " + exits.keys.join(', ')
  end
  items = get_items_in_room(room)
  if items.size > 0
    puts "there are some items in the room: " + items.join(", ")
  end
  if room[:enemies].size > 0
    puts "there are some enemies here! " + room[:enemies].join(', ')
  end
end

def get_items_in_room(room)
  return room[:items] || []
end

def get_hidden_items_in_room(room)
  return room[:hidden_items] || []
end

def current_room
  return $map[$location]
end

def item_in_room?(item)
  return get_items_in_room(current_room).include?(item)
end

def handle_command(cmd, args)
  room = $map[$location]
  arg = args.to_a.first
  if cmd == 'quit'
    puts 'changes will not be saved are you sure you want to quit yes or no'
    if gets.strip == 'yes'
      exit 0
    end  
  elsif cmd == 'look'
    look_at_room($location)
  elsif cmd == 'help'
    display_help
  elsif room[:exits].include?(cmd)
    look_at_room(room[:exits][cmd])
  elsif DIRECTIONS.include?(cmd)
    puts "I can't go that way."
  elsif cmd == 'map'
    puts $map
  elsif ['db', 'backpack', 'inventory', 'b'].include?(cmd)
    puts 'backpack: ' + $backpack.join(', ')
  elsif cmd == 'take'
    if item_in_room?(arg)
      $backpack << arg
      room[:items].delete(arg)
      puts "you take the: " + arg  
    else  
      puts "there is no '#{args.join(' ')}' here."
    end
  elsif cmd == 'read'
    if $backpack.include?(arg)
      puts $objects[arg]['text'].join("\n")
    else  
      puts "you're not holding a #{arg}"
    end  
  elsif cmd == 'search'
    hidden_items = get_hidden_items_in_room(current_room)
    if hidden_items.size > 0
      puts "you found: " + hidden_items.join(", ") 
      current_room[:items] += hidden_items
      current_room[:hidden_items] = []
    else
      puts "you didn't find anything."
    end

  elsif cmd == 'select'
    puts 'backpack contains' + $backpack.to_s 
    if $backpack.include?(arg)
      $selected = arg
      puts "you have selected " + arg
    end
  elsif  cmd == 'attack'
    if current_room[:enemies].to_a.include?(arg)
      $attacking = arg
      puts "you attacked " + arg
   if arg == 'zapper'
    $zhealth = $zhealth - 1

    elsif arg.to_s != ''
      puts "there is no #{arg} here!"
    else
      puts "there are no enemies here!"
    end
  elsif  cmd == 'options'
    puts "commands can do back, teach"
    cmd, args = get_command
    if cmd == 'back'
      puts 'back to game'
    end
  elsif $zhealth == 0
    current_room[:enemies].delete('zapper')    
    end  
    $mapped_commands[args[0]] = args[2]
  elsif cmd == 'drop'
    if $backpack.include?(arg)
      current_room[:items] << arg
      $backpack.delete(arg)
      puts "you drop the: " + arg  
    else  
      puts "you do not have '#{args.join(' ')}' in your backpack."     
    end
  elsif cmd == 'r'
    "you're are lost in a forest, the trees sway and bushes blow in the wind"        
  else
    return false
  end
  return true
end
def cmd_loop
    while true do
      cmd, args = get_command
      next if !cmd
      if !handle_command(cmd, args)
          puts "I don't know what : " + cmd + " means"
      end
    end
end
def loot_randomize()
  $zloot.shuffle.first
end
$backpack = ["knife", "torch"]
initialize_map($map)
puts 'welcome to mark text adventure!'
display_help
look_at_room(:forest)
cmd_loop
def tree_randomize()
  $props.shuffle.first
end  
def world_genarator
  puts tree_randomize()
end  