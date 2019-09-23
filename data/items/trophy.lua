local item = ...

function item:on_created()

  -- Define the properties.
  self:set_sound_when_picked(nil)
  self:set_shadow("small")
  self:set_savegame_variable("trophy")
end
