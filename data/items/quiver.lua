local item = ...

local function update_quiver()
  local variant = item:get_variant()
  local bow = item:get_game():get_item("bow")
  local arrow = item:get_game():get_item("arrow")
  if variant == 0 then
    -- No quiver.
    bow:set_max_amount(0)
    arrow:set_obtainable(false)
  else
    -- Obtaining a quiver changes the max amount of the bow counter.
    local max_amounts = {30, 60, 99}
    local max_amount = max_amounts[variant]
    bow:set_max_amount(max_amount)
    arrow:set_obtainable(true)
  end
end

function item:on_created()

  -- Store the possession state of this item in a savegame variable.
  self:set_savegame_variable("possession_quiver")
end

function item:on_started()
  update_quiver()
end

function item:on_variant_changed(variant)
  update_quiver()
end

function item:on_obtaining(variant, savegame_variable)

  if variant > 0 then
    local bow = item:get_game():get_item("bow")
    bow:set_amount(bow:get_max_amount())
  end
end

