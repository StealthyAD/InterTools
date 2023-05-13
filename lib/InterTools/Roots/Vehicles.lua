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

    Part: Vehicles
]]--

    ---========================================----
    ---              Vehicle Roots
    ---         The part of vehicle roots
    ----========================================----

        local VehicleParts = InterRoot:list("Vehicles Parts", {"intveh"})
        local Countermeasures = VehicleParts:list("Countermeasures")
        local DetectionRadar = VehicleParts:list("Detection Tools")
        local VehicleSpawnParts = VehicleParts:list("Spawn Tweaks")
        local TeslaParts = VehicleParts:list("Tesla Tools")
        local VehicleSettings = VehicleParts:list("Vehicle Settings")
        local TrophyADS = Countermeasures:list("Trophy ADS")

    ----========================================----
    ---              Vehicle Parts
    ---         The part of vehicle parts
    ----========================================----

        InterWarthog = VehicleParts:toggle_loop("GAU-8 Avenger Warthog", {}, "Only Works on the B-11. Makes the Cannon like how it is in Real Life, you could make BRRRTTT.\n\nNOTE: It will disable when you are not in B-11 Strikeforce.", function()
            local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            if ENTITY.GET_ENTITY_MODEL(player_veh) == util.joaat("strikeforce") then
                local A10_while_using = entities.get_user_vehicle_as_handle()
                local CanPos = ENTITY.GET_ENTITY_BONE_POSTION(A10_while_using, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(A10_while_using, "weapon_1a"))
                local target = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(A10_while_using, 0, 175, 0)
                if PAD.IS_CONTROL_PRESSED(114, 114) then
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(CanPos['x'], CanPos['y'], CanPos['z'], target['x']+math.random(-1,1), target['y']+math.random(-1,1), target['z']+math.random(-1,1), 100.0, true, 3800181289, players.user_ped(), true, false, 100.0)
                end
            else
                InterNotify("You have to be in a B-11 Strikeforce to use the feature.")
                InterCmd(InterWarthog, "off")
            end
        end)

        VehicleParts:text_input("Plate Name", {"intplatecar"}, "Apply Plate Name if the player is in a vehicle.", function(name)
            local player = players.user_ped()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                if name ~= "" then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, name)
                else
                    name = nil
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, RandomPlate())
                end
            end
        end)

        local seat_id = -1
        local moved_seat = VehicleParts:click_slider("Change Seat", {""}, "Switch seats by using the Slider. 1 is the Driver.", 1, 1, 1, 1, function(seat_id)
            TASK.TASK_WARP_PED_INTO_VEHICLE(players.user_ped(), entities.get_user_vehicle_as_handle(), seat_id - 2)
        end)
    
        menu.on_tick_in_viewport(moved_seat, function()
            if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                moved_seat.max_value = 0
            return end
            moved_seat.max_value = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()))
        end)

        VehicleParts:toggle_loop("Boost Heli Engine", {}, "Enable the feature will make helicopter faster than 1 second\nDisable the feature will able to stop engine and continue.", function()
            if entities.get_user_vehicle_as_handle() ~= 0 then
                VEHICLE.SET_HELI_BLADES_FULL_SPEED(entities.get_user_vehicle_as_handle())
            else
                VEHICLE.SET_HELI_BLADES_SPEED(entities.get_user_vehicle_as_handle(), 0)
            end
        end)

        VehicleParts:toggle_loop("Lock Vehicle", {}, "", function()
            local player = players.user_ped()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerVehicle, 4)
            end
        end, function()
            VEHICLE.SET_VEHICLE_DOORS_LOCKED(PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true), 0)
        end)

        VehicleParts:toggle_loop("Immersive Radio", {}, "Toggle immersive radio for First Person view vs 3rd person view while slightly reduced radio", function()
            AUDIO.SET_FRONTEND_RADIO_ACTIVE(CAM.GET_CAM_VIEW_MODE_FOR_CONTEXT(1) == 4)
        end, function()
            AUDIO.SET_FRONTEND_RADIO_ACTIVE(true)
        end)
        VehicleParts:toggle_loop("Toggle Bypass Depth Submarine", {""}, "", function()
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
            local tables = {
                "submersible",
                "submersible2",
                "kosatka",
                "toreador",
                "stromberg",
                "avisa"
            }
            for _, model in pairs(tables) do
                local hash = util.joaat(model)
                if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                    VEHICLE.SET_SUBMARINE_CRUSH_DEPTHS(vehicle, false, 2000, 2000, 2000)
                end
            end
        end)

        VehicleParts:toggle_loop("Quick Start Engine", {}, "Reduce time for start engine car and drive quick in 1 seconds.", function()
            if PED.IS_PED_GETTING_INTO_A_VEHICLE(PLAYER.PLAYER_PED_ID()) then
                local veh = PED.GET_VEHICLE_PED_IS_ENTERING(PLAYER.PLAYER_PED_ID())
                if veh ~= 0 then
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, true)
                end
            end
        end)

        VehicleParts:toggle_loop("Toggle Engine", {""}, "Toggle (Disable/Enable) engine.", function()
            local player = players.user_ped()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                VEHICLE.SET_VEHICLE_ENGINE_ON(playerVehicle, false, true, true)
            end
        end,function()
            VEHICLE.SET_VEHICLE_ENGINE_ON(PED.GET_VEHICLE_PED_IS_IN(player, true), true, true, false)
        end)
        
        VehicleParts:slider("Opacity Vehicle", {"intveht"}, "", 0, 100, 100, 20, function(value)
            if value > 80 then
                ENTITY.RESET_ENTITY_ALPHA(entities.get_user_vehicle_as_handle())
            else
                ENTITY.SET_ENTITY_ALPHA(entities.get_user_vehicle_as_handle(), value * 2.55, false)
            end
        end)

        VehicleParts:action("Leave Vehicle", {}, "", function()
            if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
            end
        end)

    ----========================================----
    ---              Tesla Parts
    ---         The part of Elon Musk parts
    ----========================================----
        
        TeslaParts:toggle("Tesla Mode", {}, "", function(toggle)
            local ped = players.user_ped()
            local playerpos = ENTITY.GET_ENTITY_COORDS(ped, false)
            local pos = ENTITY.GET_ENTITY_COORDS(ped)
            local tesla_ai = util.joaat("u_m_y_baygor")
            local tesla = util.joaat("raiden")
            RequestModel(tesla_ai)
            RequestModel(tesla)
            if toggle then     
               if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    menu.trigger_commands("deletevehicle")
                end
                tesla_ai_ped = entities.create_ped(26, tesla_ai, playerpos, 0)
                tesla_vehicle = entities.create_vehicle(tesla, playerpos, 0)
                ENTITY.SET_ENTITY_INVINCIBLE(tesla_ai_ped, menu.get_value(TeslaToggleGod)) 
                ENTITY.SET_ENTITY_VISIBLE(tesla_ai_ped, false)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ai_ped, true)
                PED.SET_PED_INTO_VEHICLE(ped, tesla_vehicle, -2)
                PED.SET_PED_INTO_VEHICLE(tesla_ai_ped, tesla_vehicle, -1)
                PED.SET_PED_KEEP_TASK(tesla_ai_ped, true)
                VEHICLE.SET_VEHICLE_COLOURS(tesla_vehicle, 111, 111)

                if menu.get_value(TeslaToggleUpgrade) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(tesla_vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, i, num - 1, true)
                    end
                else
                    VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 0, 0 - 1, true)
                end
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(tesla_vehicle, menu.get_value(TeslaPlateIndex))
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(tesla_vehicle, 111, 147)
                if TeslaPlate == nil then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(tesla_vehicle, RandomPlate())
                else
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(tesla_vehicle, TeslaPlate)
                end
                VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, menu.get_value(TeslaWindowTint))
        
                if HUD.IS_WAYPOINT_ACTIVE() then
                    local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ai_ped, tesla_vehicle, pos.x, pos.y, pos.z, 20.0, 786603, 0)
                else
                    TASK.TASK_VEHICLE_DRIVE_WANDER(tesla_ai_ped, tesla_vehicle, 20.0, 786603)
                end
            else
                if tesla_ai_ped ~= nil then 
                    entities.delete_by_handle(tesla_ai_ped)
                end
                if tesla_vehicle ~= nil then 
                    entities.delete_by_handle(tesla_vehicle)
                end
            end
        end)

        TeslaToggleGod = TeslaParts:toggle_loop("Toggle Invincible Vehicle", {}, "", function() end)
        TeslaToggleUpgrade = TeslaParts:toggle_loop("Toggle Upgrade Cars", {}, "", function()end)
        TeslaPlateIndex = TeslaParts:slider("Plate Color", {"inttplc"}, "Choose Plate Color.", 0, 5, 0, 1, function()end)
        TeslaWindowTint = TeslaParts:slider("Window Tint", {"inttwt"}, "Choose Window tint Color.", 0, 6, 0, 1, function()end)
        TeslaParts:text_input("Plate Name", {"inttplate"}, "Apply Plate Name when summoning vehicles.\nYou are not allowed to write more than 8 characters.", function(name)
            if name ~= "" then
                TeslaPlate = name:sub(1, 8)
            else
                TeslaPlate = nil
            end
        end)

   ----========================================----
   ---              Vehicle Parts
   ---         The part of active vehicle
   ----========================================----

        local VehicleWCompart = {
            {"All" },
            {"Left front window"}, -- 0
            {"Right front window"}, -- 1
            {"Left rear window"}, -- 2
            {"Right rear window "}, -- 3
            {"Front windshield window"}, -- 4
            {"Rear windshield window"} -- 5
        }
        local WindowsTParts = 1 
        VehicleSettings:list_select("Select Part Windows", {}, "", VehicleWCompart, 1, function(value)
            WindowsTParts = value
        end)

        VehicleSettings:toggle_loop("Toggle Windows (Open/Close)", {}, "", function()
            local vehicle = entities.get_user_vehicle_as_handle()
            if vehicle ~= 0 then
                if WindowsTParts == 1 then
                    for i = 0, 7 do
                        VEHICLE.ROLL_DOWN_WINDOW(vehicle, i)
                    end
                elseif WindowsTParts > 1 then
                    VEHICLE.ROLL_DOWN_WINDOW(vehicle, WindowsTParts - 2)
                end
            end
        end, function()
            local vehicle = entities.get_user_vehicle_as_handle()
            if vehicle ~= 0 then
                if WindowsTParts == 1 then
                    for i = 0, 7 do
                        VEHICLE.ROLL_UP_WINDOW(vehicle, i)
                    end
                elseif WindowsTParts > 1 then
                    VEHICLE.ROLL_UP_WINDOW(vehicle, WindowsTParts - 2)
                end
            end
        end)

        VehicleSettings:action("Repair Windows", {}, "", function()
            local vehicle = entities.get_user_vehicle_as_handle()
            if vehicle ~= 0 then
                if WindowsTParts == 1 then
                    for i = 0, 7 do
                        VEHICLE.FIX_VEHICLE_WINDOW(vehicle, i)
                    end
                elseif WindowsTParts > 1 then
                    VEHICLE.FIX_VEHICLE_WINDOW(vehicle, WindowsTParts - 2)
                end
            end
        end)

        VehicleSettings:action("Break Windows", {}, "", function()
            local vehicle = entities.get_user_vehicle_as_handle()
            if vehicle ~= 0 then
                if WindowsTParts == 1 then
                    for i = 0, 7 do
                        VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, i)
                    end
                elseif WindowsTParts > 1 then
                    VEHICLE.SMASH_VEHICLE_WINDOW(vehicle, WindowsTParts - 2)
                end
            end
        end)

        local DustCar = 0.0
        VehicleSettings:click_slider("Dust Car Vehicle", {}, "Applies Dust Car Vehicle.", 0.0, 15.0, 0.0, 1.0, function(value)
            DustCar = value
            local vehicle = entities.get_user_vehicle_as_handle()
            if vehicle ~= 0 then
                VEHICLE.SET_VEHICLE_DIRT_LEVEL(vehicle, DustCar)
            end
        end)

    ----========================================----
    ---           Spawning Tweaks Parts
    ---         The part of vehicle parts
    ----========================================----

        VehicleSpawnParts:list_action("Preset Cars", {}, "", vehicleData, function(index)
            local hash = util.joaat(vehicleData[index])
            local ped = PLAYER.GET_PLAYER_PED()
            if not STREAMING.HAS_MODEL_LOADED(hash) then
                LoadingModel(hash)
            end
            local function upgrade_vehicle(vehicle)
                if menu.get_value(SelfTUpgrade) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                else
                    VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                end
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(SelfPlateNameIndex))

                if menu.get_value(VehicleRandomPaint) == true then
                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                end

                if SelfPlateName == nil then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, RandomPlate())
                else
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, SelfPlateName)
                end
            end
            local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 6.5, -1.0)
            local veh = entities.create_vehicle(hash, c, CAM.GET_FINAL_RENDERED_CAM_ROT(2).z)
            upgrade_vehicle(veh)
            ENTITY.SET_ENTITY_INVINCIBLE(veh, menu.get_value(SelfToggleGod))
            VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, menu.get_value(SelfWindowT))
            RequestControlOfEntity(veh)
            local InvincibleStatus = menu.get_value(SelfToggleGod) and "Active" or "Inactive"
            local UpgradedCar = menu.get_value(SelfTUpgrade) and "Active" or "Inactive"
            local PaintStatus = menu.get_value(VehicleRandomPaint) and "Active" or "Inactive"
            if SelfPlateName == nil then
                InterNotify("You have spawned: "..vehicleData[index].. " for yourself with the parameters: \n- Plate Name: "..RandomPlate().."\n- Plate Color: "..menu.get_value(SelfPlateNameIndex).."\n- Window Tint: "..menu.get_value(SelfWindowT).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar.."\n- Random Paint: "..PaintStatus)
            else
                InterNotify("You have spawned: "..vehicleData[index].. " for yourself with the parameters: \n- Plate Name: "..SelfPlateName.."\n- Plate Color: "..menu.get_value(SelfPlateNameIndex).."\n- Window Tint: "..menu.get_value(SelfWindowT).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar.."\n- Random Paint: "..PaintStatus)
            end
        end)

        VehicleSpawnParts:action("Spawn Vehicle", {"intspawn"}, "", function()
            local text = display_onscreen_keyboard()
            if text == nil or text == "" then return end
            local hash = util.joaat(text)
            local ped = PLAYER.GET_PLAYER_PED()
            if not STREAMING.HAS_MODEL_LOADED(hash) then
                LoadingModel(hash)
            end
            local function upgrade_vehicle(vehicle)
                if menu.get_value(SelfTUpgrade) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                else
                    VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                end
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(SelfPlateNameIndex))

                if menu.get_value(VehicleRandomPaint) == true then
                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                end

                if SelfPlateName == nil then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, RandomPlate())
                else
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, SelfPlateName)
                end
            end
            if STREAMING.IS_MODEL_A_VEHICLE(hash) then
                local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 6.5, -1.0)
                local veh = entities.create_vehicle(hash, c, CAM.GET_FINAL_RENDERED_CAM_ROT(2).z)
                upgrade_vehicle(veh)
                ENTITY.SET_ENTITY_INVINCIBLE(veh, menu.get_value(SelfToggleGod))
                VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, menu.get_value(SelfWindowT))
                RequestControlOfEntity(veh)
                local InvincibleStatus = menu.get_value(SelfToggleGod) and "Active" or "Inactive"
                local UpgradedCar = menu.get_value(SelfTUpgrade) and "Active" or "Inactive"
                local PaintStatus = menu.get_value(VehicleRandomPaint) and "Active" or "Inactive"
                if SelfPlateName == nil then
                    InterNotify("You have spawned: "..text.. " for yourself with the parameters: \n- Plate Name: "..RandomPlate().."\n- Plate Color: "..menu.get_value(SelfPlateNameIndex).."\n- Window Tint: "..menu.get_value(SelfWindowT).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar.."\n- Random Paint: "..PaintStatus)
                else
                    InterNotify("You have spawned: "..text.. " for yourself with the parameters: \n- Plate Name: "..SelfPlateName.."\n- Plate Color: "..menu.get_value(SelfPlateNameIndex).."\n- Window Tint: "..menu.get_value(SelfWindowT).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar.."\n- Random Paint: "..PaintStatus)
                end
            else
                InterNotify("The model named: "..text.." is not recognized, please retry later.")
            end
        end)

        VehicleSpawnParts:text_input("Plate Name", {"intplate"}, "Apply Plate Name when summoning vehicles.\nYou are not allowed to write more than 8 characters.", function(name)
            if name ~= "" then
                SelfPlateName = name:sub(1, 8)
            else
                SelfPlateName = nil
            end                    
        end)

        SelfToggleGod = VehicleSpawnParts:toggle_loop("Toggle Invincible Vehicle", {}, "", function() end)
        SelfTUpgrade = VehicleSpawnParts:toggle_loop("Toggle Upgrade Cars", {}, "", function()end)
        VehicleRandomPaint = VehicleSpawnParts:toggle_loop("Toggle Random Paint", {}, "", function()end)
        SelfPlateNameIndex = VehicleSpawnParts:slider("Plate Color", {"intplc"}, "Choose Plate Color.", 0, 5, 0, 1, function()end)
        SelfWindowT = VehicleSpawnParts:slider("Window Tint", {"intwt"}, "Choose Window tint Color.", 0, 6, 0, 1, function()end)

    ----========================================----
    ---           Countermeasures Parts
    ---     The part of countermeasures parts
    ----========================================----

        Countermeasures:toggle_loop("Toggle Flares", {"intertogflare"}, "Spawns Flares Behind the Vehicle. Don't spam E button or flare will not appear correctly, entites contains +20 flares.\n\nNOTE: Each 15 seconds running out, it will disable preventing false fire shot flares.", function()
            if PAD.IS_CONTROL_PRESSED(46, 46) then
                local ped = PLAYER.PLAYER_PED_ID()
                if PED.IS_PED_IN_ANY_PLANE(ped) then
                    local targetP = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -2, -2.0, 0)
                    local targetFG = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -3, -25.0, 0)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP['x'], targetP['y'], targetP['z'], targetFG['x'], targetFG['y'], targetFG['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                    local targetP1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 2, -2.0, 0)
                    local targetFG1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 3, -25.0, 0)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP1['x'], targetP1['y'], targetP1['z'], targetFG1['x'], targetFG1['y'], targetFG1['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                    util.yield(300)

                    local targetP2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -4, -2.0, 0)
                    local targetFG2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -10, -20.0, -1)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP2['x'], targetP2['y'], targetP2['z'], targetFG2['x'], targetFG2['y'], targetFG2['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                    local targetP3 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 4, -2.0, 0)
                    local targetFG3 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 10, -20.0, -1)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP3['x'], targetP3['y'], targetP3['z'], targetFG3['x'], targetFG3['y'], targetFG3['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                    util.yield(300)

                    for i = 0, 4, 2 do
                        local targetP4 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -4, -2.0, 0)
                        local target2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -10, -15.0, -1)
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP4['x'], targetP4['y'], targetP4['z'], target2['x'], target2['y'], target2['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                        local targetP5 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 4, -2.0, 0)
                        local target3 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 10, -15.0, -1)
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP5['x'], targetP5['y'], targetP5['z'], target3['x'], target3['y'], target3['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                        util.yield(300)
                    end

                    for i = 0, 6, 2 do
                        local targetP6 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -4, -2.0, 0)
                        local target4 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), -10, -10.0, -1)
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP6['x'], targetP6['y'], targetP6['z'], target4['x'], target4['y'], target4['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                        local targetP7 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 4, -2.0, 0)
                        local targetG = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 10, -10.0, -1)
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(targetP7['x'], targetP7['y'], targetP7['z'], targetG['x'], targetG['y'], targetG['z'], 100.0, true, 1198879012, players.user_ped(), true, false, 25.0)
                        util.yield(300)
                    end

                    InterNotify("Flares is ready to reload.\nEstimated time: 15 seconds.\nNOTE: Disabling and re-enable 'Toggle Flares' will not become efficient.")
                    util.yield(15000)
                    InterNotify("Flares is ready to start.")
                end
            end
        end)

    ----========================================----
    ---              Detection Tools
    ---     The part of stealth radar parts
    ----========================================----    

        local NoLockRadar = nil
        local StealthRadar = nil
        DetectionRadar:toggle_loop("Stealth Radar High Altitude", {}, "Only works for plane.\nEnable/Disable OTR when the aircraft reaches a certain altitude.", function()
            StealthRadar = menu.ref_by_path("Online>Off The Radar")
            NoLockRadar = menu.ref_by_path("Vehicle>Can't Be Locked On")
            local altitude = 1050 -- Cruise Altitude
            local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            local ped = PLAYER.PLAYER_PED_ID()
            if PED.IS_PED_IN_ANY_PLANE(ped) and ENTITY.GET_ENTITY_MODEL(player_veh) then
                local plane = PED.GET_VEHICLE_PED_IS_USING(ped)
                if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(plane) > altitude then
                    HUD.TOGGLE_STEALTH_RADAR(true)
                    menu.trigger_command(StealthRadar, "on")
                    menu.trigger_command(NoLockRadar, "on")
                else
                    HUD.TOGGLE_STEALTH_RADAR(false)
                    menu.trigger_command(StealthRadar, "off")
                    menu.trigger_command(NoLockRadar, "off")
                end
            end
            end, function()
            if StealthRadar ~= nil and NoLockRadar ~= nil then
                HUD.TOGGLE_STEALTH_RADAR(false)
                menu.trigger_command(StealthRadar, "off")
                menu.trigger_command(NoLockRadar, "off")
            end
        end)

        DetectionRadar:toggle_loop("Stealth Radar Optimal Altitude", {}, "Only works for plane.\nEnable/Disable OTR when the aircraft reaches a certain altitude.", function()
            StealthRadar = menu.ref_by_path("Online>Off The Radar")
            NoLockRadar = menu.ref_by_path("Vehicle>Can't Be Locked On")
            local highaltitude = 1550 -- High altitude while leaving the stealth zone
            local lowAltitude = 50 -- Low Altitude might be detected
            local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            local ped = PLAYER.PLAYER_PED_ID()
            if PED.IS_PED_IN_ANY_PLANE(ped) and ENTITY.GET_ENTITY_MODEL(player_veh) then
                local plane = PED.GET_VEHICLE_PED_IS_USING(ped)
                if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(plane) <= highaltitude and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(plane) >= lowAltitude then
                    HUD.TOGGLE_STEALTH_RADAR(true)
                    menu.trigger_command(StealthRadar, "on")
                    menu.trigger_command(NoLockRadar, "on")
                else
                    HUD.TOGGLE_STEALTH_RADAR(false)
                    menu.trigger_command(StealthRadar, "off")
                    menu.trigger_command(NoLockRadar, "off")
                end
            end
            end, function()
            if StealthRadar ~= nil and NoLockRadar ~= nil then
                HUD.TOGGLE_STEALTH_RADAR(false)
                menu.trigger_command(StealthRadar, "off")
                menu.trigger_command(NoLockRadar, "off")
            end
        end)

        local LowestRadar = nil
        DetectionRadar:toggle_loop("Stealth Radar Low Altitude", {}, "Only works for plane and helicopters.\nEnable/Disable OTR when the aircraft/helicopters reaches a certain altitude.", function()
            LowestRadar = menu.ref_by_path("Online>Off The Radar")
            NoLockRadar = menu.ref_by_path("Vehicle>Can't Be Locked On")
            local altitude = 75 -- Lowest altitude which can be undetected.
            local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            local ped = PLAYER.PLAYER_PED_ID()
            if PED.IS_PED_IN_ANY_PLANE(ped) or PED.IS_PED_IN_ANY_HELI(ped) and ENTITY.GET_ENTITY_MODEL(player_veh) then
                local plane = PED.GET_VEHICLE_PED_IS_USING(ped)
                if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(plane) < altitude then
                    HUD.TOGGLE_STEALTH_RADAR(true)
                    menu.trigger_command(LowestRadar, "on")
                    menu.trigger_command(NoLockRadar, "on")
                else
                    HUD.TOGGLE_STEALTH_RADAR(false)
                    menu.trigger_command(LowestRadar, "off")
                    menu.trigger_command(NoLockRadar, "off")
                end
            end
            end, function()
            if StealthRadar ~= nil and NoLockRadar ~= nil then
                HUD.TOGGLE_STEALTH_RADAR(false)
                menu.trigger_command(LowestRadar, "off")
                menu.trigger_command(NoLockRadar, "off")
            end
        end)

        DetectionRadar:toggle_loop("Car Stealth Radar", {}, "Only works for ground vehicles.", function()
            OTR = menu.ref_by_path("Online>Off The Radar")
            local altitude = 5 -- Allow only ground vehicles which can able to fly
            local altitudeBike = 75 -- Allow only ground bikes (Oppressor1/MK2 and others bikes) vehicles which can able to fly
            local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
            local ped = PLAYER.PLAYER_PED_ID()
            if PED.IS_PED_ON_ANY_BIKE(ped) and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(PED.GET_VEHICLE_PED_IS_USING(ped)) < altitudeBike then 
                HUD.TOGGLE_STEALTH_RADAR(true)
                menu.trigger_command(OTR, "on")
            elseif PED.IS_PED_IN_ANY_VEHICLE(ped, false) and not PED.IS_PED_IN_ANY_HELI(ped) and not PED.IS_PED_IN_ANY_PLANE(ped) and ENTITY.GET_ENTITY_MODEL(player_veh) then
                if ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(PED.GET_VEHICLE_PED_IS_USING(ped)) < altitude then -- Disable while using Deluxo or Scramjet or every else
                    HUD.TOGGLE_STEALTH_RADAR(true)
                    menu.trigger_command(OTR, "on")
                else
                    HUD.TOGGLE_STEALTH_RADAR(false)
                    menu.trigger_command(OTR, "off")
                end
            else
                HUD.TOGGLE_STEALTH_RADAR(false)
                menu.trigger_command(OTR, "off")
            end
        end, function()
            if OTR ~= nil then
                HUD.TOGGLE_STEALTH_RADAR(false)
                menu.trigger_command(OTR, "off")
            end
        end)

    ----========================================----
    ---              Trophy ADS Parts
    ---     The part of countermeasures parts
    ----========================================----        

        TrophyADS:toggle("Trophy ADS", {"inttaps"}, "APS (Active Protection System), is a System that will Defend your Vehicle from Missles by Shooting them out of the Sky before they Hit you.\nBefore the machine works, you need to change the range slightly to have better efficient machine.", function(on)
            IntAPS_charges = InterTAPSCharges
            InterTAPSVehicle = on
            mod_uses("object", if on then 1 else -1)
        end)
        
        InterTAPSRange = 10
        TrophyADS:slider("APS Range", {"inttapsrange"}, "The Range at which APS will Destroy Incoming Projectiles.", 15, 100, 15, 5, function(value)
            InterTAPSRange = value
        end)
        
        InterTAPSCharges = 8
        TrophyADS:slider("APS Charges", {"inttapscharge"}, "Set the Amount of Charges / Projectiles the APS can Destroy before having to Reload.", 1, 100, 8, 1, function(value)
            InterTAPSCharges = value
        end)
        
        InterTAPSTimeout = 8000
        TrophyADS:slider("APS Reload Time", {"inttapsrt"}, "Set the Time, in Seconds, for how Long it takes the APS to Reload after Depleting all of its Charges. This is not after every Shot, just the Reload after EVERY Charge has been used.", 1, 100, 8, 1, function(value)
            local MultipliedTime = value * 1000
            InterTAPSTimeout = MultipliedTime
        end)

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--