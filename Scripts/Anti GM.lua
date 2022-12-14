--[[
    Script Name:        Anti GM
    
    Description:        Advanced script to stops bot when GM detected or intereacting with as.                
    Author:             Ascer - example 
]]

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> CONFIG SECTION: start
----------------------------------------------------------------------------------------------------------------------------------------------------------

local CHECK_IF_TELEPORTED = {
    enabled = false,                                     -- true/false check if you character was teleported
    sqms = 3,                                           -- minimal amount of sqms to check.
    pauseBot = true                                     -- true/false pause bot or not (default alarm will play)
}

local CHECK_IF_GM_ON_SCREEN = {
    enabled = true,                                     -- true/false check for gm on screen
    keywords = {"GM ", "CM ", "Admin ", "ADM ", "Tutor"},        -- table of keywords in gm nick
    pauseBot = true                                     -- true/false pause bot or not (default alarm will play)    
}

local CHECK_FOR_PM_DEFAULT_MESSAGE = {
    enabled = true,                                     -- true/false check if gm send to as pm or default message, #IMPORTANT respond only to nicks from CHECK_IF_GM_ON_SCREEN.keywords
    pauseBot = true,                                    -- true/false pause bot or not (default alarm will play)
    respond = {
        enabled = true,                                -- true/false respond fo default message
        randomMsg = {"sup :p", "hello"}     -- messages to respond only once
    } 
}

local CHECK_FOR_MANA_INCREASED = {
    enabled = false,                                     -- true/false check if mana gained fast in one tick.
    points = 200,                                       -- minimal mana points gained to module works
    pauseBot = true                                     -- true/false pause bot or not (default alarm will play)
}

local CHECK_FOR_HEALTH_DMG = {
    enabled = false,                                     -- true/false check for hp decarese by percent
    percent = 60,                                       -- minimal hpperc decreased by GM.                  
    pauseBot = true                                     -- true/false pause bot or not (default alarm will play)
}

local CHECK_FOR_SPECIAL_MONSTER = {
    enabled = false,                                    -- true/false check if on screen appear special monster that normal don't appear in this place
    names = {"Demon", "Black Sheep"},                   -- monster names
    pauseBot = true
}

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> CONFIG SECTION: end
----------------------------------------------------------------------------------------------------------------------------------------------------------


-- DONT'T EDIT BELOW THIS LINE 

CHECK_FOR_SPECIAL_MONSTER.names = table.lower(CHECK_FOR_SPECIAL_MONSTER.names)

local detectTime = 0
local teleported, old = false, {x=0, y=0, z=0}
local lastMana = Self.Mana()
local lastHealth = Self.Health()
local responders, respond = {}, false


----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       checkIfTeleported()
--> Description:    Check for character current position and play sound and stops bot when pos quick change.
-->                 
--> Return:         nil - nothing
----------------------------------------------------------------------------------------------------------------------------------------------------------
function checkIfTeleported()
    if not CHECK_IF_TELEPORTED.enabled then return end
    if teleported then
        Rifbot.PlaySound("Default.mp3")
        if CHECK_IF_TELEPORTED.pauseBot then
            if Rifbot.isEnabled() then
                Rifbot.setEnabled(false)
            end 
        end 
    end    
    local dist = Self.DistanceFromPosition(old.x, old.y, old.z)
    if dist >= CHECK_IF_TELEPORTED.sqms and old.x ~= 0 then
        teleported = true
        print("Your character has been teleported " .. dist .. " sqms.")
    end
    old = Self.Position()
end 

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       checkForVisibleGM(creatures)
--> Description:    Check for gms on screen and play sound.
--> Params:         
-->                 @creatures table with creatures.
-->                 
--> Return:         nil - nothing
----------------------------------------------------------------------------------------------------------------------------------------------------------
function checkForVisibleGM(creatures)
    if not CHECK_IF_GM_ON_SCREEN.enabled then return end
    for i = 1, #creatures do
        local player = creatures[i]
        if Creature.isPlayer(player) then
            for j = 1, #CHECK_IF_GM_ON_SCREEN.keywords do
                if string.instr(player.name, CHECK_IF_GM_ON_SCREEN.keywords[j]) then
                    Rifbot.PlaySound("Default.mp3")
                    if CHECK_IF_GM_ON_SCREEN.pauseBot then
                        if Rifbot.isEnabled() then
                            Rifbot.setEnabled(false)
                        end 
                    end
                    print("Detected player " .. player.name .. " on screen.")
                    break    
                end    
            end    
        end    
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       checkForManaIncreased()
--> Description:    Check for mana increased.
-->                 
--> Return:         nil - nothing
----------------------------------------------------------------------------------------------------------------------------------------------------------
function checkForManaIncreased()
    if not CHECK_FOR_MANA_INCREASED.enabled then return end
    local mp = Self.Mana()
    if mp > lastMana then
        local gain = mp - lastMana
        if gain >= CHECK_FOR_MANA_INCREASED.points then
            Rifbot.PlaySound("Default.mp3")
            if CHECK_FOR_MANA_INCREASED.pauseBot then
                if Rifbot.isEnabled() then
                    Rifbot.setEnabled(false)
                end 
            end
            print("Mana increased by " .. gain .. " points")
        end    
    end
    lastMana = mp 
