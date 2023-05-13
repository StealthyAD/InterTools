--[[

    ██╗███╗   ██╗████████╗███████╗██████╗ ████████╗ ██████╗  ██████╗ ██╗     ███████╗
    ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
    ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝   ██║   ██║   ██║██║   ██║██║     ███████╗
    ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗   ██║   ██║   ██║██║   ██║██║     ╚════██║
    ██║██║ ╚████║   ██║   ███████╗██║  ██║   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
    ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
                                                                                    
    Features:
    - Compatible All Stand Versions if deprecated versions too.
    - Complete script.

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html

    Part: Self
]]--

    ---========================================----
    ---              Self Roots
    ---         The part of self roots
    ----========================================----

        local SelfParts = InterRoot:list("Self Options", {"intself"})
        local AnimalsParts = SelfParts:list("Animals Parts")
        local AnimationsParts = SelfParts:list("Animations Features")
        local LocalParts = SelfParts:list("Local Parts")

    ----========================================----
    ---              Self Parts
    ---         The part of self parts
    ----========================================----

        SelfParts:toggle_loop("Enhance Respawn", {}, "Able to respawn faster while toggle.", function()
            QuickRespawn()
        end)

        SelfParts:toggle_loop("Ragdoll Loop", {}, "Loop Ragdoll", function()
            PED.SET_PED_TO_RAGDOLL(players.user_ped(), 2500, 0, 0, false, false, false)
        end)

        SelfParts:toggle_loop("Toggle Fast Roll", {}, "The nostalgia of the PS3 modding which we could fast roll as much as we can.", function()
            STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_SHOOTING_ABILITY"), 200, true)
        end)

        SelfParts:toggle_loop("Burn Proof Mode", {}, "Make able to avoid burn in fire while put fire", function()
            FIRE.STOP_ENTITY_FIRE(PLAYER.PLAYER_PED_ID())
        end)

        SelfParts:toggle("Partial Invisible", {}, "Turn partially invisible mode (Players will not able to see you), but you will see only yourself, includes vehicles.\nNo one can see you in the minimap.", function(toggle)
            local remote = toggle and "remote" or "off"
            EnhanceOTR(toggle)
            InterCmds("invisibility ".. remote)
            InterCmds("vehinvisibility " .. remote)
        end)

        SelfParts:toggle_loop("Enhanced Invisibility", {}, "", function()
            invis = invis ?? memory.script_global(2657589 + 1 + (players.user() * 466) + 254)
            if not ENTITY.IS_ENTITY_DEAD(players.user_ped()) then
                memory.write_byte(invis, 1)
            else
                memory.write_byte(invis, 0)
            end
        end,function()
            memory.write_byte(invis, 0)
            invis = nil
        end)

        SelfParts:toggle("Better OTR", {}, "No one can see you on your minimap.", function(state)
            EnhanceOTR(state)
        end)

        local maxHealth <const> = 328
        SelfParts:toggle_loop("Undead OTR", {}, "Turn you off the radar without notifying other players.\nNOTE: Trigger Modded Health detection.", function()
            if  ENTITY.GET_ENTITY_MAX_HEALTH(players.user_ped()) ~= 0 then
                ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(), 0)
            end
        end, function ()
            ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(), maxHealth)
        end)

        SelfParts:toggle_loop("Force Clean Ped & Wetness", {}, "Force Cleanup Ped & Wetness against blood or damage.", function() 
            PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID()) 
            PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
        end)

        SelfParts:toggle("Reduce Footsteps", {}, "", function(toggle)
            AUDIO.SET_PED_FOOTSTEPS_EVENTS_ENABLED(PLAYER.PLAYER_PED_ID(), not toggle)
        end)

        SelfParts:toggle("Cold Blooded", {}, "Remove your own signature against players using thermal scope/helmet and make harder to aim.", function(toggle)
            if toggle then
                PED.SET_PED_HEATSCALE_OVERRIDE(players.user_ped(), 0)
            else
                PED.SET_PED_HEATSCALE_OVERRIDE(players.user_ped(), 1)
            end
        end)

        SelfParts:action("Enter Nearest Vehicle", {}, "", function()
            local vehicles = entities.get_all_vehicles_as_handles()
            if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                if PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicles[1], -1)) then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.GET_PLAYER_PED(players.user()), vehicles[1], -2)
                else
                    PED.SET_PED_INTO_VEHICLE(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicles[1], -1), vehicles[1], -2)
                    PED.SET_PED_INTO_VEHICLE(PLAYER.GET_PLAYER_PED(players.user()), vehicles[1], -1)
                end
            end
        end)

        SelfParts:action("Russian Roulette", {}, "Play Russian Roulette\nProbability: Survived or Died", function()
            local rand = math.random(6)
            local pid = players.user()
            if players.is_godmode(pid) then
                InterNotify("Sorry you can't play Russian Roulette.\nMake sure you disable godmode to play.")
            else
                if rand == 1 then
                    local ped = players.user()
                    local pos = players.get_position(ped)
                    pos.z = pos.z - 1.0
                    for i = 0, 50 do
                        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 7, 1000, false, true, 0)
                    end
                    InterNotify("You're dead.")
                else
                    InterNotify("You survived this round of Russian Roulette.")
                end
            end
        end)

        SelfParts:slider("Wanted Level", {}, "Useless features, same as Stand", 0, 5, 0, 1, function(value)
            players.set_wanted_level(players.user(), value)
        end)

   ----========================================----
   ---                 Local Parts
   ---           The part of local self
   ----========================================----

        CustomTimerAutority = LocalParts:slider("Custom Time", {"inttctime"}, "Adding 60 seconds will made you adding more 1 minute to get 3 minutes. Example: 0 means you are in default time: 2 minutes.\nAdding 120 seconds will make you able to stay atleast 4 minutes.", 0, 20000, 0, 1, function()end)
        LocalParts:toggle("Bribe Authorities", {}, "Remove completely cops for a certain period time.\nDefault time: 2 minutes.", function(toggle)
            if toggle then
                local customTime = menu.get_value(CustomTimerAutority) * 1000
                SET_INT_GLOBAL(2793046 + 4654, 81)
                SET_INT_GLOBAL(2793046 + 4655, 1)
                SET_INT_GLOBAL(2793046 + 4657, NETWORK.GET_NETWORK_TIME() + customTime) 
            else
                SET_INT_GLOBAL(2793046 + 4657, 0)
            end
        end)

       LocalParts:action("Edit Health", {"inthealth"}, "Edit Health Bar.\n- Male/Female Ped: < 100 = you die\nHealth bar: 100 - 323\n\nWrite nothing = you die.", function()
            local text = display_onscreen_keyboard()
            ENTITY.SET_ENTITY_HEALTH(players.user_ped(), text)
       end)

        LocalParts:action("Edit Armor", {"intarmor"}, "Edit Armor bar (0 - 50)\nWrite nothing = no armor", function()
            local text = display_onscreen_keyboard()
            PED.SET_PED_ARMOUR(players.user_ped(), text)
        end)

        LocalParts:slider("Local Transparency", {"inttransp"}, "", 0, 100, 100, 20, function(value)
            if value > 80 then
                ENTITY.RESET_ENTITY_ALPHA(players.user_ped())
            else
                ENTITY.SET_ENTITY_ALPHA(players.user_ped(), value * 2.55, false)
            end
        end)

        LocalParts:action("Refill Armor & Snacks", {}, "", function()
            STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30)
            STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
            STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 15)
            STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
            STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
            STAT_SET_INT("CIGARETTES_BOUGHT", 10)
            STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
            STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
            STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
            STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
            STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
        end)

        LocalParts:toggle_loop("CEO Abilities", {""}, "Makes all CEO Abilities Free.", function() 
            SET_PACKED_INT_GLOBAL(12842, 12851, 0)
            SET_PACKED_INT_GLOBAL(15968, 15973, 0)
            SET_INT_GLOBAL(262145 + 15890, 0)
            SET_INT_GLOBAL(262145 + 19302, 0)
            SET_INT_GLOBAL(262145 + 19304, 0)
        end, function()
            SET_PACKED_INT_GLOBAL(12843, 12845, 5000)
            SET_PACKED_INT_GLOBAL(15971, 15973, 5000)
            SET_INT_GLOBAL(262145 + 12842, 20000)
            SET_INT_GLOBAL(262145 + 12846, 25000)
            SET_INT_GLOBAL(262145 + 12847, 1000)
            SET_INT_GLOBAL(262145 + 12848, 1500)
            SET_INT_GLOBAL(262145 + 12849, 1000)
            SET_INT_GLOBAL(262145 + 12850, 12000)
            SET_INT_GLOBAL(262145 + 12851, 15000)
            SET_INT_GLOBAL(262145 + 15890, 5000)
            SET_INT_GLOBAL(262145 + 15968, 10000)
            SET_INT_GLOBAL(262145 + 15969, 7000)
            SET_INT_GLOBAL(262145 + 15970, 9000)
            SET_INT_GLOBAL(262145 + 19302, 5000)
            SET_INT_GLOBAL(262145 + 19304, 10000)
        end)

    ----========================================----
    ---            Animations Parts
    ---          The part of animations
    ----========================================----

        local InterAnimations = {
            ToggleFeature = {},
            ToggleMenu = {},
        }
        InterAnimations.task_list = {
            { 1,   "Climb Ladder" },
            { 2,   "Exit Vehicle)"},
            { 3,   "Combat Roll" },
            { 16,  "Get Up" },
            { 17,  "Get Up And Stand Still" },
            { 50,  "Vault" },
            { 54,  "Open Door" },
            { 121, "Steal Vehicle"},
            { 128, "Melee" },
            { 135, "Synchronized Scene"},
            { 150, "In Vehicle Basic" },
            { 152, "Leave Any Car" },
            { 160, "Enter Vehicle"},
            { 162, "Open Vehicle Door From Outside"},
            { 163, "Enter Vehicle Seat"},
            { 164, "Close Vehicle Door From Inside" },
            { 165, "In Vehicle Seat Shuffle" },
            { 167, "Exit Vehicle Seat" },
            { 168, "Close Vehicle Door From Outside"},
            { 177, "Try To Grab Vehicle Door"},
            { 286, "Throw Projectile"},
            { 300, "Enter Cover"},
            { 301, "Exit Cover"},
        }

        AnimationsParts:toggle_loop("Toggle Feature", {}, "Turning On/Off for Fast Animation", function()
            for id, toggle in pairs(InterAnimations.ToggleFeature) do
                if toggle and TASK.GET_IS_TASK_ACTIVE(players.user_ped(), id) then
                    PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
                end
            end
        end)

        AnimationsParts:divider("Options")
        AnimationsParts:toggle("Enable/Disable Feature", {}, "", function(toggle)
            for _, v in pairs(InterAnimations.ToggleMenu) do
                if menu.is_ref_valid(v) then
                    menu.set_value(v, toggle)
                end
            end
        end)

        for _, v in pairs(InterAnimations.task_list) do
            local id = v[1]
            local name = v[2]

            InterAnimations.ToggleFeature[id] = false

            local menu_toggle = AnimationsParts:toggle(name, {}, "", function(toggle)
                InterAnimations.ToggleFeature[id] = toggle
            end)
            InterAnimations.ToggleMenu[id] = menu_toggle
        end

    ----========================================----
    ---             Animals Parts
    ---          The part of animals
    ----========================================----

        local custom_pet
        AnimalsParts:toggle_loop("Meoww cat", {}, "", function()
            if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                local pet = util.joaat("a_c_cat_01")
                RequestModel(pet)
                local pos = players.get_position(players.user())
                custom_pet = entities.create_ped(28, pet, pos, 0)
                PED.SET_PED_COMPONENT_VARIATION(custom_pet, 0, 0, 1, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
            InterWait(2500)
        end, function()
            entities.delete_by_handle(custom_pet)
            custom_pet = nil
        end)

        AnimalsParts:toggle_loop("Polish Cow", {}, "", function()
            if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                local pet = util.joaat("a_c_cow")
                RequestModel(pet)
                local pos = players.get_position(players.user())
                custom_pet = entities.create_ped(28, pet, pos, 0)
                PED.SET_PED_COMPONENT_VARIATION(custom_pet, 0, 0, 1, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
            InterWait(2500)
        end, function()
            entities.delete_by_handle(custom_pet)
            custom_pet = nil
        end)

        AnimalsParts:toggle_loop("Canadian Deer", {}, "", function()
            if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                local pet = util.joaat("a_c_deer")
                RequestModel(pet)
                local pos = players.get_position(players.user())
                custom_pet = entities.create_ped(28, pet, pos, 0)
                PED.SET_PED_COMPONENT_VARIATION(custom_pet, 0, 0, 1, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
            InterWait(2500)
        end, function()
            entities.delete_by_handle(custom_pet)
            custom_pet = nil
        end)

        AnimalsParts:toggle_loop("German Shepherd", {}, "", function()
            if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                local pet = util.joaat("a_c_shepherd")
                RequestModel(pet)
                local pos = players.get_position(players.user())
                custom_pet = entities.create_ped(28, pet, pos, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
            InterWait(2500)
        end, function()
            entities.delete_by_handle(custom_pet)
            custom_pet = nil
        end)

        AnimalsParts:toggle_loop("iShowSpeed Favorite Animal", {}, "Monkey Monkey Monkey Monkey\nMonkey Monkey Monkey Monkey\nMonkey Monkey Monkey Monkey", function()
            if not custom_pet or not ENTITY.DOES_ENTITY_EXIST(custom_pet) then
                local pet = util.joaat("a_c_chimp")
                RequestModel(pet)
                local pos = players.get_position(players.user())
                custom_pet = entities.create_ped(28, pet, pos, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(custom_pet, true)
            end
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(custom_pet)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(custom_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
            InterWait(2500)
        end, function()
            entities.delete_by_handle(custom_pet)
            custom_pet = nil
        end)

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
