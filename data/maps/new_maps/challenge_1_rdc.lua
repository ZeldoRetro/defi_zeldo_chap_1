local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

texte_lieu = sol.surface.create(sol.language.get_language().."/texte_lieu/defi_zeldo.png")

--DEBUT DE LA MAP
function map:on_started()
  --PORTES OUVERTES
  map:set_doors_open("falling_door")
  map:set_doors_open("door_boss")
  --COFFRES INVISIBLES
  map:set_entities_enabled("chest",false)
  --ENEMIS DESACTIVES DE BASE (BOSS, MINIBOSS, ENEMIS POUR BATAILLE, ...)
  map:set_entities_enabled("enemy_battle",false)
  --TELEPORTEUR DESACTIVES DE BASE
	map:set_entities_enabled("telep",false)
  --COFFRES CLES OBTENUS:SWITCHS RESTENT ACTIVES
  if game:get_value("key_001_1") then 
    map:set_entities_enabled("chest_key_1",true)
    switch_chest_key_1:set_activated(true)
    local x1, y1 = switch_chest_key_1:get_position()
    block_1:set_position(x1 + 8, y1 + 12)
  end
  --MINIBOSS VAINCU
  if game:get_value("miniboss_901") then
	  map:set_entities_enabled("telep_miniboss",true)
  end
  --TELEPORTEUR BOSS
  if game:get_value("telep_boss_901") then
    switch_telep_boss:set_activated(true)
    map:set_entities_enabled("telep_boss",true)
  end
  --BOSS
  if game:get_value("boss_901") then
      boss_sensor:set_enabled(false)
      map:set_entities_enabled("rage_hole",false)
      map:set_entities_enabled("anti_hole",true)
  else
      boss:set_enabled(false)
  end
end

--PIECE TROLL 1: COMBAT POUR RESSORTIR
for enemy in map:get_entities("enemy_door_1") do
  enemy.on_dead = function()
    if not map:has_entities("enemy_door_1") then
    	sol.audio.play_sound("secret")
    	sol.audio.play_sound("door_open")
      sensor_falling_door_1:set_enabled(false)
      map:open_doors("falling_door_1")
    end
  end
end

--CLE 1:BLOC A BIEN PLACER
function switch_chest_key_1:on_activated()
  sol.audio.play_sound("secret")
  map:set_entities_enabled("chest_key_1",true)
end

--SWITCH TELEPORTEUR BOSS
function switch_telep_boss:on_activated()
  sol.audio.play_sound("secret")
  map:set_entities_enabled("telep_boss",true)
  game:set_value("telep_boss_901",true)
end

--BOSS ACTIVE
function boss_sensor:on_activated()
    map:close_doors("door_boss")
    boss:set_enabled(true)
    sol.audio.play_music("boss")
    boss_sensor:set_enabled(false)
end
--BOSS
if boss ~= nil then
 function boss:on_dead()
  map:open_doors("door_boss_1")
  sol.audio.play_music("after_boss")
  sol.audio.play_sound("secret") 
  map:set_entities_enabled("rage_hole",false)
  map:set_entities_enabled("anti_hole",true)
 end
end

--MURS FISSURES
function weak_door_1:on_opened()
  sol.audio.play_sound("secret")
end

--FIN DONJON
function map:on_obtained_treasure(item, variant, treasure_savegame_variable)
  if item:get_name() == "trophy" and item:get_variant() == 1 then
    hero:freeze()
    game:set_pause_allowed(false)
    sol.audio.play_music("victory")
    game:set_life(game:get_max_life())
    game:set_magic(game:get_max_magic())
    sol.timer.start(9500,function() 
       hero:start_victory()
       sol.timer.start(1000,function()
    	  game:set_pause_allowed(true)
          hero:teleport("ending","destination","fade") 
          end)     
       end)
  end
end
