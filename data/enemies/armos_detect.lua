local enemy = ...

-- Armos Status: Stationary until hero gets close, then comes to life.

local going_hero = false
local timer

function enemy:on_created()
  self:set_life(4)
  self:set_damage(4)
  self:create_sprite("enemies/armos")
  self:set_hurt_style("monster")
  self:set_size(16, 16)
  self:set_origin(8, 12)
  self:get_sprite():set_animation("immobilized")
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("arrow", "protected")
  self:set_attack_consequence("thrown_item", "protected")
  self:set_attack_consequence("hookshot", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("fire", "protected")
  self:set_traversable(false)
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:stop()
    self:check_hero()
  end
end

function enemy:on_restarted()
  self:stop()
  self:check_hero()
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 64

  if near_hero and not going_hero then
    self:go_hero()
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:stop()
  self:set_attack_consequence("arrow", "protected")
  self:set_can_attack(false)
  self:set_can_hurt_hero_running(false)
  self:get_sprite():set_animation("immobilized")
  --movement:stop(self)
  going_hero = false
end

function enemy:go_hero()
  self:set_attack_consequence("arrow", 2)
  self:set_attack_consequence("sword", 1)
  self:set_can_attack(true)
  self:set_can_hurt_hero_running(true)
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(40)
  m:start(self)
  going_hero = true
end
