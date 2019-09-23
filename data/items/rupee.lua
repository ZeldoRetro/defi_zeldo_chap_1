local item = ...
local game = item:get_game()

function item:on_created()

  -- Define the properties of rupees.
  item:set_shadow("small")
  item:set_brandish_when_picked(false)
  item:set_sound_when_picked("picked_rupee")
  item:set_can_disappear(true)
end

function item:on_obtaining(variant, savegame_variable)

  local amounts = { 1, 5, 20, 50, 100, 300 }
  local amount = amounts[variant]
  game:add_money(amount)
end
