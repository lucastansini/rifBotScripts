--[[
    Script Name:        Pickup Free items
    Description:        Pickup free items around your character to first slot in any opened backpack.
    Author:             Ascer - example
]]

local FREE_ITEMS = {3552}     -- IDs of items to pickup
local OPEN_NEXT_BP_IF_FULL = {enabled = false, id = 2854} -- open next backpack: enabled - true/false, 
local BOOTS_ID = 3552          -- id of new soft boots 

-- DON'T EDIT BELOW

	Module.New("Pickup items", function()
    
		if Self.isConnected() then
        
			-- load self pos.
			local pos = Self.Position()

			-- in range for 1 sqm
			for x = -1, 1 do
			for y = -1 , 1 do
                
					-- load map
					local map = Map.GetTopMoveItem(pos.x + x, pos.y + y, pos.z)

					-- when we found item
					if table.find(FREE_ITEMS, map.id) then
                   
						-- Pickup item
						Self.PickupItem(pos.x + x, pos.y + y, pos.z, map.id, map.count, Container.GetWithEmptySlots(nr), 0, 0)
						
						-- load feet.						
						local feet = Self.Feet().id

						-- when no boots on feet
						if feet <= 0 then

						-- equip boots
						Self.EquipItem(SLOT_FEET, SOFT_BOOTS_NEW_ID, 1)
						
 					else	

    					-- when on feet are different boots than already using softs.
    					if feet ~= SOFT_BOOTS_USING then

    					-- dequip boots to any opened container.
    					Self.DequipItem(SLOT_FEET)

                
					end 

				end
            
			end     
		end
	end)