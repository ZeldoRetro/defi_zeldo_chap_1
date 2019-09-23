local inventory_manager = {}

local gui_designer = require("scripts/menus/lib/gui_designer")

local item_names = {
  -- Placer les objets d'inventaire de la quête ici (ils seront dans l'ordre de gauche a droite et de haut en bas.)
  "bombs_counter",
  "lamp",
  "boomerang",
}
local items_num_columns = 3
local items_num_rows = math.ceil(#item_names / items_num_columns)
local piece_of_heart_icon_img = sol.surface.create("hud/piece_of_heart_icon.png")
local icons_img = sol.surface.create("menus/stats_icons.png")
local items_img = sol.surface.create("entities/items.png")
local movement_speed = 800
local movement_distance = 1

--FENETRE DES OBJETS

local function create_item_widget(game)
  local widget = gui_designer:create(112, 58)
  widget:set_xy(16 - movement_distance, 56)
  widget:make_green_frame()
  local items_surface = widget:get_surface()


  for i, item_name in ipairs(item_names) do
    local variant = game:get_item(item_name):get_variant()
    if variant > 0 then
      local column = (i - 1) % items_num_columns + 1
      local row = math.floor((i - 1) / items_num_columns + 1)
      -- Draw the sprite statically. This is okay as long as
      -- item sprites are not animated.
      -- If they become animated one day, they will have to be
      -- drawn at each frame instead (in on_draw()).
      local item_sprite = sol.sprite.create("entities/items")
      item_sprite:set_animation(item_name)
      item_sprite:set_direction(variant - 1)
      item_sprite:set_xy(8 + column * 32 - 16, 17 + row * 32 - 16)
      item_sprite:draw(items_surface)
    end
  end
  return widget
end

local function create_menu_title_widget(game)
  local widget = gui_designer:create(72, 28)
  widget:set_xy(124, 8)
  widget:make_wooden_frame()
  widget:make_text(sol.language.get_string("menu_title.inventory"), 6, 6, "left")
  return widget
end

local function create_stats_widget(game)
  local widget = gui_designer:create(112, 52)

  widget:set_xy(16, 128)
  widget:make_red_frame()

  --équipement principal: bottes, palmes, gants, ...
  local x_shoes = 16
  local y_shoes = 18
  local x_glove = 48
  local x_flippers = 80
  if game:get_item("tunic"):get_variant() == 2 then
    widget:make_image_region(items_img, 32, 32, 16, 16, x_shoes, y_shoes)
  end
  if game:get_item("sword"):get_variant() == 2 then
    widget:make_image_region(items_img, 48, 32, 16, 16, x_glove, y_shoes)
  end
  if game:get_item("bomb_bag"):get_variant() == 2 then
    widget:make_image_region(items_img, 64, 32, 16, 16, x_flippers, y_shoes)
  end  
  return widget
end

local function create_equipment_widget(game)
  local widget = gui_designer:create(96, 58)

  widget:set_xy(208, 56)
  widget:make_yellow_frame(0,0,96,58)
  --timer
  widget:make_image_region(icons_img, 48, 32, 12, 12, 6, 6)

  --épée, bouclier, tunique
  local x_tunic = 12
  local x_tunic_level = 22
  local y_sword = 20
  local y_sword_level = 28
  local x_sword = 38
  local x_sword_level = 48
  local x_shield = 64
  local x_shield_level = 74
  if game:get_ability("sword") == 1 then
    widget:make_image_region(items_img, 528, 32, 16, 16, x_sword, y_sword)
    widget:make_counter(1, x_sword_level, y_sword_level)
  elseif game:get_ability("sword") == 2 then
    widget:make_image_region(items_img, 528, 32, 16, 16, x_sword, y_sword)
    widget:make_counter(2, x_sword_level, y_sword_level)
  elseif game:get_ability("sword") == 3 then
    widget:make_image_region(items_img, 528, 32, 16, 16, x_sword, y_sword)
    widget:make_counter(3, x_sword_level, y_sword_level)
  elseif game:get_ability("sword") == 4 then
    widget:make_image_region(items_img, 528, 48, 16, 16, x_sword, y_sword)
    widget:make_green_counter(4, x_sword_level, y_sword_level)
  end
  if game:get_ability("shield") == 1 then
    widget:make_image_region(items_img, 544, 0, 16, 16, x_shield, y_sword)
    widget:make_counter(1, x_shield_level, y_sword_level)
  elseif game:get_ability("shield") == 2 then
    widget:make_image_region(items_img, 544, 16, 16, 16, x_shield, y_sword)
    widget:make_counter(2, x_shield_level, y_sword_level)
  elseif game:get_ability("shield") == 3 then
    widget:make_image_region(items_img, 544, 32, 16, 16, x_shield, y_sword)
    widget:make_green_counter(3, x_shield_level, y_sword_level)
  end
  if game:get_ability("tunic") == 1 then
    widget:make_image_region(items_img, 512, 0, 16, 16, x_tunic, y_sword)
    widget:make_counter(1, x_tunic_level, y_sword_level)
  elseif game:get_ability("tunic") == 2 then
    widget:make_image_region(items_img, 512, 0, 16, 16, x_tunic, y_sword)
    widget:make_counter(2, x_tunic_level, y_sword_level)
  elseif game:get_ability("tunic") == 3 then
    widget:make_image_region(items_img, 512, 32, 16, 16, x_tunic, y_sword)
    widget:make_green_counter(3, x_tunic_level, y_sword_level)
  end

  return widget
end

local function create_force_gem_widget(game)
  local widget = gui_designer:create(48, 52)
  widget:set_xy(256, 128)
  widget:make_blue_frame()
	if game:get_value("key_item_901",true) then
      local sprite = sol.sprite.create("entities/items")
      sprite:set_animation("trophy")
      widget:make_sprite(sprite, 280, 160)
  end  
  return widget
end

function inventory_manager:new(game)

  local inventory = {}

  local state = "opening"  -- "opening", "ready" or "closing".

  local item_widget = create_item_widget(game)
  local menu_title_widget = create_menu_title_widget(game)
  local stats_widget = create_stats_widget(game)
  local equipment_widget = create_equipment_widget(game)
  local force_gem_widget = create_force_gem_widget(game)
  
  local item_cursor_moving_sprite = sol.sprite.create("menus/item_cursor")
  item_cursor_moving_sprite:set_animation("solid_fixed")

  -- Determine the place of the item currently assigned if any.
  local item_assigned_row, item_assigned_column, item_assigned_index
  local item_assigned = game:get_item_assigned(1)
  if item_assigned ~= nil then
    local item_name_assigned = item_assigned:get_name()
    for i, item_name in ipairs(item_names) do

      if item_name == item_name_assigned then
        item_assigned_column = (i - 1) % items_num_columns
        item_assigned_row = math.floor((i - 1) / items_num_columns)
        item_assigned_index = i - 1
      end
    end
  end

  local time_played_text = sol.text_surface.create{
    font = "white_digits",
    horizontal_alignment = "left",
    vertical_alignment = "top",
  }

  -- Draws the time played on the status widget.
  local function draw_time_played(dst_surface)
    local time_string = game:get_time_played_string()
    time_played_text:set_text(time_string)
    time_played_text:draw(dst_surface, 228, 48+16)
  end

  -- Rapidly moves the inventory widgets towards or away from the screen.
  local function move_widgets(callback)

    local angle_added = 0
    if item_widget:get_xy() > 0 then
      -- Opposite direction when closing.
      angle_added = math.pi * 2
    end

    local movement = sol.movement.create("straight")
    movement:set_speed(movement_speed)
    movement:set_max_distance(movement_distance)
    movement:set_angle(0 + angle_added)
    item_widget:start_movement(movement, callback)

  end

  local cursor_index = game:get_value("pause_inventory_last_item_index") or 0
  local cursor_row = math.floor(cursor_index / items_num_columns)
  local cursor_column = cursor_index % items_num_columns

  -- Draws cursors on the selected and on the assigned items.
  local function draw_item_cursors(dst_surface)

    -- Selected item.
    local widget_x, widget_y = item_widget:get_xy()
    item_cursor_moving_sprite:draw(
        dst_surface,
        widget_x + 24 + 32 * cursor_column,
        widget_y + 28 + 32 * cursor_row
    )
  end

  -- Changes the position of the item cursor.
  local function set_cursor_position(row, column)
    cursor_row = row
    cursor_column = column
    cursor_index = cursor_row * items_num_columns + cursor_column
    if cursor_index == item_assigned_index then
      item_cursor_moving_sprite:set_animation("solid_fixed")
    end
  end

  function inventory:on_draw(dst_surface)

    item_widget:draw(dst_surface)
    menu_title_widget:draw(dst_surface)
    stats_widget: draw(dst_surface)
    equipment_widget: draw(dst_surface)
    force_gem_widget:draw(dst_surface)

    draw_time_played(dst_surface)
    -- Show the item cursors.
    draw_item_cursors(dst_surface)
  end

  function inventory:on_command_pressed(command)

    if state ~= "ready" then
      return true
    end

    local handled = false

    if command == "pause" then
      -- Close the pause menu.
      state = "closing"
      sol.audio.play_sound("pause_closed")
      move_widgets(function() game:set_paused(false) end)
      handled = true

    elseif command == "item_1" then
      -- Assign an item.
      local item = game:get_item(item_names[cursor_index + 1])
      if cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("ok")
        game:set_item_assigned(1, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "item_2" then
      -- Assign an item.
      local item = game:get_item(item_names[cursor_index + 1])
      if cursor_index ~= item_assigned_index
          and item:has_variant()
          and item:is_assignable() then
        sol.audio.play_sound("ok")
        game:set_item_assigned(2, item)
        item_assigned_row, item_assigned_column = cursor_row, cursor_column
        item_assigned_index = cursor_row * items_num_rows + cursor_column
        item_cursor_moving_sprite:set_animation("solid_fixed")
        item_cursor_moving_sprite:set_frame(0)
      end
      handled = true

    elseif command == "right" then
      if cursor_column < items_num_columns - 1 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column + 1)
        handled = true
      end

    elseif command == "up" then
      sol.audio.play_sound("cursor")
      if cursor_row > 0 then
        set_cursor_position(cursor_row - 1, cursor_column)
      else
        set_cursor_position(items_num_rows - 1, cursor_column)
      end
      handled = true

    elseif command == "left" then
      if cursor_column > 0 then
        sol.audio.play_sound("cursor")
        set_cursor_position(cursor_row, cursor_column - 1)
        handled = true
      end

    elseif command == "down" then
      sol.audio.play_sound("cursor")
      if cursor_row < items_num_rows - 1 then
        set_cursor_position(cursor_row + 1, cursor_column)
      else
        set_cursor_position(0, cursor_column)
      end
      handled = true
    end

    return handled
  end

  function inventory:on_finished()
    -- Store the cursor position.
    game:set_value("pause_inventory_last_item_index", cursor_index)
  end

  set_cursor_position(cursor_row, cursor_column)
  move_widgets(function() state = "ready" end)

  return inventory
end

return inventory_manager

