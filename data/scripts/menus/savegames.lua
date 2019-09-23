local savegames_menu = {}

local game_manager = require("scripts/game_manager")
local gui_designer = require("scripts/menus/lib/gui_designer")
local hearts_builder = require("scripts/hud/hearts")
local options_menu = require("scripts/menus/options")

local cursor_img = sol.surface.create("menus/fairy_cursor.png")
local fairy_img = sol.surface.create("menus/fairy_cursor.png")
local cursor_position
local fairy_cursor_position
local savegames_surfaces = {}
local games = {}
local icons_img = sol.surface.create("menus/icons.png")

local layout

-- show a background that depends on the hour of the day
local hours = tonumber(os.date("%H"))
local time_of_day
if hours >= 8 and hours < 18 then
    time_of_day = "daylight"
elseif hours >= 18 and hours < 20 then
    time_of_day = "sunset"
else
    time_of_day = "night"
end

local background_img = sol.surface.create("menus/title_" .. time_of_day
      .. "_background.png")

local function build_layout()

  layout = gui_designer:create(320, 240)
  layout:make_background()
  layout:make_big_wooden_frame(16, 8, 160, 32)
  layout:make_text(sol.language.get_string("savegames_menu.title"), 96, 16, "center")
  layout:make_wooden_frame(16, 48, 288, 32)
  layout:make_wooden_frame(16, 96, 288, 32)
  layout:make_wooden_frame(16, 144, 288, 32)
  layout:make_wooden_frame(16, 192, 136, 32) 
  layout:make_text(sol.language.get_string("savegames_menu.options"), 84, 200, "center")
  layout:make_text("1.", 44, 56)
  layout:make_text("2.", 44, 104)
  layout:make_text("3.", 44, 152)
end

-- Places the cursor on the savegame 1, 2 or 3.
local function set_cursor_position(index)

  cursor_position = index
  if index <= 4 then
    cursor_img:set_xy(26, 8 + index * 48)
  else
    cursor_img:set_xy(178, 194)
  end
end

local function get_savegame_file_name(index)
  return "save" .. index .. ".dat"
end

-- Draws the hearts of a game on a savegame surface.
local function draw_hearts(game, surface)

  local hearts = hearts_builder:new(game)
  hearts:on_started()
  hearts:on_draw(surface)
end

-- Reads the existing savegames and creates the savegames surfaces.
local function read_savegames()

  for i = 1, 3 do
    local file_name = get_savegame_file_name(i)
    local surface = sol.surface.create(240, 20)
    surface:set_xy(60, 8 + i * 48)
    savegames_surfaces[i] = surface
    
    if not sol.game.exists(file_name) then
      games[i] = nil
    else
      -- Existing file.
      	local game = game_manager:create(file_name)
      	games[i] = game
	  
	if game:get_value("key_item_901",true) then
    icons_img:draw_region(112,0,16,16,surface,216,0)
  end
      
      draw_hearts(game, surface)
    end
  end
end

function savegames_menu:on_started()

  build_layout()
  read_savegames()
  sol.audio.play_music("file_selection")
  set_cursor_position(1)
end

function savegames_menu:on_draw(dst_surface)

  background_img:draw(dst_surface)
  layout:draw(dst_surface)
  
  for i = 1, 3 do
    savegames_surfaces[i]:draw(dst_surface)
  end
  cursor_img:draw(dst_surface)
end

function savegames_menu:on_key_pressed(key)

  local handled = false

  if key == "down" then
    if cursor_position < 4 then
      set_cursor_position(cursor_position + 1)
    else
      set_cursor_position(1)
    end
    sol.audio.play_sound("cursor")
    handled = true
  elseif key == "up" then
    if cursor_position > 1 then
      set_cursor_position(cursor_position - 1)
    else
      set_cursor_position(4)
    end
    sol.audio.play_sound("cursor")
    handled = true
  elseif key == "space" then
    if cursor_position <= 3 then
      if games[cursor_position] == nil then
        -- Create a new savegame.
        local file_name = get_savegame_file_name(cursor_position)
        sol.main.start_game(game_manager:create(file_name))
        sol.menu.stop(savegames_menu)
      else
        -- Show actions for an existing savegame.
    		sol.timer.start(10,function()
            show_savegame_action_box(cursor_position)
    		end)
      end
	  elseif cursor_position == 4 then
      -- Options.
      sol.audio.play_sound("pause_closed")
      sol.menu.start(savegames_menu, options_menu)
      function options_menu:on_finished()
        build_layout()  -- Because the language may have changed.
        options_menu.on_finished = nil
      end
    end
	end
  handled = true

  return handled
