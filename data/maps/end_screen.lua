local map = ...
local game = map:get_game()

local current_credits = sol.surface.create(sol.language.get_language().."/credits/end.png")
function map:on_draw(dst_surface)
  current_credits:draw(dst_surface)
end

function map:on_started()
  game:set_hud_enabled(false) 
  game:set_pause_allowed(false)
  hero:set_visible(false)
end

function map:on_opening_transition_finished()
  hero:freeze()
  sol.audio.stop_music()
  sol.audio.play_sound("world_warp")
  game:set_value("key_item_901",true)
  game:save()
  sol.timer.start(game, 5000, function() sol.main.reset() end)
end