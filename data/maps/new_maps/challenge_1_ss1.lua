local map = ...
local game = map:get_game()

local door_manager = require("maps/lib/door_manager")
door_manager:manage_map(map)
local separator_manager = require("maps/lib/separator_manager")
separator_manager:manage_map(map)

--DEBUT DE LA MAP
function map:on_started()
  --PORTES OUVERTES
  map:set_doors_open("door_miniboss")
  map:set_doors_open("falling_door")
  --COFFRES INVISIBLES
  map:set_entities_enabled("chest",false)
  --ENEMIS DESACTIVES DE BASE (BOSS, MINIBOSS, ENEMIS POUR BATAILLE, ...)
  map:set_entities_enabled("enemy_battle",false)
  map:set_entities_enabled("miniboss",false)
  --TELEPORTEUR DESACTIVES DE BASE
	map:set_entities_enabled("telep",false)
  --COFFRES CLES OBTENUS:SWITCHS RESTENT ACTIVES

  --MINIBOSS VAINCU
  if game:get_value("miniboss_901") then
	  map:set_entities_enabled("telep_miniboss",true)
    sensor_miniboss:set_enabled(false)
  end
  --ENIGME DE LA CLE VERTE FAITE
	if game:get_value("green_key_901",true) then
		chest_green_key:set_enabled(true)
		switch_green_key:set_activated(true)
    local x1, y1 = switch_green_key_1:get_position()
    statue_1:set_position(x1 + 8, y1 + 12)
    local x2, y2 = switch_green_key_2:get_position()
    statue_2:set_position(x2 + 8, y2 + 12)
    local x3, y3 = switch_green_key_3:get_position()
    statue_3:set_position(x3 + 8, y3 + 12)
    local x4, y4 = switch_green_key_4:get_position()
    statue_4:set_position(x4 + 8, y4 + 12)
	else
		chest_green_key:set_enabled(false)
	end
  --ENIGME DE LA CLE JAUNE FAITE
	if game:get_value("yellow_key_901",true) then
		chest_yellow_key:set_enabled(true)
		switch_yellow_key:set_activated(true)
    local x1, y1 = switch_yellow_key_1:get_position()
    block_1:set_position(x1 + 8, y1 + 12)
    local x2, y2 = switch_yellow_key_2:get_position()
    block_2:set_position(x2 + 8, y2 + 12)
    local x3, y3 = switch_yellow_key_3:get_position()
    block_3:set_position(x3 + 8, y3 + 12)
    local x4, y4 = switch_yellow_key_4:get_position()
    block_4:set_position(x4 + 8, y4 + 12)
	else
		chest_yellow_key:set_enabled(false)
	end
--ENIGME FINALE FAITE
	if game:get_value("bosskey_901") then
		chest_bigkey:set_enabled(true)
		bigkey_switch_10:set_activated(true)
		bigkey_switch_2:set_activated(true)
		bigkey_switch_3:set_activated(true)
		bigkey_switch_4:set_activated(true)
		bigkey_switch_5:set_activated(true)
		bigkey_switch_6:set_activated(true)
		bigkey_switch_7:set_activated(true)
		bigkey_switch_8:set_activated(true)
		bigkey_switch_9:set_activated(true)
	else
		chest_bigkey:set_enabled(false)
	end
end

--MINIBOSS
function sensor_miniboss:on_activated()
  sol.audio.play_music("miniboss")
  sensor_miniboss:set_enabled(false)
  map:set_entities_enabled("miniboss",true) 
  map:close_doors("door_miniboss") 
  map:get_entity("miniboss"):set_hurt_style("boss")
end
for enemy in map:get_entities("miniboss") do
  enemy.on_dead = function()
    if not map:has_entities("miniboss") then
    	map:open_doors("door_miniboss")
	    map:set_entities_enabled("telep_miniboss_1",true)
    	sol.audio.play_sound("secret")
    	sol.audio.play_music("retro_dungeon")
      game:set_value("miniboss_901",true)
    end
  end
end

--ENIGME 1: CLE VERTE
function switch_green_key:on_activated()
	if switch_green_key_1:is_activated() and switch_green_key_2:is_activated() and switch_green_key_3:is_activated() and           	switch_green_key_4:is_activated() then
		sol.audio.play_sound("secret")
		chest_green_key:set_enabled(true)
	else
		sol.timer.start(500,function()
			sol.audio.play_sound("wrong")
			switch_green_key:set_activated(false)
		end)
	end
end

--ENIGME 2: CLE JAUNE
function switch_yellow_key:on_activated()
	if switch_yellow_key_1:is_activated() and switch_yellow_key_2:is_activated() and switch_yellow_key_3:is_activated() and           	switch_yellow_key_4:is_activated() then
		sol.audio.play_sound("secret")
		chest_yellow_key:set_enabled(true)
	else
		sol.timer.start(500,function()
			sol.audio.play_sound("wrong")
			switch_yellow_key:set_activated(false)
		end)
	end
end

--ENIGME FINALE: CLE DU BOSS

function bigkey_switch_10:on_activated()
	if bigkey_switch_2:is_activated() then
		bigkey_switch_2:set_activated(false)
	else
		bigkey_switch_2:set_activated(true)
	end
	if bigkey_switch_9:is_activated() then
		bigkey_switch_9:set_activated(false)
	else
		bigkey_switch_9:set_activated(true)
	end
