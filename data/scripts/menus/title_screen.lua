local title_screen = {}
local background = false
local title = false
local space = false

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

local zs_presents_img = sol.surface.create("menus/title_screen_initialization.png")
  
local logo_img = sol.surface.create("menus/title_logo.png")
local copyright_img = sol.surface.create("menus/title_copyright.png")
local background_img = sol.surface.create("menus/title_" .. time_of_day
      .. "_background.png")
local press_space_img

function title_screen:on_started()
  sol.audio.play_sound("intro")

  sol.timer.start(self, 2000, function()
  background = true
  sol.audio.play_music("intro",false)
  sol.timer.start(7000,function()
  title = true
  sol.timer.start(500,function() if space then space = false else space = true end return true end)
  end)
  end)
end

function title_screen:on_draw(dst_surface)

  zs_presents_img:draw(dst_surface)
  if background then
  background_img:draw(dst_surface)
  end
  
  if title then
	logo_img:draw(dst_surface, 60, 6)
	copyright_img:draw(dst_surface)
  end
  if space then
  press_space_img = sol.surface.create(sol.language.get_language().."/title/title_press_space.png")
	press_space_img:draw(dst_surface)
  end
end

function title_screen:on_key_pressed(key)

  if key == "return" or key == "space" then
    if title then
		sol.audio.play_sound("pause_closed")
		sol.menu.stop(title_screen)
	end
	if background then
		title = true
		sol.timer.start(500,function() if space then space = false else space = true end return true end)
    end
  end
end

function title_screen:on_joypad_button_pressed(button)
  return self:on_key_pressed("space")
end

return title_screen