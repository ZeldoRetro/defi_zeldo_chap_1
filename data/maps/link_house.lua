local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

texte_lieu = sol.surface.create("texte_lieu/goron_mine.png")

--EFFET DE CHALEUR
local heat = sol.surface.create(320,240)
heat:set_opacity(100)
heat:fill_color({255,40,0})

function map:on_draw(dst_surface)
  heat:draw(dst_surface)
end
