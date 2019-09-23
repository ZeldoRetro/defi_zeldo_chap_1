local item = ...

function item:on_created()

  self:set_savegame_variable("get_rupee_bag")
end

function item:on_variant_changed(variant)

  -- Obtaining a rupee bag changes the max money.
  local max_moneys = {500, 999, 5000, 9999}
  local max_money = max_moneys[variant]
  if max_money == nil then
    error("Invalid variant '" .. variant .. "' for item 'rupee_bag'")
  end

  self:get_game():set_max_money(max_money)
end

