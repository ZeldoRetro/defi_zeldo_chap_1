-- This script handles global behavior of this quest,
-- things not related to a particular savegame.
local quest_manager = {}

-- Initialize map features specific to this quest.
local function initialize_map()

  local map_meta = sol.main.get_metatable("map")
  texte_lieu_on = false

      local shadow = sol.surface.create(5000,5000)
      local lights = sol.surface.create(5000,5000)
      shadow:set_blend_mode("multiply")
      shadow:fill_color({0, 49, 164})
      lights:set_blend_mode("add")
     

  function map_meta:on_draw(dst_surface)
    local game = self:get_game()
    local hero = self:get_hero()
    --AFFICHAGE LIEU
    if texte_lieu_on then texte_lieu:draw(dst_surface) end
  end

  function map_meta:move_camera(x, y, speed, callback, delay_before, delay_after)

    local camera = self:get_camera()
    local game = self:get_game()
    local hero = self:get_hero()

    delay_before = delay_before or 1000
    delay_after = delay_after or 1000

    local back_x, back_y = camera:get_position_to_track(hero)
    game:set_suspended(true)
    camera:start_manual()

    local movement = sol.movement.create("target")
    movement:set_target(camera:get_position_to_track(x, y))
    movement:set_ignore_obstacles(true)
    movement:set_speed(speed)
    movement:start(camera, function()
      local timer_1 = sol.timer.start(self, delay_before, function()
        if callback ~= nil then
          callback()
        end
        local timer_2 = sol.timer.start(self, delay_after, function()
          local movement = sol.movement.create("target")
          movement:set_target(back_x, back_y)
          movement:set_ignore_obstacles(true)
          movement:set_speed(speed)
          movement:start(camera, function()
            game:set_suspended(false)
            camera:start_tracking(hero)
            if self.on_camera_back ~= nil then
              self:on_camera_back()
            end
          end)
        end)
        timer_2:set_suspended_with_map(false)
      end)
      timer_1:set_suspended_with_map(false)
    end)
  end

  function map_meta:on_finished()
    local game = self:get_game()
    texte_lieu_on = false
    game:set_value("sensor_falling_dall_activated_1",false)
    game:set_value("falling_dall",false)
    nb_torches_lit = 0
    temporary_torches = false
  end
end

-- Initialize dynamic tile behavior specific to this quest.
local function initialize_dynamic_tile()

  local dynamic_tile_meta = sol.main.get_metatable("dynamic_tile")

  function dynamic_tile_meta:on_created()

    local name = self:get_name()
    if name == nil then
      return
    end

    if name:match("^invisible_tile") then
      self:set_visible(false)
    end
    if name:match("^invisible_path") then
      self:set_visible(false)
    end
  end
end

-- Initializes shared behavior of destructibles.
local function initialize_destructible()

  local destructible_meta = sol.main.get_metatable("destructible")
  
  -- destructible_meta represents the default behavior of all destructible.
  
  function destructible_meta:on_looked()
    local game = self:get_game()
    if self:get_can_be_cut()
      and not self:get_can_explode()
      and not self:get_game():has_ability("sword") then
      -- The destructible can be cut, but the player has no cut ability.
      game:start_dialog("destructible_cannot_lift_should_cut")
    elseif not game:has_ability("lift") then
      -- No lift ability at all.
      game:start_dialog("destructible_cannot_lift_too_heavy")
    else
      -- Not enough lift ability.
      game:start_dialog("destructible_cannot_lift_still_too_heavy")
    end
  end
    
end

