local item = ...

function item:on_created()
    self:set_savegame_variable('small_key')
    self:set_shadow("small")
    self:set_amount_savegame_variable('small_key_amount')
    self:set_sound_when_picked("picked_small_key")
    self:set_brandish_when_picked(false)
    self:set_max_amount(9)
end

function item:on_obtained()
    self:add_amount(1)
end
