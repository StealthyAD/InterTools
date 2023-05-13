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

    Part: World
]]--

        local SND_ASYNC<const> = 0x0001
        local SND_FILENAME<const> = 0x00020000
        
    ----========================================----
    ---              World Roots
    ---         The part of world parts
    ----========================================----

        local WorldParts = InterRoot:list("World Settings", {"intworld"})
        local ClearingParts = WorldParts:list("Clearing Parts")
        local ClearingPartSpec = ClearingParts:list("Specific Clearing Parts")
        local PanicParts = WorldParts:list("Panic Parts")
        local WorldChanges = WorldParts:list("Riot/Peds & World Changes")
        local TwinTowersParts = WorldParts:list("Twin Towers")
        local TeleportParts = WorldParts:list("Teleports Parts")
        local WeatherFeatures = WorldParts:list("Weather & Time Features")

   ----===============================================----
   ---                World Parts
   ---    The part of worlds parts, useful or useless
   ----===============================================----

       local plateTables = {
           "ADOLF", 
           "HITLER", 
           "WAFFENSS",
           "14",
           "88",
           "HIMMLER", 
           "GOEBBELS",
           "REICH",
           "NIGGER",
           "DICKLAND",
           "39 45",
           "1939",
           "1945",
           "DASREICH"
       } 

       local currentPlate = plateTables[math.random(#plateTables)]

       GColors = WorldParts:toggle_loop("Made in Germany", {}, "Pray for Austrian Painter", function()
           if menu.get_value(RainColors) then
               menu.set_value(RainColors, false)
           end
           for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
               for i = 0,49 do
                   local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                   VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                   VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, 2)
                   VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 5)
               end
               VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 188, 0, 0)
               VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 188, 0, 0)
               VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, currentPlate)
           end
       end,function()
           menu.set_value(RainColors, false)
       end)

       RainColors = WorldParts:toggle_loop("Rainbow Cars", {}, "", function()
           if menu.get_value(GColors) then
               menu.set_value(GColors, false)
           end
           local primary_color = 0
           local secondary_color = 0
       
           for k, veh in pairs(entities.get_all_vehicles_as_handles()) do
               NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
               VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, primary_color, math.random(0, 255), math.random(0, 255))
               VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, secondary_color, math.random(0, 255), math.random(0, 255))
               VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
               DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", math.random(0, 50))
               VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, math.random(17, 22), true)
               VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, math.random(0, 49))
               VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, math.random(0, 6))
               VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, math.random(0, 5))
               VEHICLE.SET_VEHICLE_MOD(veh, math.random(0, 49))
               VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 2)
               VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 5)
               VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, RandomPlate())
       
               primary_color = primary_color + 10
               if primary_color > 255 then
                   primary_color = 0
                   secondary_color = secondary_color + 10
                   if secondary_color > 255 then
                       secondary_color = 0
                   end
               end
           end
       end,function()
           menu.set_value(GColors, false)
       end)

       WorldParts:toggle_loop("More Traffic City", {}, "", function()
           local repopulate_timer = os.time() + 2.5
           if os.time() > repopulate_timer then
               InstantlyFillVehiclePopulation()
               repopulate_timer = os.time() + 2.5
           end
       end)

       local disable_peds = true
       local disable_traffic = true

       WorldParts:toggle("Remove Traffic", {}, "", function(toggle)
           local pop_multiplier_id
           if toggle then
               local ped_sphere, traffic_sphere
               if disable_peds then ped_sphere = 0.0 else ped_sphere = 1.0 end
               if disable_traffic then traffic_sphere = 0.0 else traffic_sphere = 1.0 end
               pop_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0, ped_sphere, traffic_sphere, false, true)
               MISC.CLEAR_AREA(1.1, 1.1, 1.1, 30000.0, true, false, false, true)
           else
               MISC.REMOVE_POP_MULTIPLIER_SPHERE(pop_multiplier_id, false);
           end
       end)

       WorldParts:action("Blow up nearby vehicles", {}, "It will guaranteed burning all vehicles Specific Personal Vehicles.\n\nNOTE: It will affect players while driving and can burn, die easily.", function()
           for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
               if vehicle ~= entities.get_user_personal_vehicle_as_handle() then
                   RequestControl(vehicle)
                   VEHICLE.EXPLODE_VEHICLE_IN_CUTSCENE(vehicle)
               end
           end
       end)

       WorldParts:action("Teleport to a high altitude", {"intertphigh"}, "Teleports you and your vehicle to a high altitude.", function()
           local ped = players.user_ped()
           local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
           local coords
           if PED.IS_PED_IN_VEHICLE(ped, playerVehicle, false) then
                if playerVehicle ~= 0 then 
                    coords = ENTITY.GET_ENTITY_COORDS(playerVehicle)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(playerVehicle, coords.x, coords.y, 2000.0, false, false, false)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, coords.x, coords.y, 2000.0, false, false, false)
                    TASK.TASK_ENTER_VEHICLE(ped, playerVehicle, 1, -1, 1.0, 1, 0)
                end
            else
                coords = ENTITY.GET_ENTITY_COORDS(ped)
                coords.z = 2000.0
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, coords.x, coords.y, coords.z, false, false, false)
            end
       end)

    ----===============================================----
    ---              World Parts (BOEING)
    ---    The part of worlds parts, useful or useless
    ----===============================================----

        local posCas =
        {
            v3.new(618.32416, 43.211624, 105.66624),
            v3.new(1171.9432, -95.993965, 105.080505),
            v3.new(733.55536, -308.09018, 118.84326),
            v3.new(896.63477, 314.4733, 113.98827),
        }
        local oriTCas =
        {
            v3.new(0, 0, -88), 
            v3.new(0, 0, 60),
            v3.new(0, 0, -34),
            v3.new(0, 0, -173)
        }
        local lastPosition = math.random(#posCas)

        WorldParts:action("Send Boeing to Casino", {}, "Recommended for blocking roads on the casino.", function()
            local hash = util.joaat("jet")
            LoadingModel(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                InterWait()
            end
            local currentPosition = math.random(#posCas)
            while currentPosition == lastPosition do
                currentPosition = math.random(#posCas)
            end
            lastPosition = currentPosition
        
            local pos = posCas[currentPosition]
            local orient = oriTCas[currentPosition]
        
            local boeing = entities.create_vehicle(hash, pos, orient.z)
            ENTITY.SET_ENTITY_INVINCIBLE(boeing, false)
        
            local speed = currentPosition == 1 and 850.0 or 500.0
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(boeing, speed)
            VEHICLE.SET_VEHICLE_MAX_SPEED(boeing, speed)
        
            if currentPosition > 1 then
                ENTITY.SET_ENTITY_ROTATION(boeing, orient.x, orient.y, orient.z, 2, false)
                VEHICLE.SET_HELI_BLADES_SPEED(boeing, 0)
            end
        
            VEHICLE.CONTROL_LANDING_GEAR(boeing, 3)
            InterWait()
        end)

    ----========================================----
    ---             Ped & Horn Parts
    ---  The part of funny features while scream
    ----========================================----

        WorldChanges:toggle_loop("Ped Scream", {}, "", function()
            InterWait(150)
            local peds = entities.get_all_peds_as_handles()
            for i = 1, #peds do
                if not PED.IS_PED_A_PLAYER(peds[i]) and not PED.IS_PED_IN_ANY_VEHICLE(peds[i]) then
                    AUDIO.PLAY_PAIN(peds[i], math.random(6, 7), 0, 0)
                end
                InterWait(math.random(0, 2))
            end
        end)

        WorldChanges:toggle_loop("Toggle Horn", {}, "Cause all nearby vehicles to activate there horns", function() 
            AUDIO.SET_AGGRESSIVE_HORNS(true)
            for i, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                VEHICLE.START_VEHICLE_HORN(vehicle, 20, 0, false)
            end
            InterWait(1000)
        end)

        WorldChanges:toggle_loop("Combine Horn & Ped Scream", {}, "MAKE SCREAM AND HORN AGGRESSIVE", function()
            InterWait(150)
            local peds = entities.get_all_peds_as_handles()
            for i = 1, #peds do
                if not PED.IS_PED_A_PLAYER(peds[i]) and not PED.IS_PED_IN_ANY_VEHICLE(peds[i]) then
                    AUDIO.PLAY_PAIN(peds[i], math.random(6, 7), 0, 0)
                end
                InterWait(math.random(0, 2))
            end

            AUDIO.SET_AGGRESSIVE_HORNS(true)
            for i, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                VEHICLE.START_VEHICLE_HORN(vehicle, 20, 0, false)
            end
            InterWait(1000)
        end)

        WorldChanges:divider("Advanced Tools")

        WorldChanges:toggle("Toggle Blackout", {}, "*works locally*", function(toggle)
            GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(toggle)
            GRAPHICS.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(toggle)
            if toggle then
                if menu.get_value(clear_day) then
                    menu.set_value(clear_day, false)
                end
                GRAPHICS.SET_TIMECYCLE_MODIFIER_STRENGTH(1)
                GRAPHICS.SET_TIMECYCLE_MODIFIER("dlc_island_vault")
                GRAPHICS.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(true)
                InterCmds("locktime on")
                InterCmds("timesmoothing off")
                InterCmds("time 0")
                InterCmds("clouds horizon")
            elseif not menu.get_value(clear_day) then
                GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
                GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(false)
                GRAPHICS.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(false)
                GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
                ResetRendering()
            end
        end)

        local GTWorld = "Toggle Ghost Town"
        WorldChanges:toggle(GTWorld, {}, "*works locally*", function(state)
            local ref = menu.ref_by_rel_path(WorldChanges, GTWorld)
            if state then
                if menu.get_value(clear_day) then
                    menu.set_value(clear_day, false)
                end
                GRAPHICS.SET_TIMECYCLE_MODIFIER_STRENGTH(1)
                GRAPHICS.SET_TIMECYCLE_MODIFIER("superDARK")
                GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(true)
                GRAPHICS.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(true)
                InterCmds("locktime on")
                InterCmds("timesmoothing off")
                InterCmds("time 0")
                InterCmds("clouds horizon")
                util.create_tick_handler(function()
                    if not ref.value then
                        return false
                    end
                    VEHICLE.SET_AMBIENT_VEHICLE_RANGE_MULTIPLIER_THIS_FRAME(0.0)
                    PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(0.0)
                    PED.SET_SCENARIO_PED_DENSITY_MULTIPLIER_THIS_FRAME(0.0, 0.0)
                    VEHICLE.SET_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0.0)
                    VEHICLE.SET_RANDOM_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0.0)
                    VEHICLE.SET_PARKED_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0.0)
                end)
            elseif not menu.get_value(clear_day) then
                GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(false)
                GRAPHICS.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(false)
                GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
                ResetRendering()
            end
        end)

        WorldChanges:toggle_loop("Riot Mode", {}, "Simple Riot mode when NPCs will fight against.", function()
            MISC.SET_RIOT_MODE_ENABLED(true)
        end, function()
            MISC.SET_RIOT_MODE_ENABLED(false)
        end)

        WorldChanges:toggle_loop("Riot Mode Enhanced", {}, "Purge is coming.", function()
            MISC.SET_RIOT_MODE_ENABLED(true)
            InterCmds("wanted 0")
            local repopulate_timer = os.time() + 10
            if os.time() > repopulate_timer then
                PED.INSTANTLY_FILL_PED_POPULATION()
                repopulate_timer = os.time() + 10
            end

            for i, entitiy in pairs(entities.get_all_peds_as_handles()) do
                if entitiy == players.user_ped() then
                    goto continue
                end

                for i = 0, 91 do
                    PED.SET_PED_COMBAT_ATTRIBUTES(entitiy, i, true)
                end

                PED.SET_PED_COMBAT_RANGE(entitiy, 4)
                PED.SET_PED_COMBAT_ABILITY(entitiy, 2)
                PED.SET_PED_COMBAT_MOVEMENT(entitiy, 3)
                PED.SET_PED_ACCURACY(entitiy, 100)
                if PED.IS_PED_IN_ANY_VEHICLE(entitiy, false) then
                    local vehcars = PED.GET_VEHICLE_PED_IS_IN(entitiy, false)
                    TASK.TASK_LEAVE_ANY_VEHICLE(entities, 0, 0)
                    entities.delete_by_handle(vehcars)
                end
                if i % 5 == 0 then
                    TASK.TASK_COMBAT_PED(entitiy, players.user_ped(), 0, 16)
                end
                ::continue::
            end
        end,function()
            MISC.SET_RIOT_MODE_ENABLED(false)
        end)

    ----========================================----
    ---             Panic Parts
    ---   The part of menyoo destroying world
    ----========================================----


        PanicParts:divider("Panic Mode")
                    
        local DeathPoint = {
            groundpoint = 100,
            vehicle_toggle = true,
            ped_toggle = true,
            object_toggle = false,
            forward_speed = 30,
            forward_degree = 30,
            has_gravity = true,
            time_delay = 100,
            exclude_mission = false,
            exclude_dead = false
        }
        
        PanicParts:toggle_loop("Toggle Panic Mode", {}, "Attract all entites around of you.\n\nNOTE: You will also too attract yourself and can make strange movements.", function()
            -- Vehicle
            if DeathPoint.vehicle_toggle then
                for _, ent in pairs(GET_NEARBY_VEHICLES(players.user_ped(), DeathPoint.groundpoint)) do
                    if not IS_PLAYER_VEHICLE(ent) then
                        if DeathPoint.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        elseif DeathPoint.exclude_dead and ENTITY.IS_ENTITY_DEAD(ent) then
                        else
                            REQUEST_CONTROL_ENTITY(ent, 10)
                            VEHICLE.SET_VEHICLE_MAX_SPEED(ent, 99999.0)
                            ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                            VEHICLE.SET_VEHICLE_FORWARD_SPEED(ent, DeathPoint.forward_speed)
                            VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(ent, false, false)
                            VEHICLE.SET_VEHICLE_GRAVITY(ent, DeathPoint.has_gravity)
                        end
                    end
                end
            end
            if DeathPoint.ped_toggle then
                for _, ent in pairs(GET_NEARBY_PEDS(players.user_ped(), DeathPoint.groundpoint)) do
                    if not IS_PED_PLAYER(ent) then
                        if DeathPoint.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                        elseif DeathPoint.exclude_dead and ENTITY.IS_ENTITY_DEAD(ent) then
                        else
                            REQUEST_CONTROL_ENTITY(ent, 10)
                            ENTITY.SET_ENTITY_MAX_SPEED(ent, 99999.0)
                            ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                            local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ent)
                            local force = {}
                            force.x = vector.x * math.random(-1, 1) * DeathPoint.forward_degree
                            force.y = vector.y * math.random(-1, 1) * DeathPoint.forward_degree
                            force.z = vector.z * math.random(-1, 1) * DeathPoint.forward_degree
        
                            ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 1, false, true, true,
                                true, true)
                            ENTITY.SET_ENTITY_HAS_GRAVITY(ent, DeathPoint.has_gravity)
                        end
                    end
                end
            end
            if DeathPoint.object_toggle then
                for _, ent in pairs(GET_NEARBY_OBJECTS(players.user_ped(), DeathPoint.groundpoint)) do
                    if DeathPoint.exclude_mission and ENTITY.IS_ENTITY_A_MISSION_ENTITY(ent) then
                    elseif DeathPoint.exclude_dead and ENTITY.IS_ENTITY_DEAD(ent) then
                    else
                        REQUEST_CONTROL_ENTITY(ent, 10)
                        ENTITY.SET_ENTITY_MAX_SPEED(ent, 99999.0)
                        ENTITY.FREEZE_ENTITY_POSITION(ent, false)
                        local vector = ENTITY.GET_ENTITY_FORWARD_VECTOR(ent)
                        local force = {}
                        force.x = vector.x * math.random(-1, 1) * DeathPoint.forward_degree
                        force.y = vector.y * math.random(-1, 1) * DeathPoint.forward_degree
                        force.z = vector.z * math.random(-1, 1) * DeathPoint.forward_degree
        
                        ENTITY.APPLY_FORCE_TO_ENTITY(ent, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 1, false, true, true,
                            true, true)
                        ENTITY.SET_ENTITY_HAS_GRAVITY(ent, DeathPoint.has_gravity)
                    end
                end
            end
            InterWait(DeathPoint.time_delay)
        end)
        
        PanicParts:divider("Panic Mode Settings")
        local groundpoint_slider = PanicParts:slider("Panic Mode Range", {'intpmr'}, "Range centered of you, will able to choose range distance which it will attract.", 0, 1000, 100, 10, function(value)
            DeathPoint.groundpoint = value
        end)

        PanicParts:toggle("Toggle Car", {}, "", function(toggle)
            DeathPoint.vehicle_toggle = toggle
        end, true)

        PanicParts:toggle("Toggle NPC", {}, "", function(toggle)
            DeathPoint.ped_toggle = toggle
        end, true)

        PanicParts:toggle("Toggle Object", {}, "", function(toggle)
            DeathPoint.object_toggle = toggle
        end)

        PanicParts:slider("Speed Cars", {'intspeedcar'}, "", 0, 1000, 30, 10, function(value)
            DeathPoint.forward_speed = value
        end)

            PanicParts:slider("Speed Propulsion of NPCs", {'intspeednpc'}, "", 0, 1000, 30, 10,
        function(value)
            DeathPoint.forward_degree = value
        end)

        PanicParts:toggle("Gravity Entities", {}, "", function(toggle)
            DeathPoint.has_gravity = toggle
        end, true)

        PanicParts:slider("Delay Time (ms)", {'intdelayt'}, "", 0, 3000, 100, 10, function(value)
            DeathPoint.time_delay = value
        end)

        PanicParts:toggle("Exclude Mission", {}, "", function(toggle)
            DeathPoint.exclude_mission = toggle
        end)

        PanicParts:toggle("Exclude Deaths", {}, "", function(toggle)
            DeathPoint.exclude_dead = toggle
        end)
        
        local is_groundpoint_slider_onFocus
        menu.on_focus(groundpoint_slider, function()
            is_groundpoint_slider_onFocus = true
            util.create_tick_handler(function()
                if not is_groundpoint_slider_onFocus then
                    return false
                end
        
                local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
                GRAPHICS.DRAW_MARKER_SPHERE(coords.x, coords.y, coords.z, DeathPoint.groundpoint, 200, 50, 200, 0.5)
            end)
        end)
        
        menu.on_blur(groundpoint_slider, function()
            is_groundpoint_slider_onFocus = false
        end)

    ----========================================----
    ---           Twin Towers Parts
    ---   The part of worlds parts, twin towers
    ----========================================----

        local positions = {
            {v3.new(125.72, -1146.2, 222.75), v3.new(286.49008, -1007.72217, 90.0402), {"Boeing 747 appears at ".."Pilbox Hill (".."North"..")"}}, -- North 1
            {v3.new(118.13, -365.5, 213.06), v3.new(246.32755, -285.16418, 68.83013), {"Boeing 747 appears at ".."Alta (".."South East"..")"}}, -- South East 2
            {v3.new(-126.54, -508.41, 226.35), v3.new(-151.16615, -276.66415, 81.63583), {"Boeing 747 appears at ".."Vinewood (".."East"..")"}}, -- East 3 
            {v3.new(368.63, -656.42, 199.41), v3.new(590.4069, -607.59656, 41.821896), {"Boeing 747 appears at ".."Textile City/Strawberry Ave (".."South West"..")"}}, -- South West 4
            {v3.new(486.79584, -836.7407, 201.24078), v3.new(460.1325, -1097.1022, 43.075542), {"Boeing 747 appears at ".."Textile City (".."West"..")"}},  -- West 5
            {v3.new(324.71548, -60.498875, 232.9209), v3.new(313.43738, -60.363735, 153.29718), {"Boeing 747 appears at ".."Hawick (".."South"..")"}}, -- South 6
            {v3.new(-875.4278, -191.15733, 260.2907), v3.new(-491.05692, -335.17578, 96.19807), {"Boeing 747 appears at ".."Rockford Hills (".."East"..")"}}, -- East 7
            {v3.new(578.16266, -443.25204, 205.79388), v3.new(712.1099, -243.52017, 67.47418), {"Boeing 747 appears at ".."Alta (".."South West"..")"}}, -- South West 8  
        }
        
        local orientations = {
            v3.new(0, 0, -3), -- North 1
            v3.new(0, 10, -180), -- South East 2
            v3.new(10, 0, -118), -- East 3
            v3.new(10, 0, -244), -- South West 4
            v3.new(10, 0, -285), -- West 5
            v3.new(10, 0, -200), -- South 6
            v3.new(10, 0, -113), -- East 7
            v3.new(10, 0, -244), -- South West 8
        }

        local currentPosition = math.random(#positions)
        local isAssisting = false
        local toggleSong
        local isCooldown = false
        local lastTimeUsed = 0
        
        TimerTowers = TwinTowersParts:slider("Cooldown Duration", {"interttcooldown"}, "", 15, 600, 15, 1, function()end)
        TwinTowersParts:toggle("Toggle Teleport 'Twin Towers'", {}, "Toggle while teleporting House to assist 9/11 Crash Planes\n\n- Enable: you will be automatically teleported.\n- Disable: you will not be automatically teleported.", function(toggle) isAssisting = toggle end)
        TwinTowersParts:toggle("Toggle Sounds for 'Twin Towers'", {}, "Toggle while using song House for 9/11 Crash Planes\n\n- Enable: you will hear the sound (local).\n- Disable: you will not be able to hear the sound (local).", function(toggle) toggleSong = toggle end)
        TwinTowersParts:action("Twin Towers Boeing", {}, "Send Boeing to Twin Towers but you have each interval which you cannot spam more plane.\n\nNostalgic 9/11 but watch this.\n\nBeware, some planes can cross the Twin Towers, be very careful. Do not abuse the features.", function()
            local cooldownTime = menu.get_value(TimerTowers)
            if isAssisting then
                local UserPos = positions[currentPosition] and positions[currentPosition][2] or nil
                if UserPos then
                    ENTITY.SET_ENTITY_COORDS(players.user_ped(), UserPos.x, UserPos.y, UserPos.z)
                end
            end
            if toggleSong then
                local songs911 = script_resources .. '/Sounds'
                PlaySong(join_path(songs911, "911.wav"), SND_FILENAME | SND_ASYNC)
            end
            musicStartTime = os.clock()
            local hash = util.joaat("jet")
            LoadingModel(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                InterWait()
            end
            local currentTime = os.time()
            local elapsedTime = currentTime - lastTimeUsed
            if not isCooldown or elapsedTime >= cooldownTime then
                isCooldown = true
                lastTimeUsed = currentTime
                
                if positions[currentPosition] ~= nil then
                    local pos = positions[currentPosition][1]
                    local orient = orientations[currentPosition]
        
                    local boeing = entities.create_vehicle(hash, pos, orient.z)
                    ENTITY.SET_ENTITY_INVINCIBLE(boeing, false)
        
                    local speed = currentPosition == 1 and 850.0 or 650.0
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(boeing, speed)
                    VEHICLE.SET_VEHICLE_MAX_SPEED(boeing, speed)
        
                    if currentPosition > 0 then
                        ENTITY.SET_ENTITY_ROTATION(boeing, orient.x, orient.y, orient.z, 2, false)
                        VEHICLE.SET_HELI_BLADES_SPEED(boeing, 0)
                        if positions[currentPosition][3] then
                            local str = table.concat(positions[currentPosition][3])
                            InterNotify(str)
                        end
                    end
        
                    VEHICLE.CONTROL_LANDING_GEAR(boeing, 3)
                end
        
                currentPosition = math.random(#positions + 1)
                while os.clock() - musicStartTime < 11 do
                    InterWait()
                end
                PlaySong(join_path(script_resources, "stops.wav"), SND_FILENAME | SND_ASYNC)
                isCooldown = false
            else
                local remainingTime = cooldownTime - elapsedTime
                if remainingTime >= 60 then
                    local minutes = math.floor(remainingTime / 60)
                    local seconds = math.floor(remainingTime % 60)
                    local pluralMinutes = minutes > 1 and "s" or ""
                    local pluralSeconds = seconds > 1 and "s" or ""
                    InterNotify("Please wait " .. minutes .. " minute" .. pluralMinutes .. " and " .. seconds .. " second" .. pluralSeconds .. " to start again.")
                else
                    local plural = remainingTime > 1 and "s" or ""
                    local seconds = math.floor(remainingTime)
                    InterNotify("Please wait " .. seconds .. " second" .. plural .. " to start again.")
                end
                PlaySong(join_path(script_resources, "stops.wav"), SND_FILENAME | SND_ASYNC)
                isAssisting = false
            end
        end)

    ----========================================----
    ---           Teleport Parts
    ---   The part of teleport parts, locations
    ----========================================----

        local InterVans = {
            {v3.new(-30.691593170166016, 6440.61181640625, 31.46271514892578), "Gunvan 1 (Paleto Bay)"},
            {v3.new(1708.04541015625,4818.873046875,42.020225524902344), "Gunvan 2 (Grapeseed)"},
            {v3.new(1799.9373779296875,3901.3955078125,34.05502700805664), "Gunvan 3 (Sandy Shores)"},
            {v3.new(1339.3294677734375,2758.759765625,51.40709686279297), "Gunvan 4 (Grand Senora Desert 'Part 1')"},
            {v3.new(785.4343872070313,1214.0382080078125,336.1535949707031), "Gunvan 5 (Vinewood Hills)"},
            {v3.new(-3195.79150390625,1059.0968017578125,20.859222412109375), "Gunvan 6 (Chumash)"},
            {v3.new(-797.0811157226563,5404.021484375,34.05730438232422), "Gunvan 7 (Paleto Forest)"},
            {v3.new(-17.769180297851563,3054.6484375,41.4296875), "Gunvan 8 (Zancudo River)"},
            {v3.new(2667.525634765625,1469.25537109375,24.50077247619629), "Gunvan 9 (Palmer Taylor Station)"},
            {v3.new(-1455.878662109375,2669.613525390625,17.643640518188477), "Gunvan 10 (Lago Zancudo Bridge)"},
            {v3.new(2347.800537109375,3052.162841796875,48.184085845947266), "Gunvan 11 (Grand Senora Desert 'Part 2')"},
            {v3.new(1513.4649658203125,-2143.073486328125,76.97412872314453), "Gunvan 12 (El Burrito Heights)"},
            {v3.new(1156.6365966796875,-1359.7158203125,34.70103454589844), "Gunvan 13 (Murrieta Heights)"},
            {v3.new(-58.51665115356445,-2651.006103515625,6.0007123947143555), "Gunvan 14 (Elysian Island)"},
            {v3.new(1906.2650146484375,560.096923828125,175.74546813964844), "Gunvan 15 (Tataviam Mountains)"},
            {v3.new(966.0137939453125,-1711.8599853515625,30.243873596191406), "Gunvan 16 (La Mesa)"},
            {v3.new(795.4525756835938,-3271.485595703125,5.900516033172607), "Gunvan 17 (Terminal Port)"},
            {v3.new(-582.546142578125,-1640.6015625,19.550588607788086), "Gunvan 18 (La Puerta)"},
            {v3.new(734.7702026367188,-733.7327880859375,26.44579315185547), "Gunvan 19 (La Mesa 'Part 2')"},
            {v3.new(-1689.081787109375,-448.0471496582031,40.953269958496094), "Gunvan 20 (Del Perro)"},
            {v3.new(-1322.4208984375,-1164.1304931640625,4.779491901397705), "Gunvan 21 (Vespucci / Magellan Ave)"},
            {v3.new(-501.4334716796875,50.08109664916992,56.49615478515625), "Gunvan 22 (West Vinewood)"},
            {v3.new(273.6707763671875,72.75302124023438,99.89118194580078), "Gunvan 23 (Downtown Vinewood)"},
            {v3.new(258.6902160644531,-753.9094848632813,34.63716125488281), "Gunvan 24 (Pillbox Hill)"},
            {v3.new(-473.2128,-738.3798,30.56298), "Gunvan 25 (Little Seoul)"},
            {v3.new(904.8756103515625,3607.78564453125,32.81423568725586), "Gunvan 26 (Alamo Sea)"},
            {v3.new(-2164.646484375,4280.94091796875,48.957191467285156), "Gunvan 27 (North Chumash)"},
            {v3.new(1464.5263671875,6554.38525390625,14.094414710998535), "Gunvan 28 (Mount Chiliad)"},
            {v3.new(1099.485107421875,-331.3899841308594,67.20771789550781), "Gunvan 29 (Mirror Park)"},
            {v3.new(155.89004516601563,-1649.0552978515625,29.291664123535156), "Gunvan 30 (Davis)"},
        }

        local InterLands = {
            {v3.new(-1028.3832, -2735.1409, 13.756649), "Airport Entrance"},
            {v3.new(-1170.4204, 4926.473, 224.33012), "Altruist Camp"},
            {v3.new(-520.25476, 4436.8955, 89.79521), "Calafia Train Bridge"},
            {v3.new(928.1053, -2878.5774, 19.012945), "Cargo Ship"},
            {v3.new(3411.0686, 3755.0962, 30.101265), "Humane Labs"},
            {v3.new(-2243.81, 264.048, 174.61525), "Kortz Center"},
            {v3.new(2121.7, 4796.3, 41.108337), "McKenzie Airfield"},
            {v3.new(486.43237, -3339.7036, 6.0699167), "Merryweather Dock"},
            {v3.new(464.54227, 5568.8213, 790.4641), "Mount Chiliad"},
            {v3.new(2532.4246, -383.2167, 92.99277), "N.O.O.S.E Headquarters"},
            {v3.new(1746.9985, 3273.6802, 41.14016), "Sandy Shores Airfield"},
            {v3.new(760.4, -2943.2, 5.800333), "Terminal Jetsam"},
            {v3.new(2208.6907, 5578.223, 53.736073), "Weed Farm"},
            {v3.new(2353.8342, 1830.2937, 101.169365), "Wind Farm"}
        }

        local InterUnders = {
            {"Hatch", v3.new(4283.7285, 2963.618, -182.20798), ""},
            {"Panzer II Tank", v3.new(4201.7407, 3644.483, -38.688774), "I love Nazis"},
            {"Sea Monster", v3.new(-3373.7266, 504.7183, -24.418417), ""},
            {"Sunken Cargo Ship", v3.new(3194.2065, -366.6386, -19.867027), ""},
            {"Sunken Plane", v3.new(-943.3077, 6609.274, -20.725874), ""}
        }
        
        local InterINTRS = {
            {"Comedy Club", v3.new(379.33194, -1002.38336, -98.99994)},
            {"Floyd's House", v3.new(-1151.8948, -1517.4011, 10.632715)},
            {"FIB Bureau (RAID)", v3.new(149.68756, -741.0188, 254.15218)},
            {"FIB Interior Rooftop", v3.new(121.159454, -740.33936, 258.152)},
            {"Franklin's House (Interior)", v3.new(-2.8133092, 529.7468, 176.06947)},
            {"Franklin's House (Room)", v3.new(2.1897643, 525.6434, 171.30257)},
            {"IAA Office", v3.new(124.21153, -618.8245, 206.04698)},
            {"Mineshaft", v3.new(-593.2174, 2080.1958, 131.39897)},
            {"Michael's House", v3.new(-813.04065, 179.86508, 72.15916)},
            {"Motel Room", v3.new(152.21722, -1001.37317, -99.00002)},
            {"Pacific Standard Vault Room", v3.new(255.99345, 217.02151, 101.683556)},
            {"Safe Room Space (AFK Only)", v3.new(-155.31094, -969.80676, 219.12654)},
            {"Torture Room", v3.new(142.746, -2201.189, 4.6918745)},
            {"Trevor's House (Sandy Shores)", v3.new(1973.6528, 3817.9497, 33.436283)},
            {"Vanilla Unicorn Office", v3.new(97.55246, -1290.9927, 29.268766)},
            {"Zancudo Control Tower", v3.new(-2356.094, 3248.645, 101.45063)}
        }

        local InterEssentl = {
            {
                "Ammu-Nation",
                v3.new(14.729667, -1130.4623, 28.38218),
                v3.new(811.5394, -2136.2268, 29.298626),
                v3.new(1703.9557, 3749.8425, 34.06373),
                v3.new(235.26694, -42.48556, 69.696236),
                v3.new(844.6901, -1018.00684, 27.545353),
                v3.new(-325.35016, 6068.0625, 31.279776),
                v3.new(-664.4737, -949.35846, 21.533388),
                v3.new(-1325.7206, -386.22247, 36.602425),
                v3.new(-1110.5096, 2685.986, 18.646143),
                v3.new(-3159.859, 1079.9518, 20.694046),
                v3.new(2570.869, 310.5462, 108.461),
            },
            {
                "Arena War",
                v3.new(-374.40808, -1856.8129, 20.299635)
            },
            {
                "Barber Shop",
                v3.new(-828.62286, -188.61504, 37.62003),
                v3.new(129.84355, -1714.4921, 29.236816),
                v3.new(-1292.8214, -1117.3197, 6.628836),
                v3.new(1935.2532, 3717.9526, 32.385254),
                v3.new(1200.9613, -468.50922, 66.28133),
                v3.new(-30.15244, -141.15417, 57.041813),
                v3.new(-286.0247, 6235.8604, 31.465664),
            },
            {
                "Benny's Motor Works",
                v3.new(-221.68788, -1303.7201, 30.783205)
            },
            {
                "Clothing Store",
                v3.new(-151.23697, -305.93384, 38.308353),
                v3.new(413.63574, -805.7931, 29.316673),
                v3.new(-813.3747, -1087.347, 10.947831),
                v3.new(-1207.3555, -783.1656, 17.088503),
                v3.new(618.20264, 2739.6418, 41.92529),
                v3.new(129.76231, -201.78064, 54.51178),
                v3.new(-3165.1697, 1062.4639, 20.83883),
                v3.new(85.45275, -1392.5825, 29.255098),
                v3.new(1681.4573, 4822.2695, 42.062),
                v3.new(-1091.7141, 2700.7275, 19.632227),
                v3.new(1197.4186, 2697.1492, 37.936787),
                v3.new(-2.4914842, 6519.3267, 31.465714),
                v3.new(-719.6272, -158.39229, 37.000366),
                v3.new(-1459.5343, -227.91628, 49.196167),
            },
            {
                "Diamond Casino",
                v3.new(917.64594, 50.39213, 80.40586)
            },
            {
                "Eclipse Towers",
                v3.new(-793.00836, 294.89856, 85.34387)
            },
            {
                "Fort Zancudo Airbase/Airfield",
                v3.new(-1544.4578, 2751.5488, 17.777958),
            },
            {
                "Los Santos Customs",
                v3.new(-383.23624, -123.49709, 38.19501),
                v3.new(-1134.1277, -1988.4802, 13.183585),
                v3.new(708.4548, -1080.1211, 22.401926),
                v3.new(1174.5228, 2653.681, 38.145153),
            },
            {
                "Los Santos Car Meet",
                v3.new(782.53174, -1893.9546, 28.654327)
            }
        }

        local Landmarks = TeleportParts:list("Landmarks", {}, "", function()end)  -- Landmarks
        for _, InterLands in ipairs(InterLands) do
            Landmarks:action(InterLands[2], {}, "", function()
                local UserPos = InterLands[1] or nil
                ENTITY.SET_ENTITY_COORDS(players.user_ped(), UserPos.x, UserPos.y, UserPos.z)
            end)
        end

        local Underwaters = TeleportParts:list("Underwaters", {}, "", function()end)  -- Underwaters
        for _, InterUnders in ipairs(InterUnders) do
            Underwaters:action(InterUnders[1], {}, InterUnders[3], function()
                local UserPos = InterUnders[2] or nil
                ENTITY.SET_ENTITY_COORDS(players.user_ped(), UserPos.x, UserPos.y, UserPos.z)
            end)
        end

        local Interiors = TeleportParts:list("Interiors", {}, "Can may your ped instantly die.", function()end)  -- Interiors
        for _, InterINTRS in ipairs(InterINTRS) do
            Interiors:action(InterINTRS[1], {}, "", function()
                local UserPos = InterINTRS[2] or nil
                ENTITY.SET_ENTITY_COORDS(players.user_ped(), UserPos.x, UserPos.y, UserPos.z)
            end)
        end

        local Essentials = TeleportParts:list("Essentials Locations", {}, "", function()end)  -- Interiors
        for _, InterEssentl in ipairs(InterEssentl) do
            local UserPos = nil
            Essentials:action(InterEssentl[1], {}, "", function()
                if #InterEssentl > 2 then
                    local teleportIndex = math.random(#InterEssentl - 2) 
                    UserPos = InterEssentl[teleportIndex + 2]
                elseif #InterEssentl == 2 then
                    UserPos = InterEssentl[2]
                else
                    UserPos = InterEssentl[1]
                end
                ENTITY.SET_ENTITY_COORDS(players.user_ped(), UserPos.x, UserPos.y, UserPos.z)
            end)
        end                

        TeleportParts:divider("Others")
        local GunVans = TeleportParts:list("Gunvan Locations", {}, "", function()end) -- Gun Van
        for _, InterVans in ipairs(InterVans) do
            GunVans:action(InterVans[2], {}, "", function()
                local UserPos = InterVans[1] or nil
                ENTITY.SET_ENTITY_COORDS(players.user_ped(), UserPos.x, UserPos.y, UserPos.z)
            end)
        end

    ----========================================----
    ---              Clearing Parts
    ---         The part of clearing parts
    ----========================================----

        ClearingParts:action("Full Clear", {"interfullclear"}, "This clears any Entity that Exists. It can Break many things, since it Deletes EVERY Entity that is in Range.", function()
            local ct = 0
            for k,ent in pairs(entities.get_all_vehicles_as_handles()) do
                entities.delete_by_handle(ent)
                ct = ct + 1
            end
            for k,ent in pairs(entities.get_all_peds_as_handles()) do
                if not PED.IS_PED_A_PLAYER(ent) then
                    entities.delete_by_handle(ent)
                    ct = ct + 1
                end
            end
            for k,ent in pairs(entities.get_all_objects_as_handles()) do
                entities.delete_by_handle(ent)
                ct = ct + 1
            end
            InterNotify("Full Clear Complete! Removed "..ct.." Entities in Total.")
        end)

        ClearingParts:action("Quick Clear", {"interquickclear"}, "Only Deletes Vehicles and Peds. Probably won't Break anything, unless a Mission Ped or Vehicle.", function()
            local ct = 0 
            for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
                entities.delete_by_handle(ent)
                ct = ct + 1
            end
            for k, ent in pairs(entities.get_all_peds_as_handles()) do
                if not PED.IS_PED_A_PLAYER(ent) then
                    entities.delete_by_handle(ent)
                    ct = ct + 1
                end
            end
            InterNotify("Successfully Deleted "..ct.." Entities.")
        end)

    ----========================================----
    ---         Clearing Parts Specific
    ---   The part of clearing parts specific
    ----========================================----

        ClearingPartSpec:action("Clear Vehicles", {"interclearveh"}, "Deletes all Vehicles.", function()
            local ct = 0
            for k, ent in pairs(entities.get_all_vehicles_as_handles()) do
                entities.delete_by_handle(ent)
                ct = ct + 1
            end
            InterNotify("Successfully Deleted "..ct.." Vehicles.")
        end)
        
        ClearingPartSpec:action("Clear Peds", {"interclearped"}, "Deletes all Non-Player Peds.", function()
            local ct = 0
            for k,ent in pairs(entities.get_all_peds_as_handles()) do 
                if not PED.IS_PED_A_PLAYER(ent) then
                    entities.delete_by_handle(ent)
                    ct = ct + 1
                end
            end
            InterNotify("Successfully Deleted "..ct.." Peds.")
        end)
        
        ClearingPartSpec:action("Clear Objects", {"interclearobjects"}, "Deletes all Objects. This can Break most Missions.", function()
            local ct = 0
            for k,ent in pairs(entities.get_all_objects_as_handles()) do
                entities.delete_by_handle(ent)
                ct = ct + 1
            end
            InterNotify("Successfull Deleted "..ct.." Objects.")
        end)
        
        ClearingPartSpec:action("Clear Pickups", {"interclearpickups"}, "Deletes all Pickups.", function()
            local ct = 0
            for k,ent in pairs(entities.get_all_pickups_as_handles()) do
                entities.delete_by_handle(ent)
                InterNotify("Successfully Deleted "..ct.." Pickups")
            end
        end)

        ResetRendering = function()
            InterCmds("locktime off")
            InterCmds("clouds normal")
            if AvailableSession() then
                InterCmds("syncclock")
            end
        end

    ----========================================----
    ---           Weather Features Parts
    ---         The part of weather parts
    ----========================================----

        clear_day = WeatherFeatures:toggle("Clear Day", {}, "", function(on) -- skid from aka
            InterWait()
            if on then
                if menu.get_value(clear_night) then
                    menu.set_value(clear_night, false)
                end
                InterCmds("locktime on")
                InterCmds("timesmoothing off")
                InterCmds("time 13")
                InterCmds("clouds horizon")
            elseif not menu.get_value(clear_night) then
                ResetRendering()
            end
        end)

        clear_night = WeatherFeatures:toggle("Clear Night", {}, "", function(on)
            InterWait()
            if on then
                if menu.get_value(clear_day) then
                    menu.set_value(clear_day, false)
                end
                InterCmds("locktime on")
                InterCmds("timesmoothing off")
                InterCmds("time 0")
                InterCmds("clouds horizon")
            elseif not menu.get_value(clear_day) then
                ResetRendering()
            end
        end)

        WeatherFeatures:toggle_loop("Always Clear Weather", {}, "",function()
            if AvailableSession() then
                InterCmds("weather extrasunny")
            else
                InterCmds("weather normal")
            end
            InterWait(100)
        end, function()
            InterCmds("weather normal")
        end)

        WeatherFeatures:divider("Related to Weather & Time")

        WeatherFeatures:toggle_loop("Thunder Lightning", {}, "*works locally*", function() 
            MISC.FORCE_LIGHTNING_FLASH()
            InterCmds("weather thunder")
        end,function()
            InterCmds("weather normal")
        end)

        WeatherFeatures:toggle_loop("Toggle Snow", {}, "*works locally*", function()
            SET_INT_GLOBAL(266897, 1)
        end,function()
            SET_INT_GLOBAL(266897, 0)
        end)

        local cloud_types_name = {
            "Altostratus",
            "Cirrus",
            "Cirrocumulus",
            "Clear 01",
            "Cloudy 01",
            "Contrails",
            "Horizon",
            "Horizon Band 1",
            "Horizon Band 2",
            "Horizon Band 3",
            "Horsey",
            "Nimbus",
            "Puffs",
            "Rain",
            "Snowy 01",
            "Stormy 01",
            "Stratocumulus",
            "Stripey",
            "Show",
            "Wispy",
            "Remove Clouds"
        }

        local cloud_types = {
            "altostratus",
            "Cirrus",
            "cirrocumulus",
            "Clear 01",
            "Cloudy 01",
            "Contrails",
            "Horizon",
            "horizonband1",
            "horizonband2",
            "horizonband3",
            "horsey",
            "Nimbus",
            "Puffs",
            "RAIN",
            "Snowy 01",
            "Stormy 01",
            "stratoscumulus",
            "Stripey",
            "shower",
            "Wispy",
            "Remove Clouds"
        }

        local weather_types = {
            "CLEAR",
            "EXTRASUNNY",
            "CLOUDS",
            "OVERCAST",
            "RAIN",
            "CLEARING",
            "THUNDER",
            "SMOG",
            "FOGGY",
            "XMAS",
            "SNOW",
            "SNOWLIGHT",
            "BLIZZARD",
            "HALLOWEEN",
            "NEUTRAL"
        }

        local weather_type_names = {
            "Clear",
            "Extra Sunny",
            "Clouds",
            "Overcast",
            "Rain",
            "Clearing",
            "Thunder", 
            "Smog",
            "Foggy", 
            "Xmas",
            "Snow",
            "Snowlight", 
            "Blizzard",
            "Halloween",
            "Neutral" 
        }

        local function on_cloud_type_selected(f)
            local cloud_hat = cloud_types[f]
            if cloud_hat == "Remove Clouds" then -- If "Remove" is selected, unload all cloud hats
                MISC.UNLOAD_ALL_CLOUD_HATS()
            else -- Otherwise, load the selected cloud hat
                MISC.LOAD_CLOUD_HAT(cloud_hat, 0)
            end
        end

        WeatherFeatures:action_slider("Change Cloud Type", {}, "Change the type of cloud.".."\n".."*works locally*", cloud_types_name, on_cloud_type_selected)
        
        WeatherFeatures:action_slider("Change Weather Type", {}, "*works locally*", weather_type_names, function(index)
            MISC.SET_WEATHER_TYPE_NOW_PERSIST(weather_types[index])
        end)

        util.create_thread(function()
            while true do
                InterWait(3000) 
                currentPlate = plateTables[math.random(#plateTables)]
            end
        end)

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
