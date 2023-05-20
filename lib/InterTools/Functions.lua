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

    Part: Functions
]]--

        local SND_ASYNC <const> = 0x0001
        local SND_FILENAME <const> = 0x00020000

    ---========================================----
    ---        Functions for InterTools
    ---         The part of essentials
    ----========================================----

        EToggleSelf = true
        EToggleFriend = true
        EToggleStrangers = true
        EToggleCrew = true
        EToggleOrg = true
        
        function toggleSelfCallback(toggle)
            EToggleSelf = not toggle
        end
        
        function toggleFriendCallback(toggle)
            EToggleFriend = not toggle
        end

        function toggleStrangersCallback(toggle)
            EToggleStrangers = not toggle
        end

        function toggleCrewCallback(toggle)
            EToggleCrew = not toggle
        end

        function toggleOrgCallback(toggle)
            EToggleOrg = not toggle
        end

        function QuickRespawn()
            local resp = memory.script_global(2672505 + 1685 + 756)
            if PED.IS_PED_DEAD_OR_DYING(players.user_ped()) then
                GRAPHICS.ANIMPOSTFX_STOP_ALL()
                memory.write_int(resp, memory.read_int(resp) | 1 << 1)
            end
        end

        function RequestModel(hash, timeout) -- Requesting Model
            timeout = timeout or 3
            STREAMING.REQUEST_MODEL(hash)
            local end_time = os.time() + timeout
            repeat
                util.yield()
            until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
            return STREAMING.HAS_MODEL_LOADED(hash)
        end

        function join_path(parent, child)
            local sub = parent:sub(-1)
            if sub == "/" or sub == "\\" then
                return parent .. child
            else
                return parent .. "/" .. child
            end
        end

        function RequestControl(entity, tick)
            if tick == nil then tick = 20 end
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and util.is_session_started() then
                entities.set_can_migrate(entities.handle_to_pointer(entity), true)

                local i = 0
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) and i <= tick do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
                    i = i + 1
                    util.yield()
                end
            end
            return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
        end

        function LoadingModel(hash)
            local request_time = os.time()
            if not STREAMING.IS_MODEL_VALID(hash) then
                return
            end
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if os.time() - request_time >= 10 then
                    break
                end
                util.yield()
            end
        end

        function RandomPlate() -- Random Generator Plate
            local plate = ""
                for i=1,8 do
                    local r = math.random(1,36)
                    if r <= 10 then
                        plate = plate .. tostring(r-1) 
                        else
                        r = r + 54 
                        if r > 90 then
                        r = r + 6 
                        end
                        plate = plate .. string.char(r)
                    end
                end
            return plate
        end

        function InstantlyFillVehiclePopulation()
            native_invoker.begin_call()
            native_invoker.end_call_2(0x48ADC8A773564670)
        end

        function REQUEST_CONTROL_ENTITY(ent, tick)
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
                local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
                NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
                for i = 1, tick do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                    if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
                        return true
                    end
                end
            end
            return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent)
        end

        function IS_PED_PLAYER(Ped)
            if PED.GET_PED_TYPE(Ped) >= 4 then
                return false
            else
                return true
            end
        end
        
        function IS_PLAYER_VEHICLE(Vehicle)
            if Vehicle == entities.get_user_vehicle_as_handle() or Vehicle == entities.get_user_personal_vehicle_as_handle() then
                return true
            elseif not VEHICLE.IS_VEHICLE_SEAT_FREE(Vehicle, -1, false) then
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(Vehicle, -1)
                if ped then
                    if IS_PED_PLAYER(ped) then
                        return true
                    end
                end
            end
            return false
        end

        function GET_NEARBY_VEHICLES(p, radius)
            local vehicles = {}
            local pos = ENTITY.GET_ENTITY_COORDS(p)
            for k, veh in pairs(entities.get_all_vehicles_as_handles()) do
                if radius == 0 then
                    table.insert(vehicles, veh)
                else
                    local veh_pos = ENTITY.GET_ENTITY_COORDS(veh)
                    local distance = v3.distance(v3(pos), v3(veh_pos))
                    if distance <= radius then
                        table.insert(vehicles, veh)
                    end
                end
            end
            return vehicles
        end

        function GET_NEARBY_PEDS(p, radius)
            local peds = {}
            local pos = ENTITY.GET_ENTITY_COORDS(p)
            for k, ped in pairs(entities.get_all_peds_as_handles()) do
                if radius == 0 then
                    table.insert(peds, ped)
                else
                    local ped_pos = ENTITY.GET_ENTITY_COORDS(ped)
                    local distance = v3.distance(v3(pos), v3(ped_pos))
                    if distance <= radius then
                        table.insert(peds, ped)
                    end
                end
            end
            return peds
        end

        function GET_NEARBY_OBJECTS(p, radius)
            local objects = {}
            local pos = ENTITY.GET_ENTITY_COORDS(p)
            for k, obj in pairs(entities.get_all_objects_as_handles()) do
                if radius == 0 then
                    table.insert(objects, obj)
                else
                    local obj_pos = ENTITY.GET_ENTITY_COORDS(obj)
                    local distance = v3.distance(v3(pos), v3(obj_pos))
                    if distance <= radius then
                        table.insert(objects, obj)
                    end
                end
            end
            return objects
        end

        function show_custom_rockstar_alert(l1)
            poptime = os.time()
            while true do
                if PAD.IS_CONTROL_JUST_RELEASED(18, 18) then
                    if os.time() - poptime > 0.1 then
                        break
                    end
                end
                native_invoker.begin_call()
                native_invoker.push_arg_string("ALERT")
                native_invoker.push_arg_string("JL_INVITE_ND")
                native_invoker.push_arg_int(2)
                native_invoker.push_arg_string("")
                native_invoker.push_arg_bool(true)
                native_invoker.push_arg_int(-1)
                native_invoker.push_arg_int(-1)
                -- line here
                native_invoker.push_arg_string(l1)
                -- optional second line here
                native_invoker.push_arg_int(0)
                native_invoker.push_arg_bool(true)
                native_invoker.push_arg_int(0)
                native_invoker.end_call("701919482C74B5AB")
                util.yield()
            end
        end

        function display_onscreen_keyboard()
            MISC.DISPLAY_ONSCREEN_KEYBOARD(1, "FMMC_KEY_TIP8", "", "", "", "", "", 100)
            while MISC.UPDATE_ONSCREEN_KEYBOARD() == 0 do
                util.yield_once()
            end
        
            if MISC.UPDATE_ONSCREEN_KEYBOARD() == 1 then
                local text = MISC.GET_ONSCREEN_KEYBOARD_RESULT()
                return text
            end
        end

        function CameraMoving(pid, force)
            local entity = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
            FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 7, 0, false, true, force)
        end

        function EnhanceOTR(toggled)
            otr = otr ?? memory.script_global(2657589 + 1 + (players.user() * 466) + 321)
            local v = memory.read_byte(otr)
            memory.write_byte(otr, toggled ? (v | 0xA) : (v & ~0xA))
        end

        function OwnedOrbitalCannon(state)
            local cannon = memory.script_global(2657589 + 1 + (0 * 466) + 427)
            if state then
                memory.write_int(cannon, memory.read_int(cannon) | (1 << 0))
            else
                memory.write_int(cannon, memory.read_int(cannon) & ~(1 << 0))
            end
        end

        vehicleData = util.get_vehicles() -- Preset Cars
        for k,v in vehicleData do
            vehicleData[k] = v.name
        end

        function request_model_load(hash)
            request_time = os.time()
            if not STREAMING.IS_MODEL_VALID(hash) then
                return
            end
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if os.time() - request_time >= 10 then
                    break
                end
                util.yield()
            end
        end
    
        function SET_PED_CAN_BE_KNOCKED_OFF_VEH(ped, state)
            native_invoker.begin_call()
            native_invoker.push_arg_int(ped)
            native_invoker.push_arg_int(state)
            native_invoker.end_call('7A6535691B477C48')
        end

        function escort_attack(pedUser, hash, surfaceVehicle)
            local limitSpeed = 960.0
            local speedVehicle = 440.0
            if not players.is_in_interior(pedUser) then
                local vehicleHash = util.joaat(hash)
                local playerPed = PLAYER.PLAYER_PED_ID()
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pedUser)
                local altitude = surfaceVehicle and 550 or 100
                request_model_load(vehicleHash)
                local playerPos = players.get_position(playerPed)
                playerPos.z = playerPos.z + altitude
                local offsetX = math.random(-55, 55)
                local offsetY = math.random(surfaceVehicle and -125 or -100, surfaceVehicle and 10 or -5)
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(playerPed, offsetX, offsetY, playerPos.z)
                local vehicle = entities.create_vehicle(vehicleHash, coords, ENTITY.GET_ENTITY_HEADING(playerPed))
        
                if not STREAMING.HAS_MODEL_LOADED(vehicle) then
                    request_model_load(vehicle)
                end
                for i = 0, 49 do
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                end
                VEHICLE.CONTROL_LANDING_GEAR(vehicle, 3)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, speedVehicle)
                VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, limitSpeed)
                VEHICLE.SET_VEHICLE_DOORS_LOCKED(vehicle, 4)
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
                coords = ENTITY.GET_ENTITY_COORDS(playerPed, false)
                coords.x = coords['x']
                coords.y = coords['y']
                coords.z = coords['z']
                local hash_models = {
                    util.joaat("s_m_y_blackops_01"),
                    util.joaat("s_m_m_marine_01"),
                    util.joaat("s_m_m_pilot_02"),
                    util.joaat("s_m_y_pilot_01"),
                    util.joaat("s_m_m_marine_02"),
                    util.joaat("s_m_m_prisguard_01"),
                    util.joaat("mp_g_m_pros_01"),
                    util.joaat("mp_m_avongoon"),
                    util.joaat("mp_m_boatstaff_01"),
                    util.joaat("mp_m_bogdangoon"),
                    util.joaat("mp_m_claude_01"),
                    util.joaat("mp_m_cocaine_01"),
                    util.joaat("mp_m_counterfeit_01"),
                    util.joaat("mp_m_exarmy_01"),
                    util.joaat("mp_m_fibsec_01")
                }
                local hash_model = hash_models[math.random(#hash_models)]
                request_model_load(hash_model)
                local attacker = entities.create_ped(28, hash_model, coords, math.random(0, 270))
                PED.SET_PED_AS_COP(attacker, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 281, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 2, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 33, false)
                PED.SET_PED_HEARING_RANGE(attacker, 99999)
                PED.SET_PED_RANDOM_COMPONENT_VARIATION(attacker, 0)
                PED.SET_PED_SHOOT_RATE(attacker, 5)
                PED.SET_PED_ACCURACY(attacker, 100.0)
                PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attacker, true)
                ENTITY.SET_ENTITY_INVINCIBLE(attacker, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                PED.CREATE_PED_INSIDE_VEHICLE(attacker, vehicle, 28, hash_model, -1, true)
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attacker, true, true)
                TASK.TASK_VEHICLE_MISSION_PED_TARGET(attacker, vehicle, ped, 6, 500.0, 786988, 0.0, 0.0, true)
                TASK.TASK_VEHICLE_CHASE(attacker, ped)
                PED.SET_PED_ACCURACY(attacker, 100.0)
                PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(attacker, 1)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
            end
        end

        function harass_vehicle(pedUser, vehicleHash, aerialCar, heliCars)
            if aerialCar then
                if not players.is_in_interior(pedUser) then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pedUser)
                    local hash = util.joaat(vehicleHash)
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
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(PlaneToggleGod))
                    coords = ENTITY.GET_ENTITY_COORDS(ped, false)
                    coords.x = coords['x']
                    coords.y = coords['y']
                    coords.z = coords['z']
                    local hash_model = util.joaat("s_m_y_pilot_01")
                    request_model_load(hash_model)
                    local attacker = entities.create_ped(28, hash_model, coords, math.random(0, 270))
                    PED.SET_PED_AS_COP(attacker, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 281, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 2, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 33, false)
                    PED.SET_PED_HEARING_RANGE(attacker, 99999)
                    PED.SET_PED_RANDOM_COMPONENT_VARIATION(attacker, 0)
                    PED.SET_PED_SHOOT_RATE(attacker, 5)
                    PED.SET_PED_ACCURACY(attacker, 100.0)
                    PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                    PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attacker, true)
                    ENTITY.SET_ENTITY_INVINCIBLE(attacker, menu.get_value(PlaneToggleGod))
                    PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                    local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                    PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                    PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                    PED.CREATE_PED_INSIDE_VEHICLE(attacker, vehicle, 28, hash_model, -1, true)
                    PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attacker, true, true)
                    TASK.TASK_VEHICLE_MISSION_PED_TARGET(attacker, vehicle, ped, 6, 500.0, 786988, 0.0, 0.0, true)
                    TASK.TASK_VEHICLE_CHASE(attacker, ped)
                    PED.SET_PED_ACCURACY(attacker, 100.0)
                    PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                    PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                    PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                    PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                    SET_PED_CAN_BE_KNOCKED_OFF_VEH(attacker, 1)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                    PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                    local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                    PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                end
            end

            if heliCars then
                if not players.is_in_interior(pedUser) then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pedUser)
                    local marine1 = util.joaat("s_m_y_marine_01")
                    local marine2 = util.joaat("s_m_y_marine_03")
                    local hash = util.joaat(vehicleHash)
                    request_model_load(hash)
                    request_model_load(marine1)
                    request_model_load(marine2)
                    local altitude = 25
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
                        local attackerFlag = entities.create_ped(2, marine1, outCoords, math.random(0, 270))
                        PED.SET_PED_INTO_VEHICLE(attackerFlag, vehicle, i)
                        if i % 2 == 0 then
                            WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                            PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                        else
                            WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                            PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                        end
                        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(HelisToggleGod))
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
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 30.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, 100.0)
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
                        ENTITY.SET_ENTITY_INVINCIBLE(attackerFlag, menu.get_value(HelisToggleGod))
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

        function AggressivePlanes(pedUser, hash)
            if not players.is_in_interior(pedUser) then
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pedUser)
                local vehicleHash = util.joaat(hash)
                request_model_load(vehicleHash)
                local altitude = 150
                local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 0.0, altitude)
                local vehicle = entities.create_vehicle(vehicleHash, coords, ENTITY.GET_ENTITY_HEADING(ped))
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
                ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(PlaneToggleGod))
                coords = ENTITY.GET_ENTITY_COORDS(ped, false)
                coords.x = coords['x']
                coords.y = coords['y']
                coords.z = coords['z']
                local hash_models = {
                    util.joaat("s_m_y_blackops_01"),
                    util.joaat("s_m_m_marine_01"),
                    util.joaat("s_m_m_pilot_02"),
                    util.joaat("s_m_y_pilot_01"),
                    util.joaat("s_m_m_marine_02"),
                    util.joaat("s_m_m_prisguard_01"),
                    util.joaat("mp_g_m_pros_01"),
                    util.joaat("mp_m_avongoon"),
                    util.joaat("mp_m_boatstaff_01"),
                    util.joaat("mp_m_bogdangoon"),
                    util.joaat("mp_m_claude_01"),
                    util.joaat("mp_m_cocaine_01"),
                    util.joaat("mp_m_counterfeit_01"),
                    util.joaat("mp_m_exarmy_01"),
                    util.joaat("mp_m_fibsec_01")
                }
                local hash_model = hash_models[math.random(#hash_models)]
                request_model_load(hash_model)
                local attacker = entities.create_ped(28, hash_model, coords, math.random(0, 270))
                PED.SET_PED_AS_COP(attacker, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 281, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 2, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 33, false)
                PED.SET_PED_HEARING_RANGE(attacker, 99999)
                PED.SET_PED_RANDOM_COMPONENT_VARIATION(attacker, 0)
                PED.SET_PED_SHOOT_RATE(attacker, 5)
                PED.SET_PED_ACCURACY(attacker, 100.0)
                PED.SET_PED_COMBAT_ABILITY(attacker, 2, true)
                PED.SET_PED_FLEE_ATTRIBUTES(attacker, 0, false)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 5, true)
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attacker, true)
                ENTITY.SET_ENTITY_INVINCIBLE(attacker, true)
                PED.SET_PED_CONFIG_FLAG(attacker, 52, true)
                local relHash = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                PED.SET_PED_RELATIONSHIP_GROUP_HASH(attacker, relHash)
                PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                PED.CREATE_PED_INSIDE_VEHICLE(attacker, vehicle, 28, hash_model, -1, true)
                PED.SET_PED_INTO_VEHICLE(attacker, vehicle, -1)
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attacker, true, true)
                TASK.TASK_VEHICLE_MISSION_PED_TARGET(attacker, vehicle, ped, 6, 500.0, 786988, 0.0, 0.0, true)
                TASK.TASK_VEHICLE_CHASE(attacker, ped)
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

        function groundAttack(pid, hash, groundVehicle)
            if groundVehicle then
                if not players.is_in_interior(pid) then
                    local player_ped = PLAYER.PLAYER_PED_ID()
                    local vehicleHash = util.joaat(hash)
                    local hash_models = {
                        util.joaat("s_m_y_blackops_01"),
                        util.joaat("s_m_m_marine_01"),
                        util.joaat("s_m_m_pilot_02"),
                        util.joaat("s_m_y_pilot_01"),
                        util.joaat("s_m_m_marine_02"),
                        util.joaat("s_m_m_prisguard_01"),
                        util.joaat("mp_g_m_pros_01"),
                        util.joaat("mp_m_avongoon"),
                        util.joaat("mp_m_boatstaff_01"),
                        util.joaat("mp_m_bogdangoon"),
                        util.joaat("mp_m_claude_01"),
                        util.joaat("mp_m_cocaine_01"),
                        util.joaat("mp_m_counterfeit_01"),
                        util.joaat("mp_m_exarmy_01"),
                        util.joaat("mp_m_fibsec_01")
                    }
                    local marine1 = hash_models[math.random(#hash_models)]
                    request_model_load(vehicleHash)
                    request_model_load(marine1)
                    local targetPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player_ped, 0.0, 20.0, 0.0)
                    local vehicle = entities.create_vehicle(vehicleHash, pos, ENTITY.GET_ENTITY_HEADING(player_ped))
                    if not ENTITY.DOES_ENTITY_EXIST(vehicle) then
                        return
                    end
                    local offset = getOffsetFromEntityGivenDistance(vehicle, 4)
                    local outCoords = v3.new()
                    local outHeading = memory.alloc()
                
                    if PATHFIND.GET_CLOSEST_VEHICLE_NODE_WITH_HEADING(offset.x, offset.y, offset.z, outCoords, outHeading, 1, 3.0, 0) then
                        ENTITY.SET_ENTITY_COORDS(vehicle, v3.getX(outCoords), v3.getY(outCoords), v3.getZ(outCoords))
                        ENTITY.SET_ENTITY_HEADING(vehicle, memory.read_float(outHeading))
                        VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
                    end
                    for i=-1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle) - 1 do
                        local attackerFlag = entities.create_ped(2, marine1, outCoords, math.random(0, 270))
                        PED.SET_PED_INTO_VEHICLE(attackerFlag, vehicle, i)
                        if i % 2 == 0 then
                            WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                            PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                        else
                            WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 9999, false, true)
                            PED.SET_PED_FIRING_PATTERN(attackerFlag, -957453492)
                        end
                        PED.SET_PED_AS_COP(attackerFlag, true)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 20.0)
                        VEHICLE.SET_VEHICLE_MAX_SPEED(vehicle, 200.0)
                        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(TankToggleGod))
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
                        ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(TankToggleGod))
                        if i == -1 then
                            TASK.TASK_VEHICLE_CHASE(attackerFlag, targetPed)
                            WEAPON.GIVE_WEAPON_TO_PED(attackerFlag, 584646201 , 1000, false, true)
                        else
                            TASK.TASK_COMBAT_PED(attackerFlag, targetPed, 0, 16)
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
    
        function RequestControlOfEntity(ent, time)
            if ent and ent ~= 0 then
                local end_time = os.clock() + (time or 3)
                while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) and os.clock() < end_time do
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
                    util.yield()
                end
                return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent)
            end
            return false
        end

        local function ends_with(str, ending)
            return ending == "" or str:sub(-#ending) == ending
        end

        function UpdateAutoMusics()
            Music_TempFiles = {}
            for i, path in ipairs(filesystem.list_files(script_store_songs)) do
                local file_str = path:gsub(script_store_songs, ''):gsub("\\","")
                if ends_with(file_str, '.wav') then
                    Music_TempFiles[#Music_TempFiles+1] = file_str
                end
            end
            InterMusicFiles = Music_TempFiles
        end
        UpdateAutoMusics()

        function join_path(parent, child)
            local sub = parent:sub(-1)
            if sub == "/" or sub == "\\" then
                return parent .. child
            else
                return parent .. "/" .. child
            end
        end

        current_sound_handle = nil

        function InterLoading(directory)
            local InterLoadedSongs = {}
            for _, filepath in ipairs(filesystem.list_files(directory)) do
                local _, filename, ext = string.match(filepath, "(.-)([^\\/]-%.?([^%.\\/]*))$")
                if not filesystem.is_dir(filepath) and ext == "wav" then
                    local name = string.gsub(filename, "%.wav$", "")
                    local sound_location = join_path(directory, filename)
                    InterLoadedSongs[#InterLoadedSongs + 1] = {file=name, sound=sound_location}
                end
            end
            return InterLoadedSongs
        end
        
        song_files = filesystem.list_files(script_store_songs)

        songs_direct = join_path(script_store_songs, "")
        InterLoadedSongs = InterLoading(songs_direct)
        InterMusicFiles = {}
        song_files = {}
        for _, song in ipairs(InterLoadedSongs) do
            InterMusicFiles[#InterMusicFiles + 1] = song.file
            song_files[song.file] = true
        end

        function CheckSongs()
            local new_song_files = filesystem.list_files(script_store_songs)
            for _, song_path in ipairs(new_song_files) do
                if not song_files[song_path] and string.match(song_path, "%.wav$") then
                    InterLoadedSongs = InterLoading(songs_direct)
                    InterMusicFiles = {}
                    for _, song in ipairs(InterLoadedSongs) do
                        InterMusicFiles[#InterMusicFiles + 1] = song.file
                        song_files[song.file] = true
                    end
                    break
                end
            end
        end
        
        function PlayAuto(sound_location)
            if current_sound_handle then
                current_sound_handle = nil
            end
            current_sound_handle = PlaySong(sound_location, SND_FILENAME | SND_ASYNC)
        end

        added_files = {}
        songs_direct = join_path(script_store_songs, "")
        InterLoadedSongs = InterLoading(songs_direct)
        
        function check_music_folder()
            local InterMusicFiles = {}
            for _, song in ipairs(InterLoadedSongs) do
                InterMusicFiles[#InterMusicFiles + 1] = song.file
                song_files[song.file] = true
            end
            local current_files = {}
            for i, path in ipairs(filesystem.list_files(script_store_songs)) do
                local file_str = path:gsub(script_store_songs, ''):gsub("\\","")
                if ends_with(file_str, '.wav') and not song_files[file_str] then
                    current_files[#current_files+1] = file_str
                end
            end
            
            -- Check for removed files
            for i, file in ipairs(InterMusicFiles) do
                local sound_location = join_path(script_store_songs, file .. ".wav")
                if not filesystem.exists(sound_location) then
                    for j, song in ipairs(InterLoadedSongs) do
                        if song.file == file then
                            table.remove(InterLoadedSongs, j)
                            InterNotify("Removed Music: " .. file)
                            break
                        end
                    end
                    table.remove(InterMusicFiles, i)
                    song_files = {}
                    for _, name in ipairs(InterMusicFiles) do
                        song_files[name .. ".wav"] = true
                    end
                end
            end
            
            -- Check for new files
            for _, file in ipairs(current_files) do
                if not song_files[file] and not added_files[file] then
                    local sound_location = join_path(script_store_songs, file)
                    if filesystem.exists(sound_location) then
                        local file_name = string.gsub(file, "%.wav$", "")
                        local song_found = false
                        for _, song in ipairs(InterLoadedSongs) do
                            if song.file == file_name then
                                song_found = true
                                break
                            end
                        end
                        if not song_found then
                            InterLoadedSongs[#InterLoadedSongs + 1] = {file=file_name, sound=sound_location}
                            InterMusicFiles[#InterMusicFiles + 1] = file_name
                            song_files[file] = true
                            added_files[file] = true
                            InterNotify("New Music Added: " .. file_name)
                        end
                    end
                end
            end
        end
        
        function ls_log(content)
            if ls_debug then
                util.toast(content)
            end
        end
    
        object_uses = 0
        function mod_uses(type, incr)
            if incr < 0 and is_loading then
                ls_log("Not incrementing use var of type " .. type .. " by " .. incr .. "- script is loading")
                return
            end
            ls_log("Incrementing use var of type " .. type .. " by " .. incr)
            if type == "vehicle" then
                if vehicle_uses <= 0 and incr < 0 then
                    return
                end
                vehicle_uses = vehicle_uses + incr
            elseif type == "pickup" then
                if pickup_uses <= 0 and incr < 0 then
                    return
                end
                pickup_uses = pickup_uses + incr
            elseif type == "ped" then
                if ped_uses <= 0 and incr < 0 then
                    return
                end
                ped_uses = ped_uses + incr
            elseif type == "player" then
                if player_uses <= 0 and incr < 0 then
                    return
                end
                player_uses = player_uses + incr
            elseif type == "object" then
                if object_uses <= 0 and incr < 0 then
                    return
                end
                object_uses = object_uses + incr
            end
        end
    
        function is_entity_a_projectile_all(hash)
            local all_projectile_hashes = {
                util.joaat("w_ex_vehiclemissile_1"),
                util.joaat("w_ex_vehiclemissile_2"),
                util.joaat("w_ex_vehiclemissile_3"),
                util.joaat("w_ex_vehiclemissile_4"),
                util.joaat("w_ex_vehiclemortar"),
                util.joaat("w_ex_apmine"),
                util.joaat("w_ex_arena_landmine_01b"),
                util.joaat("w_ex_birdshat"),
                util.joaat("w_ex_grenadefrag"),
                util.joaat("xm_prop_x17_mine_01a"),
                util.joaat("xm_prop_x17_mine_02a"),
                util.joaat("w_ex_grenadesmoke"),
                util.joaat("w_ex_molotov"),
                util.joaat("w_ex_pe"),
                util.joaat("w_ex_pipebomb"),
                util.joaat("w_ex_snowball"),
                util.joaat("w_lr_rpg_rocket"),
                util.joaat("w_lr_homing_rocket"),
                util.joaat("w_lr_firework_rocket"),
                util.joaat("xm_prop_x17_silo_rocket_01"),
                util.joaat("w_ex_vehiclegrenade"),
                util.joaat("w_ex_vehiclemine"),
                util.joaat("w_lr_40mm"),
                util.joaat("w_smug_bomb_01"),
                util.joaat("w_smug_bomb_02"),
                util.joaat("w_smug_bomb_03"),
                util.joaat("w_smug_bomb_04"),
                util.joaat("w_am_flare"),
                util.joaat("w_arena_airmissile_01a"),
                util.joaat("w_pi_flaregun_shell"),
                util.joaat("w_smug_airmissile_01b"),
                util.joaat("w_smug_airmissile_02"),
                util.joaat("w_sr_heavysnipermk2_mag_ap2"),
                util.joaat("w_battle_airmissile_01"),
                util.joaat("gr_prop_gr_pmine_01a")
                }
            return table.contains(all_projectile_hashes, hash)
        end
    
        function is_entity_a_missle(hash) 
            local missle_hashes = {
                util.joaat("w_ex_vehiclemissile_1"),
                util.joaat("w_ex_vehiclemissile_2"),
                util.joaat("w_ex_vehiclemissile_3"),
                util.joaat("w_ex_vehiclemissile_4"),
                util.joaat("w_lr_rpg_rocket"),
                util.joaat("w_lr_homing_rocket"),
                util.joaat("w_lr_firework_rocket"),
                util.joaat("xm_prop_x17_silo_rocket_01"),
                util.joaat("w_arena_airmissile_01a"),
                util.joaat("w_smug_airmissile_01b"),
                util.joaat("w_smug_airmissile_02"),
                util.joaat("w_battle_airmissile_01"),
                util.joaat("h4_prop_h4_airmissile_01a")
                }
            return table.contains(missle_hashes, hash)
        end
    
        function is_entity_a_grenade(hash)   
            local grenade_hashes = {
                util.joaat("w_ex_vehiclemortar"),
                util.joaat("w_ex_grenadefrag"),
                util.joaat("w_ex_grenadesmoke"),
                util.joaat("w_ex_molotov"),
                util.joaat("w_ex_pipebomb"),
                util.joaat("w_ex_snowball"),
                util.joaat("w_ex_vehiclegrenade"),
                util.joaat("w_lr_40mm")
            }
            return table.contains(grenade_hashes, hash)
        end
    
        objects_thread = util.create_thread(function(thr)
            while true do
                if object_uses > 0 then
                    all_objects = entities.get_all_objects_as_handles()
                    for k,obj in pairs(all_objects) do
                        if is_entity_a_projectile_all(ENTITY.GET_ENTITY_MODEL(obj)) then  --Edit Proj Offsets Here
                            if projectile_spaz then 
                                local strength = 20
                                ENTITY.APPLY_FORCE_TO_ENTITY(obj, 1, math.random(-strength, strength), math.random(-strength, strength), math.random(-strength, strength), 0.0, 0.0, 0.0, 1, true, false, true, true, true)
                            end
                            if slow_projectiles then
                                ENTITY.SET_ENTITY_MAX_SPEED(obj, 0.5)
                            end
                            if InterTAPSVehicle then
                                local gce_all_objects = entities.get_all_objects_as_handles()
                                local Range = InterTAPSRange
                                local RangeSq = Range * Range
                                local EntitiesToTarget = {}
                                for index, entity in pairs(gce_all_objects) do
                                    if is_entity_a_missle(ENTITY.GET_ENTITY_MODEL(entity)) or is_entity_a_grenade(ENTITY.GET_ENTITY_MODEL(entity)) then
                                        local EntityCoords = ENTITY.GET_ENTITY_COORDS(entity)
                                        local VehCoords = ENTITY.GET_ENTITY_COORDS(entities.get_user_vehicle_as_handle())
                                        local ObjPointers = entities.get_all_objects_as_pointers()
                                        local vdist = SYSTEM.VDIST2(VehCoords.x, VehCoords.y, VehCoords.z, EntityCoords.x, EntityCoords.y, EntityCoords.z)
                                        if vdist <= RangeSq then
                                            EntitiesToTarget[#EntitiesToTarget+1] = entities.pointer_to_handle(ObjPointers[index])
                                        end
                                        if EntitiesToTarget ~= nil then
                                            local dist = 999999
                                            for i = 1, #EntitiesToTarget do
                                                local tarcoords = ENTITY.GET_ENTITY_COORDS(EntitiesToTarget[index])
                                                local e = SYSTEM.VDIST2(VehCoords.x, VehCoords.y, VehCoords.z, EntityCoords.x, EntityCoords.y, EntityCoords.z)
                                                if e < dist then
                                                    dist = e
                                                    local closestEntity = entity
                                                    local ProjLocation = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(closestEntity, 0, 0, 0)
                                                    local ProjRotation = ENTITY.GET_ENTITY_ROTATION(closestEntity)
                                                    local lookAtProj = v3.lookAt(VehCoords, EntityCoords)
                                                    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_sm_counter")
                                                    STREAMING.REQUEST_NAMED_PTFX_ASSET("core") 
                                                    STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_gr_vehicle_weapons")
                                                    if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_sm_counter") and STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") and STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("veh_xs_vehicle_mods") then
                                                        ENTITY.SET_ENTITY_ROTATION(entity, lookAtProj.x - 180, lookAtProj.y, lookAtProj.z, 1, true)
                                                        lookAtPos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, 0, Range - 2, 0)
                                                        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sm_counter")
                                                        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_sm_counter_chaff", ProjLocation.x, ProjLocation.y, ProjLocation.z, ProjRotation.x + 90, ProjRotation.y, ProjRotation.z, 1, 0, 0, 0)
                                                        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                                                        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("exp_grd_sticky", ProjLocation.x, ProjLocation.y, ProjLocation.z, ProjRotation.x - 90, ProjRotation.y, ProjRotation.z, 0.2, 0, 0, 0)
                                                        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_gr_vehicle_weapons")
                                                        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("muz_mounted_turret_apc_missile", lookAtPos.x, lookAtPos.y, lookAtPos.z + .2, lookAtProj.x + 180, lookAtProj.y, lookAtProj.z, 1.3, 0, 0, 0)
                                                        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_gr_vehicle_weapons")
                                                        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("muz_mounted_turret_apc", lookAtPos.x, lookAtPos.y, lookAtPos.z + .2, lookAtProj.x + 180, lookAtProj.y, lookAtProj.z, 1.3, 0, 0, 0)
                                                        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_gr_vehicle_weapons")
                                                        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("muz_mounted_turret_apc_missile", lookAtPos.x, lookAtPos.y, lookAtPos.z + .2, lookAtProj.x + 180, lookAtProj.y, lookAtProj.z, 1.3, 0, 0, 0)
                                                        GRAPHICS.USE_PARTICLE_FX_ASSET("weap_gr_vehicle_weapons")
                                                        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("muz_mounted_turret_apc", lookAtPos.x, lookAtPos.y, lookAtPos.z + .2, lookAtProj.x + 180, lookAtProj.y, lookAtProj.z, 1.3, 0, 0, 0)
                                                        entities.delete_by_handle(entity)
                                                        IntAPS_charges = IntAPS_charges - 1
                                                        InterNotify("APS Destroyed Incoming Projectile.\n"..IntAPS_charges.."/"..InterTAPSCharges.." APS Shells Left.")
                                                        if IntAPS_charges == 0 then
                                                            InterNotify("No APS Shells Left. \nReloading...")
                                                            util.yield(InterTAPSTimeout)
                                                            IntAPS_charges = InterTAPSCharges
                                                            InterNotify("APS Ready.")
                                                        end
                                                    else
                                                        for i = 0, 10, 1 do
                                                            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_sm_counter")
                                                            STREAMING.REQUEST_NAMED_PTFX_ASSET("core") 
                                                            STREAMING.REQUEST_NAMED_PTFX_ASSET("veh_xs_vehicle_mods")
                                                        end
                                                        if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_sm_counter") or STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") or STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("veh_xs_vehicle_mods") then
                                                            InterNotify("Could not Load Particle Effect.")
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end 
                        end
                    end
                end
                util.yield()
            end
        end)

        function OrbitalRequest(Position)
            local entityPed = players.user_ped()
            FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z + 1, 59, 1, true, false, 1.0, false)
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 1.0, true, true, true)
                STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                util.yield(0)
            end
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z + 1, 0, 180, 0, 1.0, true, true, true)
            for i = 1, 4 do
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", entityPed, 0, true, false)
            end
        end

        function get_distance_between(pos1, pos2)
            if math.type(pos1) == "integer" then
                pos1 = ENTITY.GET_ENTITY_COORDS(pos1)
            end
            if math.type(pos2) == "integer" then 
                pos2 = ENTITY.GET_ENTITY_COORDS(pos2)
            end
            return pos1:distance(pos2)
        end

        function CreateNuke(Position, Named) -- Shortcut of Nuke Features
            local Owner
            if Named then
                Owner = players.user_ped()
            else
                Owner = 0
            end
            local function spawn_explosion()
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                    util.yield(0)
                end
                FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z, 59, 1, true, false, 5.0, false)
                GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z, 0, 180, 0, 4.5, true, true, true)
            end
            for i = 1, 7 do
                spawn_explosion()
            end
            for i=-30,30,10 do
                for j=-30,30,10 do
                    if i~=0 or j~=0 then
                        FIRE.ADD_EXPLOSION(Position.x+i, Position.y+j, Position.z, 59, 1.0, true, false, 1.0, false)
                    end
                end
            end

            for i = 1, 4 do
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "DLC_XM_Explosions_Orbital_Cannon", players.user_ped(), 0, true, false)
            end
            
            offsets = {{10, 30}, {30, 10}, {-30, -10}, {-10, -30}, {-10, 30}, {-30, 10}, {30,-10}, {10,-30}}
            for _, offset in ipairs(offsets) do
                local x_offset = offset[1]
                local y_offset = offset[2]
                FIRE.ADD_EXPLOSION(Position.x + x_offset ,Position.y + y_offset ,Position.z ,59 ,1.0 ,true ,false ,1.0 ,false)
            end
            local coords = {1, 3, 5, 7, 10, 12, 15, 17}

            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_xm_orbital") do
                STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                util.yield(0)
            end

            for i = 1, #coords do
                if coords[i] % 2 ~= 0 then
                    FIRE.ADD_EXPLOSION(Position.x, Position.y, Position.z+coords[i], 59, 1, true, false, 5.0, false)
                end
                GRAPHICS.USE_PARTICLE_FX_ASSET("scr_xm_orbital")
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+coords[i], 0, 180, 0, 1.5, true, true, true)
                util.yield(10)
            end
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_xm_orbital_blast", Position.x, Position.y, Position.z+80, 0, 0, 0, 3, true, true, true)

            for pid = 0, 31 do
                if players.exists(pid) and get_distance_between(players.get_position(pid), Position) < 200 then
                    local pid_pos = players.get_position(pid)
                    FIRE.ADD_EXPLOSION(pid_pos.x, pid_pos.y, pid_pos.z, 59, 1.0, true, false, 1.0, false)
                end
            end

            local peds = entities.get_all_pickups_as_handles()
            for i = 1, #peds do
                if get_distance_between(peds[i], Position) < 400 and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(peds[i]) ~= players.user() then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds[i])
                    local ped_pos = ENTITY.GET_ENTITY_COORDS(peds[i], false)
                    FIRE.ADD_EXPLOSION(ped_pos.x, ped_pos.y, ped_pos.z, 3, 1.0, true, false, 0.1, false)
                    PED.SET_PED_TO_RAGDOLL(peds[i], 1000, 1000, 0, false, false, false)
                end
            end

            local vehicles = entities.get_all_vehicles_as_handles()
            for i = 1, #vehicles do
                if get_distance_between(vehicles[i], Position) < 400 then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicles[i], -999.90002441406)
                    VEHICLE.EXPLODE_VEHICLE(vehicles[i], true, false)
                elseif get_distance_between(vehicles[i], Position) < 400 then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicles[i], -4000)
                end
            end
        end

        function get_offset_from_gameplay_camera(distance)
            local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
            local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
            local direction = v3.toDir(cam_rot)
            local destination = {
            x = cam_pos.x + direction.x * distance, 
            y = cam_pos.y + direction.y * distance, 
            z = cam_pos.z + direction.z * distance 
            }
            return destination
        end

        function SendRequestModel(Hash)
            if STREAMING.IS_MODEL_VALID(Hash) then
                STREAMING.REQUEST_MODEL(Hash)
                while not STREAMING.HAS_MODEL_LOADED(Hash) do
                    STREAMING.REQUEST_MODEL(Hash)
                    util.yield()
                end
            end
        end

        vect = {
            ['new'] = function(x, y, z)
                return {['x'] = x, ['y'] = y, ['z'] = z}
        end,
            ['subtract'] = function(a, b)
                return vect.new(a.x-b.x, a.y-b.y, a.z-b.z)
        end,
            ['add'] = function(a, b)
                return vect.new(a.x+b.x, a.y+b.y, a.z+b.z)
        end,
            ['mag'] = function(a)
                return math.sqrt(a.x^2 + a.y^2 + a.z^2)
        end,
            ['norm'] = function(a)
                local mag = vect.mag(a)
                return vect.div(a, mag)
        end,
            ['mult'] = function(a, b)
                return vect.new(a.x*b, a.y*b, a.z*b)
        end, 
            ['div'] = function(a, b)
                return vect.new(a.x/b, a.y/b, a.z/b)
        end, 
            ['dist'] = function(a, b) --returns the distance between two vectors
                return vect.mag(vect.subtract(a, b) )
        end
        }

        function MPPLY_STAT_EFFECT(stat)
            local MpplyStats = {
                "MP_PLAYING_TIME",
                "MP_NGDLCPSTAT_INT0",
                
                "MP_TUPSTAT_INT0",
                "MP_TUPSTAT_INT1",
                "MP_TUPSTAT_INT2",
                "MP_TUPSTAT_INT3",
                "MP_TUPSTAT_BOOL0",
                "MP_NGPSTAT_INT0",
                "MP_NGPSTAT_BOOL0",
                "MP_NGDLCPSTAT_BOOL0",
                "MP_PLAYING_TIME_NEW",
                "MP_PSTAT_BOOL0",
                "MP_PSTAT_BOOL1",
                "MP_PSTAT_BOOL2",
                "MP_PSTAT_INT0",
                "MP_PSTAT_INT1",
                "MP_PSTAT_INT2",
            }
            for _, mpply_stat in pairs(MpplyStats) do
                if stat == mpply_stat then
                    return true
                end
            end
    
            if string.find(stat, "MPPLY_") then
                return true
            else
                return false
            end
        end

        function ADD_MP_INDEX(stat) 
            if not MPPLY_STAT_EFFECT(stat) then
                stat = "MP" .. util.get_char_slot() .. "_" .. stat
            end
            return stat
        end

        function STAT_SET_INT(stat, value)
            STATS.STAT_SET_INT(util.joaat(ADD_MP_INDEX(stat)), value, true)
        end

        function SET_FLOAT_GLOBAL(global, value)
            memory.write_float(memory.script_global(global), value)
        end

        function SET_INT_GLOBAL(global, value)
            memory.write_int(memory.script_global(global), value)
        end

        function SET_PACKED_INT_GLOBAL(start_global, end_global, value)
            for i = start_global, end_global do
                SET_INT_GLOBAL(262145 + i, value)
            end
        end

        function GET_INT_GLOBAL(global)
            return memory.read_int(memory.script_global(global))
        end

        function Create_Network_Pickup(pickupHash, x, y, z, modelHash, value)
            SendRequestModel(modelHash)
            local pickup = OBJECT.CREATE_AMBIENT_PICKUP(pickupHash, x, y, z, 4, value, modelHash, false, true)
        
            OBJECT.SET_PICKUP_OBJECT_COLLECTABLE_IN_VEHICLE(pickup)
        
            ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(pickup, true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pickup, true, false)
            ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(pickup, true)
        
            NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(pickup)
            local net_id = NETWORK.OBJ_TO_NET(pickup)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
            for _, player in pairs(players.list(true, true, true)) do
                NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
            end
        
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
            return pickup
        end

        function BlockSyncs(pid, callback)
            for _, i in players.list(false, true, true) do
                if i ~= pid then
                    local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
                    menu.trigger_command(outSync, "on")
                end
            end
            util.yield(10)
            callback()
            for _, i in players.list(false, true, true) do
                if i ~= pid then
                    local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
                    menu.trigger_command(outSync, "off")
                end
            end
        end

        function load_weapon_asset(hash)
            while not WEAPON.HAS_WEAPON_ASSET_LOADED(hash) do
                WEAPON.REQUEST_WEAPON_ASSET(hash)
                util.yield(50)
            end
        end

        function KillPassive(pid)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local hash = 0x787F0BB
        
            local audible = true
            local visible = true
        
            load_weapon_asset(hash)
            
            for i = 0, 50 do
                if PLAYER.IS_PLAYER_DEAD(pid) then
                    InterNotify("Successfully killed " .. players.get_name(pid))
                    return
                end
        
                local coords = ENTITY.GET_ENTITY_COORDS(ped)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 2, 100, 0, hash, 0, audible, not visible, 2500)
                
                util.yield(10)
            end
        
            InterNotify("We are not able to kill " .. players.get_name(pid) .. ".\nVerify if the player is not in ragdoll mode or godmode.")
        end

        function KillSilent(pid)
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local PName = players.get_name(pid)
            for i = 0, 50 do
                if PLAYER.IS_PLAYER_DEAD(pid) then
                    InterNotify(PName.." has been silently killed.")
                    return
                end

                local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
                FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'] + 2, 7, 1000, false, true, 0)
                util.yield(10)
            end

            InterNotify(PName.. " could not silently killed.")
        end

        function driverRequest(entity)
            if not NETWORK.NETWORK_IS_IN_SESSION() then
                return true
            end
            local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netid, true)
            return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        end

        function getRangeOfVehicle(player, radius)
            local vehicles = {}
            local pos = players.get_position(player)
            for _, vehicle in entities.get_all_vehicles_as_handles() do
                local vehPos = ENTITY.GET_ENTITY_COORDS(vehicle, true)
                if pos:distance(vehPos) <= radius then table.insert(vehicles, vehicle) end
            end
            return vehicles
        end

        function Create_Network_Object(modelHash, x, y, z)
            SendRequestModel(modelHash)
            local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(modelHash, x, y, z, true, true, false)
            ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(obj, true)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, false)
            ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)

            NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
            local net_id = NETWORK.OBJ_TO_NET(obj)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(net_id, true)
            for _, player in pairs(players.list(true, true, true)) do
                NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(net_id, player, true)
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
            return obj
        end

        function SendRequestEntity(hash, timeout)
            timeout = timeout or 3
            STREAMING.REQUEST_MODEL(hash)
            local end_time = os.time() + timeout
            repeat
                util.yield()
            until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
            return STREAMING.HAS_MODEL_LOADED(hash)
        end

        vect = {
            ['new'] = function(x, y, z)
                return {['x'] = x, ['y'] = y, ['z'] = z}
        end,
            ['subtract'] = function(a, b)
                return vect.new(a.x-b.x, a.y-b.y, a.z-b.z)
        end,
            ['add'] = function(a, b)
                return vect.new(a.x+b.x, a.y+b.y, a.z+b.z)
        end,
            ['mag'] = function(a)
                return math.sqrt(a.x^2 + a.y^2 + a.z^2)
        end,
            ['norm'] = function(a)
                local mag = vect.mag(a)
                return vect.div(a, mag)
        end,
            ['mult'] = function(a, b)
                return vect.new(a.x*b, a.y*b, a.z*b)
        end, 
            ['div'] = function(a, b)
                return vect.new(a.x/b, a.y/b, a.z/b)
        end, 
            ['dist'] = function(a, b) --returns the distance between two vectors
                return vect.mag(vect.subtract(a, b) )
        end
        }

        function getOffsetFromEntityGivenDistance(entity, distance)
            local pos = ENTITY.GET_ENTITY_COORDS(entity, 0)
            local theta = (math.random() + math.random(0, 1)) * math.pi --returns a random angle between 0 and 2pi (exclusive)
            local coords = vect.new(
                pos.x + distance * math.cos(theta),
                pos.y + distance * math.sin(theta),
                pos.z
            )
            return coords
        end

        function setAttribute(attacker)
            PED.SET_PED_COMBAT_ATTRIBUTES(attacker, 46, true)
            PED.SET_PED_COMBAT_RANGE(attacker, 4)
            PED.SET_PED_COMBAT_ABILITY(attacker, 3)
        end

    ---========================================----
    ---        Other Parts for Functions
    ---          The part of other roots
    ----========================================----
    
        explosion_types = {
            [0] = {"Grenade"},
            [1] = {"Grenade Launcher"},
            [2] = {"Sticky Bomb"},
            [3] = {"Molotov"},
            [4] = {"Rocket"},
            [5] = {"Tankshell"},
            [6] = {"High Octane"},
            [7] = {"Car"},
            [8] = {"Plane"},
            [9] = {"Oil Pump"},
            [10] = {"Bike"},
            [11] = {"Steam"},
            [12] = {"Flame"},
            [13] = {"Water Hydrant"},
            [14] = {"Gas Canister"},
            [15] = {"Boat"},
            [16] = {"Ship"},
            [17] = {"Truck"},
            [18] = {"Bullet"},
            [19] = {"Smoke Grenade Launcher"},
            [20] = {"Smoke Grenade"},
            [21] = {"BZ Gas"},
            [22] = {"Flare"},
            [23] = {"Gas Canister"},
            [24] = {"Extinguisher"},
            [25] = {"Programmable AR"},
            [26] = {"Train"},
            [27] = {"Barrel"},
            [28] = {"Propane"},
            [29] = {"Blimp"},
            [30] = {"Flame Explode"},
            [31] = {"Tanker"},
            [32] = {"Plane Rocket"},
            [33] = {"Vehicle Bullet"},
            [34] = {"Gas Tank"},
            [36] = {"Railgun"},
            [37] = {"Blimp 2"},
            [38] = {"Firework"},
            [39] = {"Snowball"},
            [40] = {"Proximity Mine"},
            [41] = {"Valkyrie Cannon"},
            [42] = {"Air Defence"},
            [43] = {"Pipe Bomb"},
            [44] = {"Vehicle Mine"},
            [45] = {"Explosive Ammo"},
            [46] = {"APC Shell"},
            [47] = {"Cluster Bomb"},
            [48] = {"Gas Bomb"},
            [49] = {"Incendiary Bomb"},
            [50] = {"Standard Bomb"},
            [51] = {"Torpedo"},
            [52] = {"Underwater Torpedo"},
            [53] = {"Bombushka Cannon"},
            [54] = {"Cluster Bomb 2"},
            [55] = {"Hunter Barrage"},
            [56] = {"Hunter Cannon"},
            [57] = {"Rogue Cannon"},
            [58] = {"Underwater Mine"},
            [59] = {"Orbital Cannon"},
            [60] = {"Bomb Standard Wide"},
            [61] = {"Explosive Shotgun Ammo"},
            [62] = {"Oppressor MKII Cannon"},
            [63] = {"Mortar Kinetic"},
            [64] = {"Kinetic Mine"},
            [65] = {"EMP Mine"},
            [66] = {"Spike Mine"},
            [67] = {"Slick Mine"},
            [68] = {"Tar Mine"},
            [69] = {"Drone"},
            [70] = {"Up-n-Atomizer"},
            [71] = {"Buried Mine"},
            [72] = {"Missile"},
            [73] = {"RC Tank Rocket"},
            [74] = {"Water Bomb"},
            [75] = {"Water Bomb 2"},
            [78] = {"Flash Grenade"},
            [79] = {"Stun Grenade"},
            [81] = {"Large Missile"},
            [82] = {"Big Submarine"},
            [83] = {"EMP Launcher"}
        }

        property_id = {
            [1] = {"Eclipse Towers 31"},
            [2] = {"Eclipse Towers 9"},
            [3] = {"Eclipse Towers 40"},
            [4] = {"Eclipse Towers 5"},
            [5] = {"3 Alta St, Apt 10"},
            [6] = {"3 Alta St, Apt 57"},
            [7] = {"Del Perro Heights, Apt 20"},
            [8] = {"1162 Power St, Apt 3"},
            [9] = {"0605 Spanish Ave, Apt 1"},
            [10] = {"0604 Las Lagunas Blv, 4"},
            [11] = {"0184 Milton Rd, Apt 13"},
            [12] = {"The Royale, Apt 19"},
            [13] = {"S Mo Milton Drive"},
            [14] = {"Bay City Ave, Apt 45"},
            [15] = {"0325 S Rockford Dr"},
            [16] = {"Dream Tower, Apt 15"},
            [17] = {"Las Lagunas Blv, 9"},
            [18] = {"San Vitas St, Apt 2"},
            [19] = {"0112 S Rockford Dr, 13"},
            [20] = {"Vespucci Blvd, Apt 1"},
            [21] = {"Cougar Ave, Apt 19"},
            [22] = {"Prosperity St, 21"},
            [23] = {"Blvd Del Perro, 18"},
            [24] = {"Murrieta Heights"},
            [25] = {"Unit 14 Popular St"},
            [26] = {"Unit 2 Popular St"},
            [27] = {"331 Supply St"},
            [28] = {"Unit 1 Olympic Fwy"},
            [29] = {"0754 Roy Lowenstein Blvd"},
            [30] = {"Little Bighorn Ave"},
            [31] = {"Unit 124 Popular St"},
            [32] = {"0502 Roy Lowenstein Blvd"},
            [33] = {"0432 Davis Ave"},
            [34] = {"Del Perro Heights, 7"},
            [35] = {"Weazel Plaza, 101"},
            [36] = {"Weazel Plaza, 70"},
            [37] = {"Weazel Plaza, 26"},
            [38] = {"Integrity Way, 30"},
            [39] = {"Integrity Way, 35"},
            [40] = {"Richards Majestic, 4"},
            [41] = {"Richards Majestic, 51"},
            [42] = {"Tinsel Towers, Apt 45"},
            [43] = {"Tinsel Towers, Apt 29"},
            [44] = {"Paleto Blvd"},
            [45] = {"Strawberry Ave"},
            [46] = {"Grapeseed Ave"},
            [47] = {"Senora Way"},
            [48] = {"Great Ocean Highway"},
            [49] = {"197 Route 68"},
            [50] = {"870 Route 68"},
            [51] = {"1200 Route 68"},
            [52] = {"8754 Route 68"},
            [53] = {"1905 Davis Ave"},
            [54] = {"South Shambles St"},
            [55] = {"4531 Dry Dock St"},
            [56] = {"Exceptionalists Way"},
            [57] = {"Greenwich Parkway"},
            [58] = {"Innocence Blvd"},
            [59] = {"Blvd Del Perro"},
            [60] = {"Mirror Park Blvd"},
            [61] = {"Eclipse Towers 3"},
            [62] = {"Del Perro Heights 4"},
            [63] = {"Richards Majestics, 2"},
            [64] = {"Tinsel Towers, Apt 42"},
            [65] = {"Integrity Way, 28"},
            [66] = {"4 Hangman Ave"},
            [67] = {"12 Sustancia Rd"},
            [68] = {"4584 Procopio Dr"},
            [69] = {"4401 Procopio Dr"},
            [70] = {"0232 Paleto Blvd"},
            [71] = {"140 Zancudo Ave"},
            [72] = {"1893 Grapeseed Ave"},
            [73] = {"3655 Wild Oats Dr"},
            [74] = {"2044 North Conker Ave"},
            [75] = {"2868 Hillcrest Ave"},
            [76] = {"2862 Hillcrest Ave"},
            [77] = {"3677 Whispymound Dr"},
            [78] = {"2117 Milton Rd"},
            [79] = {"2866 Hillcrest Ave"},
            [80] = {"2874 Hillcrest Ave"},
            [81] = {"2113 Mad Wayne T Dr"},
            [82] = {"2045 North Conker Ave"},
            [83] = {"Eclipse Penthouse, Suite 1"},
            [84] = {"Eclipse Penthouse, Suite 2"},
            [85] = {"Eclipse Penthouse, Suite 3"},
            [86] = {"Invalid (Private Yacht)"},
            [87] = {"Lombank West"},
            [88] = {"Maze Bank West"},
            [89] = {"Arcadius"},
            [90] = {"Maze Bank Tower"},
            [91] = {"Rancho Clubhouse"},
            [92] = {"Del Perro Beach Clubhouse"},
            [93] = {"Philbox Hill Clubhouse"},
            [94] = {"Great Chaparral Clubhouse"},
            [95] = {"Paleto Bay Clubhouse"},
            [96] = {"Sandy Shores Clubhouse"},
            [97] = {"La Mesa Clubhouse"},
            [98] = {"Vinewood Clubhouse"},
            [99] = {"Hawick Clubhouse"},
            [100] = {"Grapeseed Clubhouse"},
            [101] = {"Paleto Bay Clubhouse (0)"},
            [102] = {"Vespucci Beach Clubhouse"},
            [103] = {"Office Garage 1 (Lombank)"},
            [104] = {"Office Garage 2 (Lombank)"},
            [105] = {"Office Garage 3 (Lombank)"},
            [106] = {"Office Garage 1 (Maze Bank West)"},
            [107] = {"Office Garage 2 (Maze Bank West)"},
            [108] = {"Office Garage 3 (Maze Bank West)"},
            [109] = {"Office Garage 1 (Arcadius)"},
            [110] = {"Office Garage 2 (Arcadius)"},
            [111] = {"Office Garage 3 (Arcadius)"},
            [112] = {"Office Garage 1 (Maze Bank Tower)"},
            [113] = {"Office Garage 2 (Maze Bank Tower)"},
            [114] = {"Office Garage 3 (Maze Bank Tower)"}
        }

        randomSongs = {
            "BadToTheBone",
            "CaliforniaDreamin",
            "RuleTheWorld",
            "FortunateSon",
            "PaintItBlack",
            "Paranoid",
            "MaterialGirl",
            "HighwayToHell",
        }
--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