end

function show_savegame_action_box(savegame_index)

  local action_box_menu = {}
  local fairy_cursor_position = 1
  local layout = gui_designer:create(112, 72)
  layout:make_wooden_frame()
  layout:make_text(sol.language.get_string("savegames_menu.load"), 56, 8, "center")
  layout:make_text(sol.language.get_string("savegames_menu.delete"), 56, 28, "center")
  layout:make_text(sol.language.get_string("savegames_menu.cancel"), 56, 48, "center")

  function action_box_menu:on_key_pressed(key)

    if key == "up" then
      sol.audio.play_sound("cursor")
      if fairy_cursor_position > 1 then
        fairy_cursor_position = fairy_cursor_position - 1
      else
        fairy_cursor_position = 3
      end

    elseif key == "down" then
      sol.audio.play_sound("cursor")
      if fairy_cursor_position < 3 then
        fairy_cursor_position = fairy_cursor_position + 1
      else
        fairy_cursor_position = 1
      end

    elseif key == "space" then

      if fairy_cursor_position == 1 then
        -- Load.
        local file_name = get_savegame_file_name(cursor_position)
        sol.main.start_game(game_manager:create(file_name))
        sol.menu.stop(savegames_menu)

      elseif fairy_cursor_position == 2 then
        -- Delete.
        sol.menu.stop(action_box_menu)
        show_confirm_delete_box(function()
          sol.audio.play_sound("boss_killed")
          sol.game.delete(get_savegame_file_name(savegame_index))
          read_savegames()
        end)

      else
        -- Cancel.
        sol.audio.play_sound("pause_closed")
        sol.menu.stop(action_box_menu)
      end

    end

    return true
  end

  function action_box_menu:on_draw(dst_surface)

    layout:draw(dst_surface, 104, 84)
    fairy_img:draw(dst_surface, 112, 72 + fairy_cursor_position * 20)
  end

  gui_designer:map_joypad_to_keyboard(action_box_menu)
  sol.audio.play_sound("pause_closed")
  sol.menu.start(savegames_menu, action_box_menu)
end

-- Creates a popup that ask confirmation to delete something.
function show_confirm_delete_box(action)

  local delete_box_menu = {}
  local fairy_cursor_position = 2
  local layout = gui_designer:create(112, 72)
  layout:make_wooden_frame()
  layout:make_text(sol.language.get_string("savegames_menu.delete_question"), 56, 8, "center")
  layout:make_text(sol.language.get_string("savegames_menu.yes"), 56, 28, "center")
  layout:make_text(sol.language.get_string("savegames_menu.no"), 56, 48, "center")

  function delete_box_menu:on_key_pressed(key)

    if key == "up" or key == "down" then
      sol.audio.play_sound("cursor")
      fairy_cursor_position = 3 - fairy_cursor_position

    elseif key == "space" then

      if fairy_cursor_position == 1 then
        -- Yes: do the action.
        action()
      else
        sol.audio.play_sound("pause_closed")
      end
      sol.menu.stop(delete_box_menu)

    end

    return true
  end

  function delete_box_menu:on_draw(dst_surface)

    layout:draw(dst_surface, 104, 84)
    fairy_img:draw(dst_surface, 112, 92 + fairy_cursor_position * 20)
  end

  gui_designer:map_joypad_to_keyboard(delete_box_menu)
  sol.audio.play_sound("pause_closed")
  sol.menu.start(savegames_menu, delete_box_menu)
end

gui_designer:map_joypad_to_keyboard(savegames_menu)

return savegames_menu