-- Defines the dungeon information of a game.

-- Usage:
-- local dungeon_manager = require("scripts/dungeons")
-- dungeon_manager:create(game)

local dungeon_manager = {}

function dungeon_manager:create(game)

  -- Define the existing dungeons and their floors for the minimap menu.
  local dungeons_info = {
    [901] = {
      lowest_floor = -1,
      highest_floor = 0,
      maps = { "new_maps/challenge_1_rdc", "new_maps/challenge_1_ss1" },
      boss = {
        floor = 0,
        x = 1120 + 3520,
        y = 360,
        savegame_variable = "boss_901",
      },
      key_item = {
        floor = 0,
        x = 1120 + 3520 + 40,
        y = 120 + 40,
        savegame_variable = "key_item_901",
      }
    },
    [101] = {
      lowest_floor = 0,
      highest_floor = 0,
      maps = { "original_maps/zelda_1_dungeon_1" },
      boss = {
        floor = 0,
        x = 960 + 800 + 3520,
        y = 720 + 360,
        savegame_variable = "boss_1",
      },
      key_item = {
        floor = 0,
        x = 960 + 800 + 3840 + 40,
        y = 720 + 360 + 40,
        savegame_variable = "triforce_1",
      }
    },
    [303] = {
      lowest_floor = -1,
      highest_floor = 0,
      maps = { "original_maps/skeleton_wood_dungeon_RDC","original_maps/skeleton_wood_dungeon_SS1" },
      boss = {
        floor = -1,
        x = 160 + 3520,
        y = 120,
        savegame_variable = "boss_303",
      },
      key_item = {
        floor = -1,
        x = 480 + 3520 + 40,
        y = 120 + 40,
        savegame_variable = "key_item_303",
      }
    },
  }

  -- Returns the index of the current dungeon if any, or nil.
  function game:get_dungeon_index()

    local world = game:get_map():get_world()
    if world == nil then
      return nil
    end
    local index = tonumber(world:match("^dungeon_([0-9]+)$"))
    return index
  end

  -- Returns the current dungeon if any, or nil.
  function game:get_dungeon()

    local index = game:get_dungeon_index()
    return dungeons_info[index]
  end

  function game:is_dungeon_finished(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_finished")
  end

  function game:set_dungeon_finished(dungeon_index, finished)
    if finished == nil then
      finished = true
    end
    dungeon_index = dungeon_index or game:get_dungeon_index()
    game:set_value("dungeon_" .. dungeon_index .. "_finished", finished)
  end

  function game:has_all_crystals()

    for i = 1, 7 do
      if not game:is_dungeon_finished(i) then
        return false
      end
    end
    return true
  end

  function game:get_num_crystals()

    local num_finished = 0
    for i = 1, 7 do
      if game:is_dungeon_finished(i) then
        num_finished = num_finished + 1
      end
    end
    return num_finished
  end

  function game:has_dungeon_map(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_map")
  end

  function game:has_dungeon_compass(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_compass")
  end

  function game:has_dungeon_boss_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_boss_key")
  end

  function game:has_dungeon_green_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_green_key")
  end
  function game:has_dungeon_red_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_red_key")
  end
  function game:has_dungeon_yellow_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_yellow_key")
  end
  function game:has_dungeon_blue_key(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return game:get_value("dungeon_" .. dungeon_index .. "_blue_key")
  end

  function game:get_dungeon_name(dungeon_index)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    return sol.language.get_string("dungeon_" .. dungeon_index .. ".name")
  end

  -- Returns the name of the boolean variable that stores the exploration
  -- of a dungeon room, or nil.
  function game:get_explored_dungeon_room_variable(dungeon_index, floor, room)

    dungeon_index = dungeon_index or game:get_dungeon_index()
    room = room or 1

    if floor == nil then
      if game:get_map() ~= nil then
        floor = game:get_map():get_floor()
      else
        floor = 0
      end
    end

    local room_name
    if floor >= 0 then
      room_name = tostring(floor + 1) .. "f_" .. room
    else
      room_name = math.abs(floor) .. "b_" .. room
    end

    return "dungeon_" .. dungeon_index .. "_explored_" .. room_name
  end

  -- Returns whether a dungeon room has been explored.
  function game:has_explored_dungeon_room(dungeon_index, floor, room)

    return self:get_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room)
    )
  end

  -- Changes the exploration state of a dungeon room.
  function game:set_explored_dungeon_room(dungeon_index, floor, room, explored)

    if explored == nil then
      explored = true
    end

    self:set_value(
      self:get_explored_dungeon_room_variable(dungeon_index, floor, room),
      explored
    )
  end

end

return dungeon_manager