-- Initializes shared behavior of sensors.
local function initialize_sensor()

  local sensor_meta = sol.main.get_metatable("sensor")
  
  -- sensor_meta represents the default behavior of all sensors.
  function sensor_meta:on_activated()
    -- self is the sensor.
    local hero = self:get_map():get_hero()
    local game = self:get_game()
    local map = self:get_map()
    local name = self:get_name()
    if name:match("^save_solid_ground_sensor") then
      local hero = self:get_map():get_hero()
      hero:save_solid_ground()
    end

    -- Sensors prefixed by "dungeon_room_N" save the exploration state of the
    -- room "N" of the current dungeon floor.
    local room = name:match("^dungeon_room_(%d+)")
    if room ~= nil then
      game:set_explored_dungeon_room(nil, nil, tonumber(room))
      self:remove()
      return
    end

    --PRISE EN COMPTE DES LAYERS ET ESCALIERS
    if name:match("^layer_up_sensor") then
      local x, y, layer = hero:get_position()
      if layer < map:get_max_layer() then
        hero:set_position(x, y, layer + 1)
      end
      return
    elseif name:match("^layer_down_sensor") then
      local x, y, layer = hero:get_position()
      if layer > map:get_min_layer() then
        hero:set_position(x, y, layer - 1)
      end
      return
    end

    --AFFICHAGE LIEU
    local opacity = 1
    local function fade_in()
    	opacity = opacity - 5
    	texte_lieu:set_opacity(opacity)
      if opacity > 0 then
    		sol.timer.start(50,fade_in)
      else
        texte_lieu_on = false
      end
    end
    local function fade_out()
    	opacity = opacity + 5
    	texte_lieu:set_opacity(opacity)
      if opacity < 255 then
    		sol.timer.start(50,fade_out)
      else
        fade_in()
      end
    end
    local function affiche_lieu()
      texte_lieu_on = true
      fade_out()
      map:set_entities_enabled("texte_lieu",false)
    end
    if name:match("^texte_lieu") then
      affiche_lieu()
    end
    if name:match("^not_texte") then
      map:set_entities_enabled("texte_lieu",false)
    end

    --GESTION DES SWITCHS ETOILES POUR LES TROUS
    local function hole_1_switch()
    	map:set_entities_enabled("hole_1",true)
    	map:set_entities_enabled("hole_2",false)
    	sol.audio.play_sound("secret")
    end
    local function hole_2_switch()
    	map:set_entities_enabled("hole_2",true)
    	map:set_entities_enabled("hole_1",false)
    	sol.audio.play_sound("secret")
    end
    local function hole_switch()
    	if game:get_value("hole_1_true") then
    		hole_2_switch()
    		game:set_value("hole_1_true",false)
    		return
    	else
    		hole_1_switch()
    		game:set_value("hole_1_true",true)
    		return
    	end
    end
    if name:match("^star_switch_1") then
    	hole_switch()
      map:set_entities_enabled("star_switch_1",false)
      map:set_entities_enabled("star_switch_2",true)
    end
    if name:match("^star_switch_2") then
    	hole_switch()
      map:set_entities_enabled("star_switch_2",false)
      map:set_entities_enabled("star_switch_1",true)
    end

    --SENSORS QUI FERMENT DES PORTES DERRIERE NOUS
    local j = 0
    while j ~= 9 do
      j = j + 1
      if name:match("^sensor_falling_door_"..j) then
        map:set_entities_enabled(name,false)
        map:close_doors("falling_door_"..j)
      end
      if name:match("^sensor_troll_door_"..j) then
        map:close_doors("troll_door_"..j)
      end
      if name:match("^sensor_troll_door_open_"..j) then
        map:set_doors_open("troll_door_"..j)
      end
    end

    --SON DE SECRET QUAND CERTAIN PASSAGE PASSE
    if name:match("^sensor_secret") then
      sol.audio.play_sound("secret")
    end  

    --PAS DE SON DANS CERTAINS LIEUX (EX:AVANT BOSS)
    if name:match("^no_sound_sensor") then
      sol.audio.play_music("none")
    end      
  end
end

-- Initialize enemy behavior specific to this quest.
local function initialize_enemy()

  local enemy_meta = sol.main.get_metatable("enemy")

  function enemy_meta:on_created()

    local name = self:get_name()
    if name == nil then
      return
    end
    if name:match("^invisible_enemy") then
      self:set_visible(false)
    end


  end
  -- Helper function to inflict an explicit reaction from a scripted weapon.
  -- TODO this should be in the Solarus API one day
  function enemy_meta:receive_attack_consequence(attack, reaction)

    if type(reaction) == "number" then
      self:hurt(reaction)
    elseif reaction == "immobilized" then
      self:immobilize()
    elseif reaction == "protected" then
      sol.audio.play_sound("sword_tapping")
    elseif reaction == "custom" then
      if self.on_custom_attack_received ~= nil then
        self:on_custom_attack_received(attack)
      end
    end

  end
end

-- Initialize NPC behavior specific to this quest.
local function initialize_npcs()
  local npc_meta = sol.main.get_metatable("npc")

  function npc_meta:on_interaction()
    local game = self:get_game()
    local name = self:get_name()
    local hero = game:get_hero()
    local map = game:get_map()

    --SYSTEME DE LIT/CAMPEMENT
    if name:match("^lit") then
    	game:start_dialog("auberge.lit.repos",function(answer)
        if answer == 1 then
    			sol.audio.play_sound("day_night")
    			game:add_life(80)
    			game:add_magic(160)
    			hero:teleport(map:get_id(),"sortie_lit","fade")
    			if game:get_value("night") then
                			game:set_value("night",false)				
    			else
    				game:set_value("night",true)
    			end    				
        end
    	end)
    end

    --PIERRES DE TELEPATHIE
    if name:match("^ts") then
      game:set_dialog_style("stone")
      game:start_dialog(name)
    end

    --PIERRES DE TELEPATHIE
    if name:match("^sign") then
      game:set_dialog_style("wood")
      game:start_dialog(name)
    end

    --MONTER A CHEVAL
    if name:match("^epona") then
      local hero = game:get_hero()
      local map = game:get_map()
      map:set_entities_enabled(name,false)
      sword_level = game:get_ability("sword")
      hero:set_tunic_sprite_id("npc/horse_1")
      --hero:set_shield_sprite_id("npc/undertale_frisk")
      game:set_item_assigned(1, game:get_item("arrow_back"))
      game:set_item_assigned(2, game:get_item("carrot_horse"))
      game:set_ability("sword",0)
      hero:set_walking_speed(120)
      game:set_pause_allowed(false)
      game:set_value("on_epona",true)
      game:get_item("carrot_horse"):set_amount(6)
      local x, y = hero:get_position()
      hero:set_position(x, y - 16)    
    end
  end
end

function quest_manager:initialize_quest()

  initialize_destructible()
  initialize_sensor()
  initialize_map()
  initialize_dynamic_tile()
  initialize_enemy()
  initialize_npcs()
end



return quest_manager