end 

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       checkForHealthDmg()
--> Description:    Check for health dmg.
-->                 
--> Return:         nil - nothing
----------------------------------------------------------------------------------------------------------------------------------------------------------
function checkForHealthDmg()
    if not CHECK_FOR_HEALTH_DMG.enabled then return end
    local hp = Self.Health()
    if hp < lastHealth then
        local dmg = lastHealth - hp
        dmg = math.floor((dmg / Self.HealthMax()) * 100)
        if dmg >= CHECK_FOR_HEALTH_DMG.percent then
            Rifbot.PlaySound("Default.mp3")
            if CHECK_FOR_HEALTH_DMG.pauseBot then
                if Rifbot.isEnabled() then
                    Rifbot.setEnabled(false)
                end 
            end
            print("Health dmg over " .. dmg .. "%")
        end    
    end
    lastHealth = hp 
end 

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       checkForSpecialMonsters(creatures)
--> Description:    Check for special creatures screen and play sound.
--> Params:         
-->                 @creatures table with creatures.
-->                 
--> Return:         nil - nothing
----------------------------------------------------------------------------------------------------------------------------------------------------------
function checkForSpecialMonsters(creatures)
    if not CHECK_FOR_SPECIAL_MONSTER.enabled then return end
    for i = 1, #creatures do
        local mob = creatures[i]
        if Creature.isMonster(mob) then
            if table.find(CHECK_FOR_SPECIAL_MONSTER.names, string.lower(mob.name)) then
                Rifbot.PlaySound("Default.mp3")
                if CHECK_FOR_SPECIAL_MONSTER.pauseBot then
                    if Rifbot.isEnabled() then
                        Rifbot.setEnabled(false)
                    end 
                end
                print("Detected monster " .. mob.name .. " on screen.")
                break    
            end        
        end    
    end
end    

----------------------------------------------------------------------------------------------------------------------------------------------------------
--> Function:       respondForMessage()
--> Description:    Execute message respond.
-->                 
--> Return:         nil - nothing
----------------------------------------------------------------------------------------------------------------------------------------------------------
function respondForMessage()
    if respond then
        local msg = CHECK_FOR_PM_DEFAULT_MESSAGE.respond.randomMsg[math.random(1, #CHECK_FOR_PM_DEFAULT_MESSAGE.respond.randomMsg)]
        Self.Say(msg)
        respond = false
        respondTime = os.clock()
        print("Responded this message: " .. msg)
    end
    if os.clock() - respondTime > 10 * 60 then -- reset list to respond
        responders = {}
    end     
end    

-- proxy messages
function proxy(messages) 
    if not CHECK_IF_GM_ON_SCREEN.enabled then return end
    for i, msg in ipairs(messages) do 
        for j = 1, #CHECK_IF_GM_ON_SCREEN.keywords do
            if string.instr(msg.speaker, CHECK_IF_GM_ON_SCREEN.keywords[j]) then
                Rifbot.PlaySound("Default.mp3")
                if CHECK_FOR_PM_DEFAULT_MESSAGE.respond.enabled then
                    if not table.find(responders, msg.speaker) then
                        table.insert(responders, msg.speaker)
                        respond = true
                    end
                end    

                if CHECK_FOR_PM_DEFAULT_MESSAGE.pauseBot then
                    if Rifbot.isEnabled() then
                        Rifbot.setEnabled(false)
                    end 
                end

                print("Recived message from: " .. msg.speaker .. ", message: " .. msg.message)
                break    
            end    
        end    
    end 
end 
Proxy.New("proxy")

-- module 200ms
Module.New("Anti GM", function ()
    
    -- when connected.
    if Self.isConnected() then

        -- load creatures.
        local creatures = Creature.getCreatures()

        checkIfTeleported()
        checkForVisibleGM(creatures)
        checkForManaIncreased()
        checkForHealthDmg()
        respondForMessage()
        checkForSpecialMonsters(creatures)

    end 

end)
