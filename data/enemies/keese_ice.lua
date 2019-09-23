local enemy = ...

-- Ice Keese (bat): Basic flying enemy, but also frozen!

local state = "stopped"
local timer

function enemy:on_created()
  self:set_life(4)
  self:set_damage(2)
  self:create_sprite("enemies/keese_ice")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:get_sprite():set_animation("stopped")
  self:set_fire_reaction(4)
end

function enemy:on_restarted()

  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(56)
  m:start(self)
end

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    -- Hero is frozen.
	hero:start_hurt(4)
  hero:freeze()
	hero:set_animation("frozen")
  sol.audio.play_sound("hero_hurt")
  sol.timer.start(2000, function () hero:unfreeze() end)
  end
end