end
function bigkey_switch_2:on_activated()
	if bigkey_switch_10:is_activated() then
		bigkey_switch_10:set_activated(false)
	else
		bigkey_switch_10:set_activated(true)
	end
	if bigkey_switch_3:is_activated() then
		bigkey_switch_3:set_activated(false)
	else
		bigkey_switch_3:set_activated(true)
	end
end
function bigkey_switch_3:on_activated()
	if bigkey_switch_2:is_activated() then
		bigkey_switch_2:set_activated(false)
	else
		bigkey_switch_2:set_activated(true)
	end
	if bigkey_switch_8:is_activated() then
		bigkey_switch_8:set_activated(false)
	else
		bigkey_switch_8:set_activated(true)
	end
end
function bigkey_switch_8:on_activated()
	if bigkey_switch_3:is_activated() then
		bigkey_switch_3:set_activated(false)
	else
		bigkey_switch_3:set_activated(true)
	end
	if bigkey_switch_7:is_activated() then
		bigkey_switch_7:set_activated(false)
	else
		bigkey_switch_7:set_activated(true)
	end
end
function bigkey_switch_7:on_activated()
	if bigkey_switch_5:is_activated() then
		bigkey_switch_5:set_activated(false)
	else
		bigkey_switch_5:set_activated(true)
	end
	if bigkey_switch_8:is_activated() then
		bigkey_switch_8:set_activated(false)
	else
		bigkey_switch_8:set_activated(true)
	end
end
function bigkey_switch_5:on_activated()
	if bigkey_switch_7:is_activated() then
		bigkey_switch_7:set_activated(false)
	else
		bigkey_switch_7:set_activated(true)
	end
	if bigkey_switch_6:is_activated() then
		bigkey_switch_6:set_activated(false)
	else
		bigkey_switch_6:set_activated(true)
	end
end
function bigkey_switch_6:on_activated()
	if bigkey_switch_5:is_activated() then
		bigkey_switch_5:set_activated(false)
	else
		bigkey_switch_5:set_activated(true)
	end
	if bigkey_switch_9:is_activated() then
		bigkey_switch_9:set_activated(false)
	else
		bigkey_switch_9:set_activated(true)
	end
end
function bigkey_switch_9:on_activated()
	if bigkey_switch_6:is_activated() then
		bigkey_switch_6:set_activated(false)
	else
		bigkey_switch_6:set_activated(true)
	end
	if bigkey_switch_10:is_activated() then
		bigkey_switch_10:set_activated(false)
	else
		bigkey_switch_10:set_activated(true)
	end
end

function bigkey_switch_4:on_activated()
	if bigkey_switch_10:is_activated() and bigkey_switch_2:is_activated() and bigkey_switch_3:is_activated() and 		bigkey_switch_5:is_activated() and bigkey_switch_6:is_activated() and  bigkey_switch_7:is_activated() and bigkey_switch_8:is_activated() and bigkey_switch_9:is_activated() then
		sol.audio.play_sound("secret")
		chest_bigkey:set_enabled(true)
	else
		sol.timer.start(500,function()
			sol.audio.play_sound("wrong")
			bigkey_switch_4:set_activated(false)
		end)
	end
end

--MURS FISSURES
function weak_door_1:on_opened()
  sol.audio.play_sound("secret")
end
function weak_door_2:on_opened()
  sol.audio.play_sound("secret")
end
function weak_door_3:on_opened()
  sol.audio.play_sound("secret")
end
function weak_door_4:on_opened()
  sol.audio.play_sound("secret")
end

--PORTES TROLL
function sensor_troll_door_open_4:on_activated()
  local movement = sol.movement.create("straight")
  movement:set_angle(0)
  movement:set_speed(88)
  movement:set_max_distance(96)

  map:set_doors_open("troll_door_4")
  hero:freeze()
  hero:set_direction(0)
  hero:set_animation("walking")
  movement:start(hero, function() hero:unfreeze() end)
end
function sensor_troll_door_open_5:on_activated()
  local movement = sol.movement.create("straight")
  movement:set_angle(math.pi)
  movement:set_speed(88)
  movement:set_max_distance(96)

  map:set_doors_open("troll_door_5")
  hero:freeze()
  hero:set_direction(2)
  hero:set_animation("walking")
  movement:start(hero, function() hero:unfreeze() end)
end
function sensor_troll_door_open_6:on_activated()
  local movement = sol.movement.create("straight")
  movement:set_angle(3*math.pi/2)
  movement:set_speed(88)
  movement:set_max_distance(96)

  map:set_doors_open("troll_door_6")
  hero:freeze()
  hero:set_direction(3)
  hero:set_animation("walking")
  movement:start(hero, function() hero:unfreeze() end)
end
function sensor_troll_door_open_7:on_activated()
  local movement = sol.movement.create("straight")
  movement:set_angle(0)
  movement:set_speed(88)
  movement:set_max_distance(96)

  map:set_doors_open("troll_door_7")
  hero:freeze()
  hero:set_direction(0)
  hero:set_animation("walking")
  movement:start(hero, function() hero:unfreeze() end)
end