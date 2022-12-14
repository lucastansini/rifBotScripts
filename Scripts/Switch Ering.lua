--[[
    Script Name: 		Switch Ering
    Description: 		Equip energy ring when when hpperc <= 75% else dquip to first open container.
    Author: 			Ascer - example
]]

local ENERGY_RING = {on = 3088, off = 3051} -- set id for ering on - equiped, off - not
local HPPERC = 75							-- when hpperc below or equal rquip ring else dequip

Module.New("Switch Ering", function (mod)
    local hp = Self.HealthPercent()
    local ring = Self.Ring()
    if hp <= HPPERC then
        if ring.id ~= ENERGY_RING.on then
            Self.EquipItem(SLOT_RING, ENERGY_RING.off, 1)
        end
    else
        if ring.id == ENERGY_RING.on then
            Self.DequipItem(SLOT_RING, 0, 19) -- dequip ring to last slot in first backpack.
        end
    end
    mod:Delay(200, 700)
end)
