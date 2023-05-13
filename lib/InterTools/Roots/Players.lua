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

    Part: Players
]]--

    ----========================================----
    ---              Player Parts
    ---    The part of the most important part
    ----========================================----

        players.on_join(function(pid)
            local PlayerMenu = menu.player_root(pid)
            local InterName = players.get_name(pid)
            PlayerMenu:divider(InterMenu)

            local function harass_specific_vehicle(hash, airVehicle, groundVehicle, heliVehicle)
                if airVehicle then
                    if not players.is_in_interior(pid) then
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        request_model_load(hash)
                        local altitude = 150
                        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, altitude)
                        local vehicle = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(ped))
                        if not STREAMING.HAS_MODEL_LOADED(vehicle) then
                            LoadingModel(vehicle)
                        end
                        for i = 0,49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                        VEHICLE.CONTROL_LANDING_GEAR(vehicle, 3)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 320.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, 1000.0)
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
                        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(PlaneToggleGodP))
                        coords = ENTITY.GET_ENTITY_COORDS(ped, false)
                        coords.x = coords['x']
                        coords.y = coords['y']
                        coords.z = coords['z']
                        local hash_model = util.joaat("s_m_y_pilot_01")
                        request_model_load(hash_model)
                        local attacker = entities.create_ped(28, hash_model, coords, math.random(0, 270))
                        PED.CREATE_PED_INSIDE_VEHICLE(attacker, vehicle, 28, hash_model, -1, true)
                        PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attacker, true, true)
                        TASK.TASK_VEHICLE_MISSION_PED_TARGET(attacker, vehicle, ped, 6, 500.0, 786988, 0.0, 0.0, true)
                        PED.SET_PED_ACCURACY(attacker, 100.0)
                        PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                        PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                        PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                        PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                        SET_PED_CAN_BE_KNOCKED_OFF_VEH(attacker, 1)
                        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                        ENTITY.SET_ENTITY_INVINCIBLE(attacker, true)
                        PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                        local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                        PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                    end
                end
                if groundVehicle then
                    if not players.is_in_interior(pid) then
                        local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local vehicleHash = util.joaat(hash)
                        local marine1 = util.joaat("s_m_y_marine_01")
                        local marine2 = util.joaat("s_m_y_marine_03")
                        request_model_load(vehicleHash)
                        request_model_load(marine1)
                        request_model_load(marine2)
                        local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local pos = ENTITY.GET_ENTITY_COORDS(targetPed)
                        local vehicle = entities.create_vehicle(vehicleHash, pos, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
                        if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
                            return
                        end
                        local offset = getOffsetFromEntityGivenDistance(vehicle, 10)
                        local outCoords = v3.new()
                        local outHeading = memory.alloc()
                    
                        if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
                            ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
                            ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
                            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                        end
                        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do
                            local attackerFlag = entities.create_ped(2, marine1, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
                            PED.SET_PED_INTO_VEHICLE(attackerFlag, vehicle, i)
                            if i % 2 == 0 then
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                                PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                            else
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                                PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                            end
                            PED.SET_PED_AS_COP(attackerFlag, true)
                            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(TankToggleGodP))
                            PED.SET_PED_CONFIG_FLAG(attackerFlag, 281, true)
                            PED.SET_PED_CONFIG_FLAG(attackerFlag, 2, true)
                            PED.SET_PED_CONFIG_FLAG(attackerFlag, 33, false)
                            PED.SET_PED_COMBAT_ATTRIBUTES(attackerFlag, 5, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(attackerFlag, 46, true)
                            PED.SET_PED_ACCURACY(attackerFlag, 100.0)
                            PED.SET_PED_HEARING_RANGE(attackerFlag, 99999)
                            PED.SET_PED_RANDOM_COMPONENT_VARIATION(attackerFlag, 0)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 3)
                            VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
                            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 50)
                            PED.SET_PED_MAX_HEALTH(attackerFlag, 150)
                            ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
                            ENTITY.SET_ENTITY_HEALTH(attackerFlag, 150)
                            PED.SET_PED_ARMOUR(attackerFlag, 100)
                            PED.SET_PED_SHOOT_RATE(attackerFlag, 5)
                            VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
                            VEHICLE.SET_VEHICLE_COLOURS(vehicle, 154, 154)
                            VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, 3, 154, 0) --matte finish
                            VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, 3, 154, 0)-- matte secondary
                            PED.SET_PED_SUFFERS_CRITICAL_HITS(attackerFlag, false)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 10, 0) --rear turret
                            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, 0, 154) --wheel color
                            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 4) --plate type, 4 is SA EXEMPT which law enforcement and government vehicles use
                            PED.SET_PED_COMBAT_ATTRIBUTES(attackerFlag, 3, false)
                            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                            if i == -1 then
                                TASK.TASK_VEHICLE_CHASE(attackerFlag, player_ped)
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 1000, false, true)
                            else
                                TASK.TASK_COMBAT_PED(attackerFlag, player_ped, 0, 16)
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 4208062921, 9999, false, true)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x8B3C480B)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x4DB62ABE)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x5DD5DBD5)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x9D65907A)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x420FD713)
                                PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                            end
                        end
                    end
                end
                if heliVehicle then
                    if not players.is_in_interior(pid) then
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local marine1 = util.joaat("s_m_y_marine_01")
                        local marine2 = util.joaat("s_m_y_marine_03")
                        request_model_load(hash)
                        request_model_load(marine1)
                        request_model_load(marine2)
                        local altitude = 75
                        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 15.0, altitude)
                        local vehicle = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(ped))
                        if not STREAMING.HAS_MODEL_LOADED(vehicle) then
                            LoadingModel(vehicle)
                        end
                        if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
                            return
                        end
                        local outCoords = v3.new()
                        for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do
                            local attackerFlag = entities.create_ped(2, marine1, outCoords, CAM.GET_GAMEPLAY_CAM_ROT(0).z)
                            PED.SET_PED_INTO_VEHICLE(attackerFlag, vehicle, i)
                            if i % 2 == 0 then
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                                PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                            else
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                                PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                            end
                            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                            PED.SET_PED_AS_COP(attackerFlag, true)
                            PED.SET_PED_CONFIG_FLAG(attackerFlag, 281, true)
                            PED.SET_PED_CONFIG_FLAG(attackerFlag, 2, true)
                            PED.SET_PED_CONFIG_FLAG(attackerFlag, 33, false)
                            PED.SET_PED_COMBAT_ATTRIBUTES(attackerFlag, 5, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(attackerFlag, 46, true)
                            PED.SET_PED_ACCURACY(attackerFlag, 100.0)
                            PED.SET_PED_HEARING_RANGE(attackerFlag, 99999)
                            PED.SET_PED_RANDOM_COMPONENT_VARIATION(attackerFlag, 0)
                            VEHICLE.CONTROL_LANDING_GEAR(vehicle, 3)
                            VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 120.0)
                            VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, 1000.0)
                            VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
                            VEHICLE.SET_VEHICLE_EXPLODES_ON_HIGH_EXPLOSION_DAMAGE(vehicle, false)
                            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(vehicle, 300)
                            PED.SET_PED_MAX_HEALTH(attackerFlag, 150)
                            ENTITY.SET_ENTITY_PROOFS(ped, false, true, false, false, true, false, false, false)
                            ENTITY.SET_ENTITY_HEALTH(attackerFlag, 150)
                            PED.SET_PED_ARMOUR(attackerFlag, 100)
                            PED.SET_PED_SHOOT_RATE(attackerFlag, 5)
                            VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
                            VEHICLE.SET_VEHICLE_COLOURS(vehicle, 154, 154)
                            VEHICLE.SET_VEHICLE_MOD_COLOR_1(vehicle, 3, 154, 0) --matte finish
                            VEHICLE.SET_VEHICLE_MOD_COLOR_2(vehicle, 3, 154, 0)-- matte secondary
                            PED.SET_PED_SUFFERS_CRITICAL_HITS(attackerFlag, false)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, 10, 0) --rear turret
                            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(vehicle, 0, 154) --wheel color
                            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 4) --plate type, 4 is SA EXEMPT which law enforcement and government vehicles use
                            PED.SET_PED_COMBAT_ATTRIBUTES(attackerFlag, 3, false)
                            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(HelisToggleGod))
                            if i == -1 then
                                TASK.TASK_VEHICLE_CHASE(attackerFlag, ped)
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 1000, false, true)
                            else
                                TASK.TASK_COMBAT_PED(attackerFlag, ped, 0, 16)
                                WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 4208062921, 9999, false, true)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x8B3C480B)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x4DB62ABE)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x5DD5DBD5)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x9D65907A)
                                WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(attackerFlag, 4208062921, 0x420FD713)
                                PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                            end
                        end
                    end
                end
            end

        ----========================================----
        ---              Player Roots
        ---    The part of specific player root
        ----========================================----

            PlayerMenu:action("Disclaimer", {}, "", function()
                InterNotify("Welcome to InterTools v"..SCRIPT_VERSION..", you are welcome and you know the principe, you are allowed to do anything in your laws. \n\nBe proud to be an american and destroy entire session. Take care about your own resposibility.")
            end)
            local InterTools = PlayerMenu:list("Inter Tools")
            local InfoPlayers = InterTools:list("Informations")
            local FriendlyOptions = InterTools:list("Friendly")
            local NeutralOptions = InterTools:list("Neutral")
            local TrollingOptions = InterTools:list("Trolling")

            InterSpec = {}
            InterTools:toggle("Spectate", {"interspec"}, "", function(on)
                if on then
                    if #InterSpec ~= 0 then
                        InterCmds("interspec"..InterSpec[1].." off")
                    end
                        table.insert(InterSpec, InterName)
                        InterCmds("spectate"..InterName.." on")
                        InterNotify("You are currently spectating "..InterName)
                    else
                        if players.exists(pid) then
                            InterCmds("spectate"..InterName.." off")
                            InterNotify("You are stopping spectating "..InterName)
                        end
                    table.remove(InterSpec, 1)
                end
            end)

            InterTools:action_slider("Kick Tools", {}, "Different types of Kick users:\n- AIO (All-in-One) - Faster kick\n- Blast\n- Boop\n- Array", {
                "AIO (All-in-One)", 
                "Blast", 
                "Boop", 
                "Array"
            }, function(kickType)
                if kickType == 1 then
                    local cmd = {"breakup", "kick", "confusionkick", "aids", "orgasmkick","nonhostkick", "pickupkick"}
                    for _, command in pairs(cmd) do
                        InterCmds(command..InterName)
                    end
                    InterNotify(InterName.." has been forced breakup.")
                elseif kickType == 2 then
                    InterCmds("historyblock " .. InterName)
                    InterCmds("breakup" .. InterName)
                elseif kickType == 3 then
                    InterCmds("breakup" .. InterName)
                    InterCmds("givesh" .. InterName)
                    util.trigger_script_event(1 << pid, {697566862, pid, 0x4, -1, 1, 1, 1}) --697566862 Give Collectible
                    util.trigger_script_event(1 << pid, {1268038438, pid, memory.script_global(2657589 + 1 + (pid * 466) + 321 + 8)}) 
                    util.trigger_script_event(1 << pid, {915462795, players.user(), memory.read_int(memory.script_global(0x1CE15F + 1 + (pid * 0x257) + 0x1FE))})
                    util.trigger_script_event(1 << pid, {697566862, pid, 0x4, -1, 1, 1, 1})
                    util.trigger_script_event(1 << pid, {1268038438, pid, memory.script_global(2657589 + 1 + (pid * 466) + 321 + 8)})
                    util.trigger_script_event(1 << pid, {915462795, players.user(), memory.read_int(memory.script_global(1894573 + 1 + (pid * 608) + 510))})
                else
                    local int_min = -2147483647
                    local int_max = 2147483647
                    for i = 1, 15 do
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1, math.random(int_min, int_max), math.random(int_min, int_max), 
                        math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max),
                        math.random(int_min, int_max), pid, math.random(int_min, int_max), math.random(int_min, int_max), math.random(int_min, int_max)})
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1})
                    end
                    InterCmds("givesh" .. InterName)
                    InterWait()
                    for i = 1, 15 do
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1, pid, math.random(int_min, int_max)})
                        util.trigger_script_event(1 << pid, {23546804, 20, 1, -1, -1, -1, -1})
                    end
                end
            end)

            InterTools:action_slider("Crash Tools", {}, "Different types of Crash Users:\n- AIO (All-in-One) - Faster Crash\n- Fragment\n- 5G Crash\n- Task Crash (AIO) - slower", {
                "AIO (All-in-One)", 
                "Fragment",
                "5G Crash",
                "Task Crash (AIO)"
            }, function(crashType)
                if crashType == 1 then
                    local cmd = {
                        "crash",
                        "choke",
                        "flashcrash",
                        "ngcrash",
                        "footlettuce",
                    }
                    for _, command in pairs(cmd) do
                        InterCmds(command..InterName)
                    end
                    InterNotify(InterName.." has been forced crashed.")
                elseif crashType == 2 then
                    if players.get_name(pid) == players.get_name(players.user()) then
                        InterNotify(lang.get_localised(-1974706693))
                    else
                        BlockSyncs(pid, function()
                            local object = entities.create_object(util.joaat("prop_fragtest_cnst_04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)))
                            OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
                            InterWait(1000)
                            entities.delete_by_handle(object)
                        end)
                    end
                elseif crashType == 3 then
                    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local allvehicles = entities.get_all_vehicles_as_handles()
                    for i = 1, 3 do
                        for i = 1, #allvehicles do
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 15, 1000)
                            InterWait()
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 16, 1000)
                            InterWait()
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 17, 1000)
                            InterWait()
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 18, 1000)
                            InterWait()
                        end
                    end
                else
                    BlockSyncs(pid, function()
                        local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_ENTITY_COORDS(p)
                        local chop = util.joaat('a_c_rabbit_01')
                        STREAMING.REQUEST_MODEL(chop)
                        while not STREAMING.HAS_MODEL_LOADED(chop) do
                            STREAMING.REQUEST_MODEL(chop)
                            InterWait()
                        end
                        local achop = entities.create_ped(26, chop, c, 0) 
                        WEAPON.GIVE_WEAPON_TO_PED(achop, util.joaat('weapon_grenade'), 9999, false, false)
                        WEAPON.SET_CURRENT_PED_WEAPON(achop, util.joaat('weapon_grenade'),true)
                        TASK.TASK_COMBAT_PED(achop , p, 0, 16)
                        setAttribute(achop)
                        TASK.TASK_THROW_PROJECTILE(achop,c.x, c.y, c.z)
                        local bchop = entities.create_ped(26, chop, c, 0) 
                        WEAPON.GIVE_WEAPON_TO_PED(bchop, util.joaat('weapon_grenade'), 9999, false, false)
                        WEAPON.SET_CURRENT_PED_WEAPON(bchop, util.joaat('weapon_grenade'),true)
                        TASK.TASK_COMBAT_PED(bchop , p, 0, 16)
                        setAttribute(bchop)
                        TASK.TASK_THROW_PROJECTILE(bchop,c.x, c.y, c.z)
                        InterWait(10000)
                        InterNotify("Crash done deleting peds")
                        entities.delete_by_handle(bchop)
                        entities.delete_by_handle(achop)
                        if not STREAMING.HAS_MODEL_LOADED(chop) then
                            InterNotify("Couldn't load the model")
                       end
                   end)

                   local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                   local pos = ENTITY.GET_ENTITY_COORDS(player, false)
                   local my_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
                   local my_ped = PLAYER.GET_PLAYER_PED(players.user())
                   pos.z = pos.z - 50
               
                    BlockSyncs(pid, function()
                        ENTITY.FREEZE_ENTITY_POSITION(my_ped, true)
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, pos.x, pos.y, pos.z, false, false, false)
                        InterWait()
                        local allvehicles = entities.get_all_vehicles_as_handles()
                        for i = 1, #allvehicles do
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 15, 1000)
                            InterWait()
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 16, 1000)
                            InterWait()
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 17, 1000)
                            InterWait()
                            TASK.TASK_VEHICLE_TEMP_ACTION(player, allvehicles[i], 18, 1000)
                        end
                        InterWait()
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, my_pos.x, my_pos.y, my_pos.z, false, false, false)
                        ENTITY.FREEZE_ENTITY_POSITION(my_ped, false)
                    end)

                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = players.get_position(pid)
                    local mdl = util.joaat("mp_m_freemode_01")
                    local veh_mdl = util.joaat("t20")
                    util.request_model(veh_mdl)
                    util.request_model(mdl)
                            BlockSyncs(pid, function()
                        for i = 1, 10 do
                            if not players.exists(pid) then
                                return
                            end
                            local veh = entities.create_vehicle(veh_mdl, pos, 0)
                            local jesus = entities.create_ped(2, mdl, pos, 0)
                            PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                            InterWait(100)
                            TASK.TASK_PLANE_LAND(jesus, veh, ped, 10.0, 0, 10, 0, 0,0)  --A2
                            InterWait(1000)
                            entities.delete_by_handle(jesus)
                            entities.delete_by_handle(veh)
                        end
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
                    end)

                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = players.get_position(pid)
                    local mdl = util.joaat("mp_m_freemode_01")
                    local veh_mdl = util.joaat("zentorno")
                    util.request_model(veh_mdl)
                    util.request_model(mdl)
                        BlockSyncs(pid, function()
                        for i = 1, 10 do
                            if not players.exists(pid) then
                                return
                            end
                            local veh = entities.create_vehicle(veh_mdl, pos, 0)
                      
                            local jesus = entities.create_ped(2, mdl, pos, 0)
                            PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                            InterWait(100)
                            TASK.TASK_VEHICLE_HELI_PROTECT(jesus, veh, ped, 10.0, 0, 10, 0, 0)
                                     
                            InterWait(1000)
                            entities.delete_by_handle(jesus)
                            entities.delete_by_handle(veh)
                        end
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
                    end)

                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = players.get_position(pid)
                    local mdl = util.joaat("mp_m_freemode_01")
                    local veh_mdl = util.joaat("adder")
                    util.request_model(veh_mdl)
                    util.request_model(mdl)
                        BlockSyncs(pid, function()
                        for i = 1, 10 do
                            if not players.exists(pid) then
                                return
                            end
                            local veh = entities.create_vehicle(veh_mdl, pos, 0)
                            local jesus = entities.create_ped(2, mdl, pos, 0)
                            PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                            InterWait(100)
                            TASK.TASK_SUBMARINE_GOTO_AND_STOP(1, veh, pos.x, pos.y, pos.z, 1)
                            InterWait(1000)
                            entities.delete_by_handle(jesus)
                            entities.delete_by_handle(veh)
                        end
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
                    end)
                end
            end)

        ----========================================----
        ---           Information Players
        ---  The part of specific player root infos
        ----========================================----

            local Controller = players.is_using_controller(pid) and "Confirmed" or "Unconfirmed" InterWait()
            local ModderDetect = players.is_marked_as_modder(pid) and "Confirmed" or "Unconfirmed" InterWait()
            local GodModeDetect = players.is_godmode(pid) and "Confirmed" or "Unconfirmed" InterWait()
            local DetectVPN = players.is_using_vpn(pid) and "Confirmed" or "Unconfirmed" InterWait()
            local OffRadar = players.is_otr(pid) and "Confirmed" or "Unconfirmed" InterWait()
            local Interior = players.is_in_interior(pid) and "Interior" or "Exterior" InterWait()

            local languageList = {
                "English",
                "French",
                "German",
                "Italian",
                "Spanish",
                "Portuguese",
                "Polish",
                "Russian",
                "Korean",
                "Chinese Traditional",
                "Japanese",
                "Mexican",
                "Chinese Simplified"
            }
            local languageIndex = players.get_language(pid)
            if languageIndex >= 0 and languageIndex <= 12 then
                local tokenTypes = {
                    ["FFFF"] = "Handicap", -- handicap mode
                    ["0000"] = "Aggressive", -- aggressive mode
                }
                for i=16,37 do
                    local hex = string.format("%04X", i)
                    tokenTypes[hex] = "Sweet Spot" -- value between 0010 & 0025
                end

                local spoofToken = players.get_host_token_hex(pid)
                local spoofType = tokenTypes[string.sub(spoofToken, 1, 4)] or "Unconfirmed"
                local playerInfos = {
                    {label = "Name", value = InterName},
                    {label = "Language", value = languageList[languageIndex + 1]},
                }

                local sessionInfos = {
                    {label = "Modder", value = ModderDetect},
                    {label = "Host Token", value = spoofType},
                    {label = "Godmode Status", value = tostring(GodModeDetect)},
                    {label = "Off the Radar", value = OffRadar},
                    {label = "Interior Status", value = Interior},
                }

                local otherInfos = {
                    {label = "Controller Usage", value = Controller},
                    {label = "VPN Usage", value = DetectVPN},
                }

                InfoPlayers:divider("Player Infos")
                for i, info in ipairs(playerInfos) do
                    InfoPlayers:readonly(info.label, info.value)
                end

                InfoPlayers:divider("Last Session Infos")
                for i, info in ipairs(sessionInfos) do
                    InfoPlayers:readonly(info.label, info.value)
                end

                InfoPlayers:divider("Others")
                for i, info in ipairs(otherInfos) do
                    InfoPlayers:readonly(info.label, info.value)
                end
            end

        ----========================================----
        ---           Friendly Options
        ---  The part of specific player friendlier
        ----========================================----

            local VehicleFriendly = FriendlyOptions:list("Vehicles")

            FriendlyOptions:action("Give Minigun", {}, "", function()
                local modelHash = util.joaat("W_MG_Minigun")
                local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 0.0, 0.0)
                local pickupHash = 792114228
                Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 100)
        
                modelHash = util.joaat("prop_ld_ammo_pack_02")
                pickupHash = 4065984953
                Create_Network_Pickup(pickupHash, coords.x, coords.y, coords.z, modelHash, 9999)
            end)

            FriendlyOptions:toggle_loop("Infinite Ammo", {"intinfp"}, "Gives infinite ammo constantly", function()
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local weaphash = WEAPON.GET_SELECTED_PED_WEAPON(ped)
                local ammo = WEAPON.GET_AMMO_IN_PED_WEAPON(ped, weaphash)
                if ammo < 9999 then
                    WEAPON.ADD_AMMO_TO_PED(ped, weaphash, 9999)
                end
            end)

        ----========================================----
        ---           Vehicle Options
        ---  The part of specific player friendly
        ----========================================----

            VehicleFriendly:action("Spawn Vehicle", {"intvspawn"}, "", function()
                local text = display_onscreen_keyboard()
                if text == nil or text == "" then return end
                local hash = util.joaat(text)
                local function platechanger(vehicle)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(PlateIndexPER))
                    if PersonalPlate == nil then
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, RandomPlate())
                    else
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, PersonalPlate)
                    end
                end
                local function upgradecar(vehicle)
                    if menu.get_value(ToggleUpgradePerso) == true then
                        for i = 0,49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    else
                        VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                    end
                end
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                if not STREAMING.HAS_MODEL_LOADED(hash) then
                    LoadingModel(hash)
                end
                if STREAMING.IS_MODEL_A_VEHICLE(hash) then
                    local vehicle = entities.create_vehicle(hash, c, 0)
                    if menu.get_value(ToggleRandomPaintPER) == true then
                        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    end
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(ToggleGMPerso))
                    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, menu.get_value(WindowTintPER))
                    platechanger(vehicle)
                    upgradecar(vehicle)
                    RequestControlOfEntity(vehicle)
                    InterNotify("You have spawned: "..text.. " for " ..InterName)
                else
                    InterNotify("The model named: "..text.." is not recognized, please retry later.")
                end
            end)
    
            VehicleFriendly:action("Repair Vehicle", {}, "", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_FIXED(playerVehicle)
                end
            end)

            VehicleFriendly:action("Give Godmode Vehicle", {}, "Detected by most mod menus if you give someone godmode vehicle.", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    ENTITY.SET_ENTITY_INVINCIBLE(playerVehicle, true)
                end
            end)

            VehicleFriendly:action_slider("Vehicle Upgrade", {}, "", {"Upgrade", "Downgrade"}, function(upgradeSelc)
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                if upgradeSelc == 1 then
                    if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                        for i = 0,49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(playerVehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(playerVehicle, i, num - 1, true)
                        end
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, RandomPlate())
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(playerVehicle, 5)
                    else
                        InterNotify("I'm sorry, "..InterName.." is not in a vehicle.")
                    end
                else
                    if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                        VEHICLE.SET_VEHICLE_MOD(playerVehicle, 0, 0 - 1, false)
                        VEHICLE.SET_VEHICLE_MOD_KIT(playerVehicle, 0)
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(playerVehicle, math.random(0, 4))
                    end
                end
            end)

            VehicleFriendly:action("Random Paint", {}, "", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(playerVehicle, 0, math.random(0, 255), math.random(0, 255))
                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(playerVehicle, 0, math.random(0, 255), math.random(0, 255))
                    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(playerVehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                end
            end)

            VehicleFriendly:text_input("Change Plate Name", {"intcplate"}, "Apply Plate Name if the player is in a vehicle.", function(name)
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if name ~= "" then
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, name)
                    else
                        name = nil
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, RandomPlate())
                    end
                end
            end)

            ----===============================================================================================================================================================----

            VehicleFriendly:divider("Vehicle Tweaks Summon")
            VehicleFriendly:text_input("Plate Name", {"intpplate"}, "Apply Plate Name when summoning vehicles.\nYou are not allowed to write more than 8 characters.", function(name)
                if name ~= "" then
                    PersonalPlate = name:sub(1, 8)
                else
                    PersonalPlate = nil
                end
            end)
            ToggleGMPerso = VehicleFriendly:toggle_loop("Toggle Invincible Vehicle", {}, "", function()end)
            ToggleUpgradePerso = VehicleFriendly:toggle_loop("Toggle Upgrade Cars", {}, "", function()end)
            ToggleRandomPaintPER = VehicleFriendly:toggle_loop("Toggle Random Paint", {}, "", function()end)
            WindowTintPER = VehicleFriendly:slider("Window Tint", {"intpwt"}, "Choose Window tint Color.", 0, 6, 0, 1, function()end)
            PlateIndexPER = VehicleFriendly:slider("Plate Color", {"intpplc"}, "Choose Plate Color.", 0, 5, 0, 1, function()end)

        ----========================================----
        ---           Neutral Options
        ---  The part of specific player neutral
        ----========================================----

            NeutralOptions:action("Detection Language", {"intlang"}, "", function()
                if AvailableSession() then
                    local languageList = {       
                        "English",
                        "French",
                        "German",
                        "Italian",
                        "Spanish",
                        "Portuguese",
                        "Polish",
                        "Russian",
                        "Korean",
                        "Chinese Traditional",
                        "Japanese",
                        "Mexican",
                        "Chinese Simplified"
                    }
                    local languageIndex = players.get_language(pid)
                    if languageIndex >= 0 and languageIndex <= 12 then
                        InterNotify(InterName .. " is " .. languageList[languageIndex + 1]..".")
                    end
                end
            end)

            local godmodeMessageDisplayed = false
            NeutralOptions:action("Godmode Detection", {"intdgod"}, "", function()
                if players.is_godmode(pid) then
                    if players.is_in_interior(pid) then
                        if not godmodeMessageDisplayed then
                            InterNotify(InterName.." is in Godmode.".."\n".."But "..InterName.." is in interior.")
                            godmodeMessageDisplayed = true
                        end
                    else
                        if not godmodeMessageDisplayed then
                            InterNotify(InterName.." is in Godmode.")
                            godmodeMessageDisplayed = true
                        end
                        godmodeMessageDisplayed = false
                    end
                else
                    InterNotify(InterName.." is not in Godmode.")
                    godmodeMessageDisplayed = false
                end
            end)

            NeutralOptions:action("Flag Host Token", {"intflagtoken"}, "Detect if "..InterName.." uses spoof host token.\nAble to detect token like:\n- Aggressive\n- Handicap\n- Sweet Spot", function()
                local tokenTypes = {
                    ["FFFF"] = "Handicap",
                    ["0000"] = "Aggressive",
                }
                for i=16,37 do
                    local hex = string.format("%04X", i)
                    tokenTypes[hex] = "Sweet Spot"
                end
                local spoofToken = players.get_host_token_hex(pid)
                local spoofType = tokenTypes[string.sub(spoofToken, 1, 4)] or "Unconfirmed"
                InterNotify(InterName.." is".." "..(spoofType ~= "Unconfirmed" and "using "..spoofType.." " or "not using Spoof Host Token."))
            end)

        ----========================================----
        ---           Trolling Options
        ---  The part of specific player troll
        ----========================================----

            local spawned_objects = {}
            local AttackParts = TrollingOptions:list("Attack Parts")
            local BountyParts = TrollingOptions:list("Bounty Parts")
            local ExplosionPlayer = TrollingOptions:list("Explosions Parts")
            local TGodPresets = TrollingOptions:list("Godmode Settings")
            local SoundTrolling = TrollingOptions:list("Sound Trolling")

        ----========================================----
        ---      Troll Options (Attack Parts)
        ---     The part of specific player troll 
        ----========================================----

            AttackParts:divider("Real Attack (Air Force)")
            PlaneToggleGodP = AttackParts:toggle_loop("Toggle Godmode Plane", {}, "Toggle (Enable/Disable) Godmode Planes while using ground vehicles.", function()end)
            local planeModelsP = {
                ["Lazer"] = util.joaat("lazer"),
                ["Hydra"] = util.joaat("hydra"),
                ["V-65 Molotok"] = util.joaat("molotok"),
                ["Western Rogue"] = util.joaat("rogue"),
                ["Pyro"] = util.joaat("pyro"),
                ["P-45 Nokota"] = util.joaat("nokota"),
            }
            
            local planeModelNamesP = {}
            for name, _ in pairs(planeModelsP) do
                table.insert(planeModelNamesP, name)
            end

            table.sort(planeModelNamesP, function(a, b) return a[1] < b[1] end)

            local selectedPlaneModelP = "Hydra"
            local planesHashP = planeModelsP[selectedPlaneModelP]
            AttackParts:list_select("Types of Planes", {"interpplanes"}, "The entities that will add while sending air force planes.", planeModelNamesP, 1, function(index)
                selectedPlaneModelP = planeModelNamesP[index]
                planesHashP = planeModelsP[selectedPlaneModelP]
            end)

            AttackParts:action("Send Planes", {}, "Attack the player with any means.".."\n".."Harass quick "..InterName.." with some reason.", function()
                harass_specific_vehicle(planesHashP, true, false, false)
            end)

            ----------------------------------------------------------------------

            AttackParts:divider("Real Attack (Ground)")
            TankToggleGodP = AttackParts:toggle_loop("Toggle Godmode Vehicle", {}, "Toggle (Enable/Disable) Godmode Armored Vehicles while using ground vehicles.",  function()end)

            local armoredModelP = {
                ["Rhino Tank"] = "rhino",
                ["Half-Track"] = "halftrack",
                ["TM-02 Khanjali"] = "khanjali",
                ["Nightshark"] = "nightshark",
                ["Barrage"] = "barrage",
                ["APC"] = "apc",
                ["Insurgent Pick-Up Custom"] = "insurgent3",
                ["Turreted Limo"] = "limo2",
                ["Weaponized Tampa"] = "tampa3",
                ["Menacer"] = "menacer",
                ["Armored Boxville"] = "boxville5",
                ["Insurgent Pick-Up"] = "insurgent2",
            }
            
            local tankModelNameP = {}
            for name, _ in pairs(armoredModelP) do
                table.insert(tankModelNameP, name)
            end
            table.sort(tankModelNameP)
            local selectedTankArmoredP = "APC"
            local tankHashesP = armoredModelP[selectedTankArmoredP]
            AttackParts:list_select("Types of Armored Vehicles", {"interparmored"}, "The entities that will add while sending army armored.", tankModelNameP, 1, function(index)
                selectedTankArmoredP = tankModelNameP[index]
                tankHashesP = armoredModelP[selectedTankArmoredP]
            end)

            AttackParts:action("Send Armored Vehicle", {}, "Attack the player with any means.".."\n".."Harass quick "..InterName.." with some reason.", function()
                harass_specific_vehicle(tankHashesP, false, true, false)
            end)

            ----------------------------------------------------------------------
            
            AttackParts:divider("Real Attack (Helicopter)")
            local helisModelsP = {
                ["Annihilator"] = util.joaat("annihilator"),
                ["Cargobob"] = util.joaat("cargobob"),
                ["Annihilator Stealth"] = util.joaat("annihilator2"),
                ["Buzzard Attack Chopper"] = util.joaat("buzzard"),
                ["Savage"] = util.joaat("savage"),
                ["Valkyrie"] = util.joaat("valkyrie"),
                ["FH-1 Hunter"] = util.joaat("hunter"),
                ["RF-1 Akula"] = util.joaat("akula"),
            }
            
            local heliModelPName = {}
            for name, _ in pairs(helisModelsP) do
                table.insert(heliModelPName, name)
            end
    
            table.sort(heliModelPName, function(a, b) return a[1] < b[1] end)
            
            local selectedHeliNameModelP = "Annihilator"
            local heliHashP = helisModelsP[selectedHeliNameModelP]
            
            AttackParts:list_select("Types of Choppers", {"interphelis"}, "The entities that will add while sending air force helicopters.", heliModelPName, 1, function(index)
                selectedHeliNameModelP = heliModelPName[index]
                heliHashP = helisModelsP[selectedHeliNameModelP]
            end)

            AttackParts:action("Send Armored Chopper", {}, "Attack the player with any means.".."\n".."Harass quick "..InterName.." with some reason.", function()
                harass_specific_vehicle(heliHashP, false, false, true)
            end)

        ----========================================----
        ---      Troll Options (bounty options)
        ---     The part of specific player troll 
        ----========================================----

            BountyPValue = BountyParts:slider("Select Amount Bounty",  {'interpbounty'}, "Select which amount it will automatically placed.",  0, 10000, 0, 1, function()end)
            BountyParts:toggle_loop("Auto-Bounty", {'interpautobounty'}, "Alright, let's start a new war for "..InterName..", you will be happy to see that.\nNOTE: Toggle Exclude features.",function()
                if AvailableSession() and players.get_bounty(pid) ~= menu.get_value(BountyPValue) then
                    InterCmds("bounty"..players.get_name(pid).." "..menu.get_value(BountyPValue))
                end
                InterWait(500)
            end)

            BountyParts:action_slider("Bounty Type", {}, "Alright, let's start a new war for "..InterName..", you will be happy to see that.\nNOTE: Toggle Exclude features.\n- Manual Bounty means you have set up \"Select Amount Bounty\".\n\n- Random Bounty means you distribute the bounty differently. It will be independent from \"Select Amount Bounty\".", {"Manual", "Random"}, function(bountySelect)
                if bountySelect == 1 then
                    if AvailableSession() and players.get_bounty(pid) ~= menu.get_value(BountyPValue) then
                        InterCmds("bounty"..players.get_name(pid).." "..menu.get_value(BountyPValue))
                    end
                    InterWait(50)
                else
                    if AvailableSession() then
                        local playerBounty = math.random(1, 10000)
                        InterCmds("bounty " .. players.get_name(pid) .. " " .. playerBounty)
                    end
                    InterWait(50)
                end
            end)

        ----========================================----
        ---      Troll Options (remove godmode)
        ---     The part of specific player troll 
        ----========================================----

            TGodPresets:toggle_loop("Remove Player Godmode", {"removegod"}, "Removes the player's godmode. Works only if the players has not a good paid menu.", function ()
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                util.trigger_script_event(1 << pid, {801199324, pid, 869796886})
                PLAYER.SET_PLAYER_INVINCIBLE(playerPed, false)
            end)

            TGodPresets:toggle_loop("Remove Vehicle Godmode", {"removegodveh"}, "Remove the players while using godmode.", function()
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and not PED.IS_PED_DEAD_OR_DYING(ped) then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
                end
            end)

        ----========================================----
        ---           Continue Options Troll
        ---    The part of specific player troll 
        ----========================================----

            TrollingOptions:toggle_loop("Camera Moving", {'intercam'}, "",function()
                if AvailableSession() then
                    if InterName then
                        CameraMoving(pid, 99999)
                    end
                end
            end)

            DisableLock = TrollingOptions:toggle_loop("Lock Vehicle", {}, "", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerVehicle, 4)
                else
                    menu.set_value(DisableLock, false)
                end
            end, function()
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true), 0)
            end)

            TrollingOptions:action_slider("Vehicle Remove", {}, "Choose any solution by any means how to remove.\n- Explode\n- Remove", {"Explode", "Remove"}, function(elimSelect)
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if elimSelect == 1 then
                    if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                        ENTITY.SET_ENTITY_INVINCIBLE(playerVehicle, false) -- add condition if the player is using godmode car
                        local pos = players.get_position(pid)
                        pos.z = pos.z - 1.0
                        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                    end
                else
                    if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                        ENTITY.SET_ENTITY_INVINCIBLE(playerVehicle, false) -- add condition if the player is using godmode car
                        entities.delete_by_handle(playerVehicle)
                    end
                end
            end)

            TrollingOptions:action_slider("Elimination Type", {}, "Different types of elimination:\n- Airstrike\n- Orbital Shot (Non-Personal)\n- Orbital Shot (Reveal)\n- Silent Shot\n- Passive Shot", {"Airstrike", "Orbital Shot (Non-Personal)", "Orbital Shot (Reveal)", "Silent Shot", "Passive Shot"}, function(killselect)
                if killselect == 1 then
                    local pidPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local abovePed = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, 0, 0, 8)
                    local missileCount = RandomGenerator(16, 24)
                    for i = 1, missileCount do
                        local missileOffset = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(abovePed.x, abovePed.y, abovePed.z, missileOffset.x, missileOffset.y, missileOffset.z, 100, true, 1752584910, 0, true, false, 250)
                    end
                elseif killselect == 2 then
                    local pos = players.get_position(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    pos.z = pos.z - 1.0
                    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 59, 1, true, false, 9.9, false)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                        InterWait(0)
                    end
                    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
                    AUDIO.PLAY_SOUND_FROM_COORD(1, "DLC_XM_Explosions_Orbital_Cannon", pos.x, pos.y, pos.z, 0, true, 0, false)
                    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", pos.x, pos.y, pos.z + 1, 0, 180, 0, 1.0, true, true, true)
                    for i = 1, 5 do
                        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", ped, 0, true, false)
                    end
                elseif killselect == 3 then
                    local pos = players.get_position(pid)
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    OwnedOrbitalCannon(true)
                    pos.z = pos.z - 1.0
                    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                    FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 59, 1, true, false, 9.9, false)
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                        InterWait(0)
                    end
                    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
                    AUDIO.PLAY_SOUND_FROM_COORD(1, "DLC_XM_Explosions_Orbital_Cannon", pos.x, pos.y, pos.z, 0, true, 0, false)
                    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", pos.x, pos.y, pos.z + 1, 0, 180, 0, 1.0, true, true, true)
                    for i = 1, 5 do
                        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", ped, 0, true, false)
                    end

                    InterWait(1000)
                    OwnedOrbitalCannon(false)
                elseif killselect == 4 then
                    KillSilent(pid)
                else
                    KillPassive(pid)
                end
            end)

            local cages =  {"Normal Cage", "Electric Cage", "Container Box", "Coffin", "Cargo Plane", "Cargobob"}
            TrollingOptions:action_slider("Cage Player", {""}, "Different types of cage player:\n- Normal Cage\n- Electric Cage\n- Container Box\n- Coffin\n- Cargo Plane\n- Cargobob", cages, function(cageselect)
                if cageselect == 1 then
                    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    if not PED.IS_PED_IN_ANY_VEHICLE(player_ped) then
                        local modelHash = util.joaat("prop_gold_cont_01")
                        local pos = ENTITY.GET_ENTITY_COORDS(player_ped)
                        local obj = Create_Network_Object(modelHash, pos.x, pos.y, pos.z)
                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    end
                elseif cageselect == 2 then
                    SpawnObjects = {}
                    get_vtable_entry_pointer = function(address, index)
                        return memory.read_long(memory.read_long(address) + (8 * index))
                    end
                    local FTotalCage = 6
                    local FElectricBox = util.joaat("prop_elecbox_12")
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = ENTITY.GET_ENTITY_COORDS(ped)
                    pos.z = pos.z - 0.5
                    SendRequestEntity(FElectricBox)
                    local temp_v3 = v3.new(0, 0, 0)
                    for i = 1, FTotalCage do
                        local angle = (i / FTotalCage) * 360
                        temp_v3.z = angle
                        local obj_pos = temp_v3:toDir()
                        obj_pos:mul(2.5)
                        obj_pos:add(pos)
                        for offs_z = 1, 5 do
                            local ElecCages = entities.create_object(FElectricBox, obj_pos)
                            SpawnObjects[#SpawnObjects + 1] = ElecCages
                            ENTITY.SET_ENTITY_ROTATION(ElecCages, 90.0, 0.0, angle, 2, 0)
                            obj_pos.z = obj_pos.z + 0.75
                            ENTITY.FREEZE_ENTITY_POSITION(ElecCages, true)
                        end
                    end
                elseif cageselect == 3 then
                    SpawnObjects = {}
                    get_vtable_entry_pointer = function(address, index)
                        return memory.read_long(memory.read_long(address) + (8 * index))
                    end
                    local ContainerBox = util.joaat("prop_container_ld_pu")
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = ENTITY.GET_ENTITY_COORDS(ped)
                    SendRequestEntity(ContainerBox)
                    pos.z = pos.z - 1
                    local Container = entities.create_object(ContainerBox, pos, 0)
                    SpawnObjects[#SpawnObjects + 1] = container
                    ENTITY.FREEZE_ENTITY_POSITION(Container, true)
                    WEAPON.REMOVE_ALL_PED_WEAPONS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                    InterCmds("disarm"..InterName)
                elseif cageselect == 4 then
                    local number_of_cages = 6
                    local coffin_hash = util.joaat("prop_coffin_02b")
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = ENTITY.GET_ENTITY_COORDS(ped)
                    RequestModel(coffin_hash)
                    local temp_v3 = v3.new(0, 0, 0)
                    for i = 1, number_of_cages do
                        local angle = (i / number_of_cages) * 360
                        temp_v3.z = angle
                        local obj_pos = temp_v3:toDir()
                        obj_pos:mul(0.8)
                        obj_pos:add(pos)
                        obj_pos.z += 0.1
                    local coffin = entities.create_object(coffin_hash, obj_pos)
                    spawned_objects[#spawned_objects + 1] = coffin
                    ENTITY.SET_ENTITY_ROTATION(coffin, 90.0, 0.0, angle,  2, 0)
                    ENTITY.FREEZE_ENTITY_POSITION(coffin, true)
                    end
                elseif cageselect == 5 then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 0.0)
                    local hash = util.joaat("cargoplane")
                    request_model_load(hash)
                    local cargo = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(ped))
                    ENTITY.FREEZE_ENTITY_POSITION(cargo, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(cargo, coords.x, coords.y, coords.z-0.1, true, false, false)
                    ENTITY.SET_ENTITY_INVINCIBLE(cargo, true)
                    for i = 1, 5 do
                        VEHICLE.SET_VEHICLE_DOOR_LATCHED(cargo, i, true, true, true)
                    end
                else
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, 0.0)
                    local hash = util.joaat("cargobob2")
                    request_model_load(hash)
                    local cargobob = entities.create_vehicle(hash, coords, ENTITY.GET_ENTITY_HEADING(ped))
                    ENTITY.FREEZE_ENTITY_POSITION(cargobob, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(cargobob, coords.x, coords.y, coords.z + 0.5, true, false, false)
                    ENTITY.SET_ENTITY_INVINCIBLE(cargobob, true)
                    for i = 1, 5 do
                        VEHICLE.SET_VEHICLE_DOOR_LATCHED(cargobob, i, true, true, true)
                    end
                end
            end)

            local InterSpam = 88
            local TablesEntities = {"Kosatka", "Cargo Plane", "Boeing 911", "B-1B Lancer", "Rhino Tank"}
            TrollingOptions:action_slider("Spam Entities", {}, "Spam every each entities of your choice".."\n- Kosatka\n- Cargo Plane\n- Boeing 911\n- B-1B Lancer\n- Rhino Tank", TablesEntities, function(spamType)
                if spamType == 1 then
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_kosatka(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                        local hash = util.joaat("kosatka")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        while InterSpam >= 1 do
                            entities.create_vehicle(hash, c, 0)
                            InterSpam = InterSpam - 1
                            InterWait(10)
                        end
                        local kosatka = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        upgrade_vehicle(kosatka)
                    end
                    give_kosatka(pid)
                    InterWait()
                elseif spamType == 2 then
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_cargoplane(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                        local hash = util.joaat("cargoplane")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        while InterSpam >= 1 do
                            entities.create_vehicle(hash, c, 0)
                            InterSpam = InterSpam - 1
                            InterWait(10)
                        end
                        local cargoplane = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        upgrade_vehicle(cargoplane)
                    end
                    give_cargoplane(pid)
                    InterWait()
                elseif spamType == 3 then
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_boeing(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                        local hash = util.joaat("jet")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        while InterSpam >= 1 do
                            entities.create_vehicle(hash, c, 0)
                            InterSpam = InterSpam - 1
                            InterWait(10)
                        end
                        local boeing = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        upgrade_vehicle(boeing)
                    end
                    give_boeing(pid)
                    InterWait()
                elseif spamType == 4 then
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_lancer(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                        local hash = util.joaat("alkonost")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        while InterSpam >= 1 do
                            entities.create_vehicle(hash, c, 0)
                            InterSpam = InterSpam - 1
                            InterWait(10)
                        end
                        local lancer = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        upgrade_vehicle(lancer)
                    end
                    give_lancer(pid)
                    InterWait()
                else
                    local function upgrade_vehicle(vehicle)
                        for i = 0, 49 do
                            local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                            VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                        end
                    end
                    local function give_leopard(pid)
                        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                        local hash = util.joaat("rhino")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        while InterSpam >= 1 do
                            entities.create_vehicle(hash, c, 0)
                            InterSpam = InterSpam - 1
                            InterWait(10)
                        end
                        local leopard = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(ped))
                        upgrade_vehicle(leopard)
                    end
                    give_leopard(pid)
                    InterWait()
                end
            end)

            TrollingOptions:action_slider("Send Plane", {}, "Call the Plane to send "..InterName.." to die.\n\nBOEING IS THE FASTEST PLANE EVER THAN SHITTY PLANES.", {"Boeing 747","F-16 Falcon","Antonov AN-225"}, function(select)
                if select == 1 then
                    local function summon_entity_face(entity, targetplayer, inclination)
                        local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
                        local pos2 = ENTITY.GET_ENTITY_COORDS(targetplayer, false)
                        local rel = v3.new(pos2)
                        rel:sub(pos1)
                        local rot = rel:toRot()
                        if not inclination then
                            ENTITY.SET_ENTITY_HEADING(entity, rot.z)
                        else
                            ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
                        end
                    end

                    local function GiveSPlane(pid)
                        local targetID = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetID, 0.0, 0, 200.0)
                        local hash = util.joaat("jet")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        local boeing = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(targetID))
                        ENTITY.SET_ENTITY_INVINCIBLE(boeing, false)
                        summon_entity_face(boeing, targetID, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(boeing, 1000.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(boeing, 1000.0)
                        VEHICLE.CONTROL_LANDING_GEAR(boeing, 3)
                    end
                    if AvailableSession() then
                        if InterName then
                            GiveSPlane(pid)
                        end
                    end
                elseif select == 2 then
                    local function summon_entity_face(entity, targetplayer, inclination)
                        local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
                        local pos2 = ENTITY.GET_ENTITY_COORDS(targetplayer, false)
                        local rel = v3.new(pos2)
                        rel:sub(pos1)
                        local rot = rel:toRot()
                        if not inclination then
                            ENTITY.SET_ENTITY_HEADING(entity, rot.z)
                        else
                            ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
                        end
                    end

                    local function GiveSPlane(pid)
                        local targetID = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetID, 0.0, 40, 125.0)
                        local hash = util.joaat("lazer")
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                        local lazersuicide = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(targetID))
                        ENTITY.SET_ENTITY_INVINCIBLE(lazersuicide, false)
                        summon_entity_face(lazersuicide, targetID, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(lazersuicide, 540.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(lazersuicide, 540.0)
                        VEHICLE.CONTROL_LANDING_GEAR(lazersuicide, 3)
                    end
                    if AvailableSession() then
                        if InterName then
                            GiveSPlane(pid)
                            InterWait()
                        end
                    end
                else
                    local function summon_entity_face(entity, targetplayer, inclination)
                        local pos1 = ENTITY.GET_ENTITY_COORDS(entity, false)
                        local pos2 = ENTITY.GET_ENTITY_COORDS(targetplayer, false)
                        local rel = v3.new(pos2)
                        rel:sub(pos1)
                        local rot = rel:toRot()
                        if not inclination then
                            ENTITY.SET_ENTITY_HEADING(entity, rot.z)
                        else
                            ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, false)
                        end
                    end

                    local function GiveSPlane(pid)
                        local targetID = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetID, 0.0, 0, 200.0)
                    
                        local hash = util.joaat("cargoplane")
                    
                        if not STREAMING.HAS_MODEL_LOADED(hash) then
                            LoadingModel(hash)
                        end
                    
                        local cargoplane = entities.create_vehicle(hash, c, ENTITY.GET_ENTITY_HEADING(targetID))
                        ENTITY.SET_ENTITY_INVINCIBLE(cargoplane, false)
                        summon_entity_face(cargoplane, targetID, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(cargoplane, 1000.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(cargoplane, 1000.0)
                        VEHICLE.CONTROL_LANDING_GEAR(cargoplane, 3)
                    end
                    if AvailableSession() then
                        if InterName then
                            GiveSPlane(pid)
                            InterWait()
                        end
                    end
                end
            end)

            TrollingOptions:action("Ragdoll", {}, "", function()
                local coords = players.get_position(pid)
                coords.z = coords.z - 2.0
                FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 11, 1, false, true, 0, true)
                InterWait(10)
            end)

            TrollingOptions:toggle_loop("Ragdoll Loop", {}, "", function()
                local coords = players.get_position(pid)
                coords.z = coords.z - 2.0
                FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 11, 1, false, true, 0, true)
            end)

            TrollingOptions:toggle_loop("Hostile Traffic NPCs", {}, "", function()
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                for _, vehicle in getRangeOfVehicle(pid, 70.0) do
                    if TASK.GET_ACTIVE_VEHICLE_MISSION_TYPE(vehicle) ~= 6 then
                        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1, false)
                        if ENTITY.DOES_ENTITY_EXIST(driver) and not PED.IS_PED_A_PLAYER(driver) then
                            driverRequest(driver)
                            PED.SET_PED_MAX_HEALTH(driver, 300)
                            ENTITY.SET_ENTITY_HEALTH(driver, 300, 0)
                            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(driver, true)
                            TASK.TASK_VEHICLE_MISSION_PED_TARGET(driver, vehicle, ped, 6, 100.0, 0, 0.0, 0.0, true)
                        end
                    end
                end
            end)

            TrollingOptions:toggle_loop("Loop Fire", {}, "", function()
                local coords = players.get_position(pid)
                coords.z = coords['z'] - 2.0
                FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 12, 1, true, false, 0, false)
                InterWait(25)
            end)

            TrollingOptions:action("Russian Roulette", {"interproulette"}, "Play Russian Roulette\nProbability: Survived or Died", function()
                local rand = math.random(6)
                if players.is_godmode(pid) then
                    InterNotify("Sorry, "..InterName.." can't play Russian Roulette.\nMake sure "..InterName.." is not using godmode to play.")
                else
                    if rand == 1 then
                        local pos = players.get_position(pid)
                        pos.z = pos.z - 1.0
                        for i = 0, 50 do
                            FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 7, 1000, false, true, 0)
                        end
                        InterNotify(InterName.." is dead.")
                    else
                        InterNotify(InterName.." has survived this round of Russian Roulette.")
                    end
                end
            end)

        ----========================================----
        ---            Explosion Type
        ---   The part of players parts, useful but
        ---   we have more solution to burn player
        ----========================================----

            local typeExplosion = 0
            ExplosionPlayer:divider("Explosions")
            ExplosionPlayer:list_select("Explosion Type", {"interpexplosiontype"}, "", explosion_types, 0, function(value)
                typeExplosion = value
            end)
            ExpShakeInten = ExplosionPlayer:slider("Explosion Shake", {"interpreshake"}, "Choose shake explosion intensity [0 - 10]", 0, 10, 1, 1, function()end)
            ExplosionPlayer:action_slider("Elimination Type", {}, "Different types of elimination:".."\n- Anonymous\n- Owned\n- Randomize", {"Anonymous", "Owned", "Randomize"}, function(elimType)
                if elimType == 1 then
                    local pos = players.get_position(pid)
                    pos.z = pos.z - 1.0
                    for i = 0, 5 do
                        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, typeExplosion, 1, true, false, menu.get_value(ExpShakeInten), false)
                    end
                elseif elimType == 2 then
                    local pos = players.get_position(pid)
                    pos.z = pos.z - 1.0
                    for i = 0, 5 do
                        FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, typeExplosion, 1, true, false, menu.get_value(ExpShakeInten), false)
                    end
                else
                    if not PLAYER.IS_PLAYER_DEAD(pid) then
                        if AvailableSession() and not players.is_in_interior(pid) and not players.is_godmode(pid) then
                            local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                            local pos = players.get_position(pid)
                            pos.z = pos.z - 1.0
                            local randomPlayerIndex = math.random(#playerList)
                            local randomPlayerId = playerList[randomPlayerIndex]
                            local randomPlayerName = players.get_name(randomPlayerId)
                            local RandomPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(randomPlayerId)
                            if randomPlayerId ~= pid then
                                InterNotify("Random player killer: "..randomPlayerName.."\nVictim target: "..InterName)
                            else
                                InterNotify(InterName.." eliminated themselves.")
                            end
                            for i = 0, 5 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, typeExplosion, 1, true, false, menu.get_value(ExpShakeInten), false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, typeExplosion, 1, true, false, menu.get_value(ExpShakeInten), false)
                            end
                        end
                    end
                end
            end)

            ExplosionPlayer:divider("Owned & Explode Loop")

            ExplosionPlayer:toggle_loop("Loop Explode", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, typeExplosion, 1, true, false, menu.get_value(ExpShakeInten), false)
            end)

            ExplosionPlayer:toggle_loop("Loop Owned Explode", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, typeExplosion, 1, true, false, menu.get_value(ExpShakeInten), false)
            end)

        ----========================================----
        ---            Sound Trolls Type
        ---   The part of players parts, useful but
        ---   we have more solution to break sounds
        ----========================================----

            SoundVolume = SoundTrolling:slider("Sound Volume", {"intvolumep"}, "", 0, 100, 0, 1, function()end)
            SoundTrolling:action("Stop Sounds", {}, "", function() for i = 0, 100 do AUDIO.STOP_SOUND(i) end end)
            SoundTrolling:divider("Single Usage Sounds")
            SoundTrolling:action("Boat Horn", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                for i = 0, menu.get_value(SoundVolume) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Horn", pos.x, pos.y, pos.z, "DLC_Apt_Yacht_Ambient_Soundset", true, 9999, false)
                end
            end)

            SoundTrolling:action("Walkie Talkie", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                for i = 0, menu.get_value(SoundVolume) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Start_Squelch", pos.x, pos.y, pos.z, "CB_RADIO_SFX", true, 9999, false)
                end
            end)

            SoundTrolling:action("Ukraine Air Defense", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                for i = 0, menu.get_value(SoundVolume) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Air_Defences_Activated", pos.x, pos.y, pos.z, "DLC_sum20_Business_Battle_AC_Sounds", true, 9999, false)
                end
            end)

            SoundTrolling:divider("Loop Sounds")

            SoundTrolling:toggle_loop("Loop Boat Horn", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                for i = 0, menu.get_value(SoundVolume) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Horn", pos.x, pos.y, pos.z, "DLC_Apt_Yacht_Ambient_Soundset", true, 9999, false)
                end
            end)

            SoundTrolling:toggle_loop("Loop Walkie Talkie", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                for i = 0, menu.get_value(SoundVolume) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Start_Squelch", pos.x, pos.y, pos.z, "CB_RADIO_SFX", true, 9999, false)
                end
            end)

            SoundTrolling:toggle_loop("Loop Ukraine Air Defense", {}, "", function()
                local pos = players.get_position(pid)
                pos.z = pos.z - 1.0
                for i = 0, menu.get_value(SoundVolume) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, "Air_Defences_Activated", pos.x, pos.y, pos.z, "DLC_sum20_Business_Battle_AC_Sounds", true, 9999, false)
                end
            end)
        end)

    players.dispatch_on_join()
    players.on_leave(function()end)

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--