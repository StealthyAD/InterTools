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

    Part: Weapons
]]--

    ---========================================----
    ---             Weapons Roots
    ---         The part of weaps roots
    ----========================================----
    
        local WeaponsParts = InterRoot:list("Weapon Parts", {"intweapons"})
        local WeaponTweaks = WeaponsParts:list("Weapons Tweaks")
        local ReloadTweaks = WeaponsParts:list("Reload Tweaks")
        local EntityTweaks = WeaponsParts:list("Entity Tweaks")

    ----========================================----
    ---              Weapons Parts
    ---     The part of weapons adding tweaks
    ----========================================----

        NVision = WeaponTweaks:toggle_loop("Night Vision Scope" ,{}, "Press E while aiming to activate.\n\nRecommended to use only night time, using daytime can may have complication on your eyes watching the screen.",function()
            if menu.get_value(TVision) then
                menu.set_value(TVision, false)
            end
            local aiming = PLAYER.IS_PLAYER_FREE_AIMING(players.user())
            local InterNV = InterRefBP('Game>Rendering>Night Vision')
            if GRAPHICS.GET_USINGNIGHTVISION() and not aiming then
                InterCmd(InterNV, "off")
                GRAPHICS.SET_NIGHTVISION(false)
            elseif PAD.IS_CONTROL_JUST_PRESSED(38,38) then
                if menu.get_value(InterNV) or not aiming then
                    InterCmd(InterNV, "off")
                    GRAPHICS.SET_NIGHTVISION(false)
                else
                    InterCmd(InterNV, "on")
                    GRAPHICS.SET_NIGHTVISION(true)
                end
            end
        end, function()
            menu.set_value(TVision, false)
        end)

        TVision = WeaponTweaks:toggle_loop("Thermal Vision Scope" ,{}, "Press E while aiming to activate.\n\nBest function to make better wallhack and see through players.",function()
            if menu.get_value(NVision) then
                menu.set_value(NVision, false)
            end
            local aiming = PLAYER.IS_PLAYER_FREE_AIMING(players.user())
            local InterThermal = menu.ref_by_path('Game>Rendering>Thermal Vision')
            if GRAPHICS.GET_USINGSEETHROUGH() and not aiming then
                InterCmd(InterThermal, "off")
                GRAPHICS.SET_SEETHROUGH(false)
                GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(1)
            elseif PAD.IS_CONTROL_JUST_PRESSED(38,38) then
                if menu.get_value(InterThermal) or not aiming then
                    InterCmd(InterThermal, "off")
                    GRAPHICS.SET_SEETHROUGH(false)
                    GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(1)
                else
                    InterCmd(InterThermal, "on")
                    GRAPHICS.SET_SEETHROUGH(true)
                    GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(3500)
                end
            end
        end, function()
            menu.set_value(NVision, false)
        end)

        local InterNR = menu.ref_by_path('Self>Weapons>No Recoil')
        WeaponTweaks:toggle_loop("No Recoil Alt", {}, "Press E while aiming to activate.\n\nRecommended to use standard weapon or RPG.", function()
            if menu.get_value(NVision) or menu.get_value(TVision) then
                menu.set_value(NVision, false)
                menu.set_value(TVision, false)
            end
            local aiming = PLAYER.IS_PLAYER_FREE_AIMING(players.user())
            if not aiming then
                InterCmd(InterNR, 'off')
            elseif PAD.IS_CONTROL_JUST_PRESSED(38, 38) then
                if not menu.get_value(InterNR) then
                    InterCmd(InterNR, 'on')
                else
                    InterCmd(InterNR, 'off')
                end
            end
        end, function()
            menu.set_value(NVision, false)
            menu.set_value(TVision, false)
        end)

    ----========================================----
    ---              Reload Tweaks
    ---    The part of weapons while reloading
    ----========================================----

        ReloadTweaks:toggle_loop("Quick Reload", {}, "Reload faster than normal weapon.\n\nRecommended for big magazine which it's very slow to reload", function()
            if PED.IS_PED_RELOADING(PLAYER.PLAYER_PED_ID()) then
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PLAYER.PLAYER_PED_ID())
            end
        end)

        ReloadTweaks:toggle_loop("Quick Reload while Rolling", {}, "Reload automatically while rolling\n\nRecommended for PvP or something else.", function()
        if TASK.GET_IS_TASK_ACTIVE(PLAYER.PLAYER_PED_ID(), 4) and PAD.IS_CONTROL_PRESSED(2, 22) and not PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
            InterWait(1000)
            WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID())
            end
        end)

        ReloadTweaks:toggle_loop("Quick Weapon Change", {}, "Speed up the action while changing weapon\n\nExample: Changing AP Pistol to RPG/Sniper/Carbine/Shotgun...", function()
            if PED.IS_PED_SWITCHING_WEAPON(PLAYER.PLAYER_PED_ID()) then
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(PLAYER.PLAYER_PED_ID())
            end
        end)

        ReloadTweaks:toggle_loop("No Reload while Shooting", {""}, "Refill Instantly your ammo without reloading while losing ammo.\n\nAlternative to Stand, have the same feature but it will make easier to not reloading.", function() 
            WEAPON.REFILL_AMMO_INSTANTLY(PLAYER.PLAYER_PED_ID())
        end)


    ----========================================----
    ---          Weapons Parts (Others)
    ---           The part of weapons
    ----========================================----

        WeaponsParts:toggle("Infinite Ammo", {"intinfiniteammo"}, "Lock your ammo to get not reloading fire.\n\nAlternative to Stand, has reloading fire. Better alternative to avoid reloading and made reloading easier without losing time.", function(toggle)
            local WeaponHashes = { 
                0x1B06D571,0xBFE256D4,0x5EF9FEC4,0x22D8FE39,0x3656C8C1,0x99AEEB3B,0xBFD21232,0x88374054,0xD205520E,0x83839C4,0x47757124,
                0xDC4DB296,0xC1B3C3D1,0xCB96392F,0x97EA20B8,0xAF3696A1,0x2B5EF5EC,0x917F6C8C,0x13532244,0x2BE6766B,0x78A97CD0,0xEFE7E2DF,
                0xA3D4D34,0xDB1AA450,0xBD248B55,0x476BF155,0x1D073A89,0x555AF99A,0x7846A318,0xE284C527,0x9D61E50F,0xA89CB99E,0x3AABBBAA,
                0xEF951FBB,0x12E82D3D,0xBFEFFF6D,0x394F415C,0x83BF0278,0xFAD1F1C9,0xAF113F99,0xC0A3098D,0x969C3D67,0x7F229F94,0x84D6FAFD,
                0x624FE830,0x9D07F764,0x7FD62962,0xDBBD7280,0x61012683,0x5FC3C11,0xC472FE2,0xA914799,0xC734385A,0x6A6C02E0,0xB1CA77B1,
                0xA284510B,0x4DD2DC56,0x42BF8A85,0x7F7497E5,0x6D544C99,0x63AB0442,0x781FE4A,0xB62D1F67,0x93E220BD,0xA0973D5E,0xFDBC8A50,0x6E7DDDEC,
                0x497FACC3,0x24B17070,0x2C3731D9,0xAB564B93,0x787F0BB,0xBA45E8B8,0x23C9F95C,0xFEA23564,0xDB26713A,0x1BC4FDB9,0xD1D5F52B,0x45CD9CF3,
                0x42BF8A85
            }

            for k,v in WeaponHashes do
                WEAPON.SET_PED_INFINITE_AMMO(players.user_ped(), toggle, v)
                WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), toggle)
            end
        end)

        WeaponsParts:toggle("Friendly Fire", {}, "Toggle Friendly Fire", function(toggle)
            PED.SET_CAN_ATTACK_FRIENDLY(players.user_ped(), toggle, false)
        end)

        WeaponsParts:toggle_loop("Fire Delete Entity Gun", {""}, "Shoot any entities to delete.", function()
            if PLAYER.IS_PLAYER_FREE_AIMING(players.user()) then
                local zEntity = memory.alloc_int()
                if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), zEntity) then
                    local entity = memory.read_int(zEntity)
                    local WeaponHash = WEAPON.GET_SELECTED_PED_WEAPON(players.user())
                    local vehicle = PED.GET_VEHICLE_PED_IS_IN(entity, false) -- returns 0 if ped not in vehicle
                    if vehicle != 0 then
                        if WEAPON.HAS_ENTITY_BEEN_DAMAGED_BY_WEAPON(vehicle, WeaponHash, 2) then
                            entities.delete_by_handle(entity)
                        end
                    end
                    if WEAPON.HAS_ENTITY_BEEN_DAMAGED_BY_WEAPON(entity, WeaponHash, 2) then
                        entities.delete_by_handle(entity)
                    end
                end
            end
            InterWait()
        end)

        WeaponsParts:toggle_loop("Lockon Range Adjuster", {}, "", function()
            PLAYER.SET_PLAYER_LOCKON_RANGE_OVERRIDE(players.user(), 99999999.0)
        end)

        WeaponsParts:action("Fill All Weapons Ammo", {"intfammo"}, "", function()
            local WeaponHashes = { 
                0x1B06D571,0xBFE256D4,0x5EF9FEC4,0x22D8FE39,0x3656C8C1,0x99AEEB3B,0xBFD21232,0x88374054,0xD205520E,0x83839C4,0x47757124,
                0xDC4DB296,0xC1B3C3D1,0xCB96392F,0x97EA20B8,0xAF3696A1,0x2B5EF5EC,0x917F6C8C,0x13532244,0x2BE6766B,0x78A97CD0,0xEFE7E2DF,
                0xA3D4D34,0xDB1AA450,0xBD248B55,0x476BF155,0x1D073A89,0x555AF99A,0x7846A318,0xE284C527,0x9D61E50F,0xA89CB99E,0x3AABBBAA,
                0xEF951FBB,0x12E82D3D,0xBFEFFF6D,0x394F415C,0x83BF0278,0xFAD1F1C9,0xAF113F99,0xC0A3098D,0x969C3D67,0x7F229F94,0x84D6FAFD,
                0x624FE830,0x9D07F764,0x7FD62962,0xDBBD7280,0x61012683,0x5FC3C11,0xC472FE2,0xA914799,0xC734385A,0x6A6C02E0,0xB1CA77B1,
                0xA284510B,0x4DD2DC56,0x42BF8A85,0x7F7497E5,0x6D544C99,0x63AB0442,0x781FE4A,0xB62D1F67,0x93E220BD,0xA0973D5E,0xFDBC8A50,0x6E7DDDEC,
                0x497FACC3,0x24B17070,0x2C3731D9,0xAB564B93,0x787F0BB,0xBA45E8B8,0x23C9F95C,0xFEA23564,0xDB26713A,0x1BC4FDB9,0xD1D5F52B,0x45CD9CF3,
                0x42BF8A85
            }
            for k,v in WeaponHashes do
                local MaxAmmo = memory.alloc_int()
                WEAPON.GET_MAX_AMMO(players.user_ped(), v, MaxAmmo)
                MaxAmmo = memory.read_int(MaxAmmo)
                WEAPON.SET_PED_AMMO(players.user_ped(), v, MaxAmmo, false)
            end
        end)

    ----========================================----
    ---          Weapons Tweaks (ENTITY)
    ---     The part of weapons adding tweaks
    ----========================================----

        EntityTweaks:toggle_loop("Orbital Gun Weapon", {}, "Shoot everywhere to orbital entities without reason.", function()
            local last_hit_coords = v3.new()
            if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), last_hit_coords) then
                OrbitalRequest(last_hit_coords)
            end
        end)

        EntityTweaks:toggle_loop("Castle Bravo", {}, "", function()
            if PED.IS_PED_SHOOTING(players.user_ped()) then
                local hash = util.joaat("prop_military_pickup_01")
                RequestModel(hash)
                local player_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, 5.0, 3.0)
                local dir = v3.new()
                local c2 = v3.new(0,0,0)
                c2 = get_offset_from_gameplay_camera(1000)
                dir.x = (c2.x - player_pos.x) * 1000
                dir.y = (c2.y - player_pos.y) * 1000
                dir.z = (c2.z - player_pos.z) * 1000
                local nuke = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, player_pos.x, player_pos.y, player_pos.z, true, false, false)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(nuke, players.user_ped(), false)
                ENTITY.APPLY_FORCE_TO_ENTITY(nuke, 0, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
                ENTITY.SET_ENTITY_HAS_GRAVITY(nuke, true)
        
                while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(nuke) and not ENTITY.IS_ENTITY_IN_WATER(nuke) do
                    InterWait(0)
                end
                local nukePos = ENTITY.GET_ENTITY_COORDS(nuke, true)
                entities.delete_by_handle(nuke)
                CreateNuke(nukePos)
            end
        end)

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
