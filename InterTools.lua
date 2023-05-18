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

    Part: Main complete
]]--

        util.keep_running()
        util.require_natives(1681379138)
        aalib = require("aalib")
        PlaySong = aalib.play_sound

    ----========================================----
    ---           Shortcuts for Stand
    ---        The part of linking files
    ----========================================----

        InterCmd = menu.trigger_command
        InterCmds = menu.trigger_commands
        InterWait = util.yield
        InterRefBP = menu.ref_by_path
        local InterRoot = menu.my_root()
        local InterToast = util.toast

    ----========================================----
    ---             Other Parts
    ---        useless but not important
    ----========================================----

        local SND_ASYNC<const> = 0x0001
        local SND_FILENAME<const> = 0x00020000
        local int_min = -2147483647
        local int_max = 2147483647
        local STAND_VERSION = menu.get_version().version
        local SCRIPT_VERSION = "1.73LN"
        local InterMenu = "InterTools v"..SCRIPT_VERSION
        local GTAO_VERSION = "1.66"
        local InterMessage = "> InterTools v"..SCRIPT_VERSION
        InterNotify = function(str) if ToggleNotify then if NotifMode == 2 then util.show_corner_help(InterMessage.."~s~~n~"..str ) else InterToast(InterMessage.."\n\n"..str) end end end
        AWACSNotify = function(str) if ToggleNotify then if NotifMode == 2 then util.show_corner_help("AWACS Detection System".."~s~~n~"..str ) else InterToast("AWACS Detection System".."\n\n"..str) end end end
        AvailableSession =  function() return util.is_session_started() and not util.is_session_transition_active() end

    ---==================================================================================================---
    -- ███████╗██╗██╗░░░░░███████╗  ██████╗░██╗██████╗░███████╗░█████╗░████████╗░█████╗░██████╗░██╗░░░██╗
    -- ██╔════╝██║██║░░░░░██╔════╝  ██╔══██╗██║██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗╚██╗░██╔╝
    -- █████╗░░██║██║░░░░░█████╗░░  ██║░░██║██║██████╔╝█████╗░░██║░░╚═╝░░░██║░░░██║░░██║██████╔╝░╚████╔╝░
    -- ██╔══╝░░██║██║░░░░░██╔══╝░░  ██║░░██║██║██╔══██╗██╔══╝░░██║░░██╗░░░██║░░░██║░░██║██╔══██╗░░╚██╔╝░░
    -- ██║░░░░░██║███████╗███████╗  ██████╔╝██║██║░░██║███████╗╚█████╔╝░░░██║░░░╚█████╔╝██║░░██║░░░██║░░░
    -- ╚═╝░░░░░╚═╝╚══════╝╚══════╝  ╚═════╝░╚═╝╚═╝░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░
    ---==================================================================================================---

        script_store_songs = filesystem.store_dir() .. "Inter" .. '/Songs' -- Redirects to %appdata%\Stand\Lua Scripts\store\Inter\Songs
        if not filesystem.is_dir(script_store_songs) then
            filesystem.mkdirs(script_store_songs)
        end

        script_resources = filesystem.resources_dir() .. "Inter" -- Redirects to %appdata%\Stand\Lua Scripts\resources\Inter
        if not filesystem.is_dir(script_resources) then
            filesystem.mkdirs(script_resources)
        end

        local ScriptDir <const> = filesystem.scripts_dir()
        local Required_Files <const> = {
            "lib\\InterTools\\Functions.lua",
            "lib\\InterTools\\math.lua",
            "lib\\InterTools\\models.lua"
        }
        for _, file in pairs(Required_Files) do
            local file_path = ScriptDir .. file
            if not filesystem.exists(file_path) then
                InterNotify("Missing documents: " .. file_path, TOAST_ALL)
                util.stop_script()
            end
        end

        require "InterTools.Functions"
        require "InterTools.math"
        require "InterTools.models"

    ----========================================----
    ---              Update Parts
    ---     The part of update. Auto or manual
    ----========================================----

        -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
        local status, auto_updater = pcall(require, "auto-updater")
        if not status then
            local auto_update_complete = nil InterNotify("Installing auto-updater...", TOAST_ALL)
            async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
                function(result, headers, status_code)
                    local function parse_auto_update_result(result, headers, status_code)
                        local error_prefix = "Error downloading auto-updater: "
                        if status_code ~= 200 then InterNotify(error_prefix..status_code, TOAST_ALL) return false end
                        if not result or result == "" then InterNotify(error_prefix.."Found empty file.", TOAST_ALL) return false end
                        filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                        local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                        if file == nil then InterNotify(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                        file:write(result) file:close() InterNotify("Successfully installed auto-updater lib", TOAST_ALL) return true
                    end
                    auto_update_complete = parse_auto_update_result(result, headers, status_code)
                end, function() InterNotify("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
            async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
            if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
            auto_updater = require("auto-updater")
        end
        if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

        local default_check_interval = 604800
        local auto_update_config = {
            source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/InterTools.lua",
            script_relpath=SCRIPT_RELPATH,
            switch_to_branch=selected_branch,
            verify_file_begins_with="--",
            check_interval=86400,
            silent_updates=true,
            dependencies={
                {
                    name="Template",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/Template/Inter.png",
                    script_relpath="resources/Inter/Template/Inter.png",
                    check_interval=default_check_interval,
                },
                {
                    name="math",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/math.lua",
                    script_relpath="lib/InterTools/math.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="functions",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Functions.lua",
                    script_relpath="lib/InterTools/Functions.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="models",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/models.lua",
                    script_relpath="lib/InterTools/models.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="aalib",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/aalib.dll",
                    script_relpath="lib/aalib.dll",
                    check_interval=default_check_interval,
                },
                {
                    name="ToggleTemplate",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/Template/ToggleTemplate.txt",
                    script_relpath="resources/Inter/Template/ToggleTemplate.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="911",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/Sounds/911.wav",
                    script_relpath="resources/Inter/Sounds/911.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="Stops",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/stops.wav",
                    script_relpath="resources/Inter/stops.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="DisplayTime",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/Template/DisplayDuration.txt",
                    script_relpath="resources/Inter/Template/DisplayDuration.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="songToggle",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/Songs/SongToggle.txt",
                    script_relpath="resources/Inter/Songs/SongToggle.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="songName",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/Songs/songName.txt",
                    script_relpath="resources/Inter/Songs/songName.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="verifyMessage",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/toggleMsg.txt",
                    script_relpath="resources/Inter/toggleMsg.txt",
                    check_interval=default_check_interval,
                },
                {
                    name="BadToTheBone",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/BadToTheBone.wav",
                    script_relpath="resources/Inter/PresetsMusics/BadToTheBone.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="CaliforniaDreamin",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/CaliforniaDreamin.wav",
                    script_relpath="resources/Inter/PresetsMusics/CaliforniaDreamin.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="DangerZone",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/DangerZone.wav",
                    script_relpath="resources/Inter/PresetsMusics/DangerZone.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="RuleTheWorld",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/RuleTheWorld.wav",
                    script_relpath="resources/Inter/PresetsMusics/RuleTheWorld.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="FortunateSon",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/FortunateSon.wav",
                    script_relpath="resources/Inter/PresetsMusics/FortunateSon.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="Master of Puppets",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/MasterOfPuppets.wav",
                    script_relpath="resources/Inter/PresetsMusics/MasterOfPuppets.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="PaintItBlack",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/PaintItBlack.wav",
                    script_relpath="resources/Inter/PresetsMusics/PaintItBlack.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="Paranoid",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/Paranoid.wav",
                    script_relpath="resources/Inter/PresetsMusics/Paranoid.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="ShouldIGo",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/ShouldIGo.wav",
                    script_relpath="resources/Inter/PresetsMusics/ShouldIGo.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="MississippiQueen",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/MississippiQueen.wav",
                    script_relpath="resources/Inter/PresetsMusics/MississippiQueen.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="MaterialGirl",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/MaterialGirl.wav",
                    script_relpath="resources/Inter/PresetsMusics/MaterialGirl.wav",
                    check_interval=default_check_interval,
                },
                {
                    name="HighwaytoHell",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/resources/Inter/PresetsMusics/HighwaytoHell.wav",
                    script_relpath="resources/Inter/PresetsMusics/HighwaytoHell.wav",
                    check_interval=default_check_interval,
                },
            }
        }

        auto_updater.run_auto_update(auto_update_config)

    ---========================================----
    ---              Self Roots
    ---         The part of self roots
    ----========================================----

        InterRoot:divider(InterMenu)
        InterRoot:action("Player Parts", {"intplayers"}, "", function() menu.ref_by_path("Players"):trigger()end)
        local SelfParts = InterRoot:list("Self Options", {"intself"})
        local AnimalsParts = SelfParts:list("Animals Parts")
        local AnimationsParts = SelfParts:list("Animations Features")
        local LocalParts = SelfParts:list("Local Parts")

    ---========================================----
    ---             Weapons Roots
    ---         The part of weaps roots
    ----========================================----
    
        local WeaponsParts = InterRoot:list("Weapon Parts", {"intweapons"})
        local WeaponTweaks = WeaponsParts:list("Weapons Tweaks")
        local ReloadTweaks = WeaponsParts:list("Reload Tweaks")
        local EntityTweaks = WeaponsParts:list("Entity Tweaks")

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
    ---              Online Roots
    ---         The part of online parts
    ----========================================----

        local OnlineParts = InterRoot:list("Online Settings", {"intonline"})
        local ExcludeRoot = OnlineParts:list("Exclude Parts", {}, "Exclude every features.\nIncludes: \n- Session Parts")
        local ChatParts = OnlineParts:list("Chat Parts")
        local DetectionRoots = OnlineParts:list("Detection Parts")
        local HostRoots = OnlineParts:list("Host Parts")
        local LanguageRoots = OnlineParts:list("Language Parts")
        local SessionRoots = OnlineParts:list("Session Parts")

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

    ---========================================----
    ---              Music Roots
    ---        The part of musics roots
    ----========================================----

        local MusicParts = InterRoot:list("Music Parts", {"intmusics"})

    ---========================================----
    ---             Settings Roots
    ---        The part of world parts
    ----========================================----

        local SettingsParts = InterRoot:list("Settings Parts", {"intsettings"})

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

        SelfParts:toggle("Partial Invisible", {}, "Turn partially invisible mode (Players will not able to see you), but you will see only yourself, includes vehicles.", function(toggle)
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
                local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicles, -1, true)
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

        LocalParts:action("Edit Armor", {"intarmor"}, "Edit Armor bar (0 - 50)", function()
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

        AnimalsParts:toggle_loop("iShowSpeed Favorite Animal", {}, "", function()
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

        WeaponsParts:toggle_loop("Toggle Reticle", {}, "", function()
            HUD.SHOW_HUD_COMPONENT_THIS_FRAME(14)
        end,function()
            HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
        end)

        local invisibleFirearm = false
        WeaponsParts:toggle_loop("Invisible Firearm", {}, "", function()
            invisibleFirearm = true
            local current_fireArms = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_VISIBLE(current_fireArms, not invisibleFirearm, false)
            while true do
                util.yield()
                if invisibleFirearm then
                    local current_fireArms = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID())
                    ENTITY.SET_ENTITY_VISIBLE(current_fireArms, false, false)
                end
            end
        end,function()
            local current_fireArms = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID())
            ENTITY.SET_ENTITY_VISIBLE(current_fireArms, invisibleFirearm, false)
            invisibleFirearm = false
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

        local moved_seat = VehicleParts:click_slider("Change Seat", {""}, "Switch seats by using the Slider. 1 is the Driver.", 1, 1, 1, 1, function(seat_id)
            TASK.TASK_WARP_PED_INTO_VEHICLE(players.user_ped(), entities.get_user_vehicle_as_handle(), seat_id - 2)
        end)
    
        menu.on_tick_in_viewport(moved_seat, function()
            if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
                moved_seat.max_value = 0
            return end
            moved_seat.max_value = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()))
        end)

        VehicleParts:toggle_loop("Toggle Nitro", {}, "Press X to turn nitro quick instant.", function()
            local player = players.user_ped()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                if PAD.IS_CONTROL_JUST_PRESSED(357, 357) then
                    STREAMING.REQUEST_NAMED_PTFX_ASSET('veh_xs_vehicle_mods')  
                    VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(playerVehicle, true, 100, 1, 99999999999, false)
                    repeat util.yield() until PAD.IS_CONTROL_JUST_PRESSED(357, 357)
                    VEHICLE.SET_OVERRIDE_NITROUS_LEVEL(playerVehicle, false, 0, 0, 0, false)
                end
            end
        end)

        VehicleParts:toggle_loop("Boost Heli Engine", {}, "Enable the feature will make helicopter faster than 1 second\nDisable the feature will able to stop engine and continue.", function()
            local player = players.user_ped()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                VEHICLE.SET_HELI_BLADES_FULL_SPEED(playerVehicle)
            else
                VEHICLE.SET_HELI_BLADES_SPEED(playerVehicle, 0)
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

                    for i = 0, 10 do
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

    ----========================================----
    ---              Exclude Parts
    ---         The part of exclusion parts
    ----========================================----

        ExcludeRoot:toggle("Exclude Self", {"intertoggleself"}, "Exclude Self for using these features.\nIncludes: \n- Session Parts", toggleSelfCallback)
        ExcludeRoot:toggle("Exclude Friends", {"intertogglefriend"}, "Exclude Friends for using these features.\nIncludes: \n- Session Parts", toggleFriendCallback)
        ExcludeRoot:toggle("Exclude Strangers", {"intertogglestrangers"}, "Exclude Strangers for using these features.\nIncludes: \n- Session Parts", toggleStrangersCallback)
        ExcludeRoot:toggle("Exclude Crew Members", {"intertogglecrews"}, "Exclude Crew Members for using these features.\nIncludes: \n- Session Parts", toggleCrewCallback)
        ExcludeRoot:toggle("Exclude Organization Members", {"intertoggleorg"}, "Exclude Organization Members for using these features.\nIncludes: \n- Session Parts", toggleOrgCallback)

    ----========================================----
    ---              Online Parts
    ---         The part of online parts
    ----========================================----

        OnlineParts:toggle_loop("Restrict Fly Zone", {'interflyzone'}, "Forces all players in air born vehicles into the ground.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local VehiclePed = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                if ENTITY.IS_ENTITY_IN_AIR(VehiclePed) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(VehiclePed)
                    ENTITY.APPLY_FORCE_TO_ENTITY(VehiclePed, 5, 0, 0, -0.8, 0, 0, 0.5, 0, false, false, true)
                    ENTITY.APPLY_FORCE_TO_ENTITY(VehiclePed, 1, 0, 0, -0.8, 0, 0, 0.5, 0, false, false, true)
                end
            end
        end)

        OnlineParts:toggle_loop("Camera Moving", {'interpcameramove'}, "Moving, shake with the hardest force in the session.\n\nToggle 'Exclude Self' to avoid using these features", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = players.get_name(pid)
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    CameraMoving(playerPed, 50000)
                end
            end
        end)

        OnlineParts:toggle_loop("Toggle Bypass Cruise Missile", {"intercruise"}, "Toggle (Enable/Disable) bypass Cruise Missile while using Kosatka and remove automatically cooldown while firing cruise missile.", function()
            SET_INT_GLOBAL(262145 + 30188, 99999)
            SET_INT_GLOBAL(262145 + 30187, 0) -- Remove Cooldown
        end,function()
            SET_INT_GLOBAL(262145 + 30188, 4000) -- Revert 4 Km Distance
            SET_INT_GLOBAL(262145 + 30187, 6000) -- Revert Cooldown
        end)

        OnlineParts:toggle_loop("Toggle Gain RP", {"intercruise"}, "Toggle (Enable/Disable) if you want gain RP or not.", function()
            SET_FLOAT_GLOBAL(262145 + 1, 0)
        end,function()
            SET_FLOAT_GLOBAL(262145 + 1, 1)
        end)

        OnlineParts:action("Find Random Session", {"interrandsess"}, "Join the Public Session.\nYou will not have the same chance, it's a game of probability.", function()
            InterCmds("go public")
            
            local rngValue = math.random(1, 100)
            local playerCount = 0
            
            if rngValue <= 10 then -- 10% chance of finding 1-4 players
                playerCount = math.random(1, 4)
            elseif rngValue <= 50 then -- 40% chance of finding 5-9 players
                playerCount = math.random(5, 9)
            elseif rngValue <= 80 then -- 30% chance of finding 10-19 players
                playerCount = math.random(10, 19)
            else -- 20% chance of finding 20-29 players
                playerCount = math.random(20, 29)
            end
            
            InterCmds("playermagnet " ..playerCount)
            InterNotify("You will gonna join the session approximately atleast: "..playerCount.." players. (Not Precise, Remember)")
    
            local loadTime = math.random(20000, 60000) -- 20 seconds / 1 min random time to able to reset player magnet
            InterWait(loadTime)
            InterCmds("playermagnet 0") -- Take time to revert the settings.
        end)

    ----========================================----
    ---         Chat Parts (Roots)
    ---     The part of chat roots, useful
    ----========================================----

        local ChatPresets = ChatParts:list("Chat Presets")
        ChatParts:divider("Custom Chat")

        local prohibitedWords = {
            "abortion",
            "alqaeda",
            "alqaida",
            "al-qaeda",
            "al-qaida",
            "fuck", 
            "bastard",
            "cock",
            "cocksucker",
            "penis",
            "daesh",
            "terrorist",
            "bisexual",
            "sex",
            "homosexual",
            "trans",
        }

        ChatParts:text_input("Custom Message", {"intcmessage"}, "Write a custom message\nFreedom Message is welcome but:\nFuck Terrorist Al-Qaeda, Daesh and I will burn these terrorists.\n\nNazism word are authorized, it's from Freedom of Speech.\n\nSexual word are banned.", function(textInput)
            if textInput ~= "" then
                ChatFinal = textInput
            else
                ChatFinal = nil
            end
        end)

        local delayedSpam
        ChatParts:text_input("Delay Time", {"intcdelay"}, "Edit time while using \"Send Loop Message\".\nThe time is measured in seconds.", function(delayTime)
            if delayTime ~= "" then
                delayedSpam = delayTime
            else
                delayedSpam = nil
            end
        end)
        
        ChatParts:action("Send Message", {""}, "", function()
            local text = display_onscreen_keyboard()
            if text ~= nil or text == "" then
                local isProhibited = false
                for _, word in ipairs(prohibitedWords) do
                    if string.match(string.lower(text), string.lower(word)) then
                        isProhibited = true
                        break
                    end
                end
                if isProhibited then
                    InterNotify("You cannot use prohibited words.")
                else
                    chat.send_message(text, false, true, true)
                    InterWait(50)
                end
            end
        end)
        
        ChatParts:toggle_loop("Send Loop Message", {""}, "Able to bypass Stand Ultimate Version which able to spam, but same result.", function()
            if ChatFinal ~= nil then
                local isProhibited = false
                for _, word in ipairs(prohibitedWords) do
                    if string.match(string.lower(ChatFinal), string.lower(word)) then
                        isProhibited = true
                        break
                    end
                end
                if isProhibited then
                    InterNotify("You cannot use prohibited words.")
                else
                    chat.send_message(ChatFinal, false, true, true)
                    InterWait(delayedSpam * 1000)
                end
            else
                InterNotify("Please enter a message to send.\nPlease try later")
            end
        end)

    ----========================================----
    ---         Chat Parts (Presets)
    ---     The part of chat roots, useful
    ----========================================----

        local presets = {
            ["Austrian Painter"] = {desc = "Austrian Painter changed the entire world", text = "His name is A d o l f  H i t l e r, the best dictatorship of Europe, he changed the entire world."},
            ["Where is Oil"] = {desc = "Somebody say oil?", text = "SOMEBODY SAY OIL? FREEDOM, DEMOCRACY, SECURITY IS COMING."},
            ["I hate who?"] = {desc = "", text = "I HATE N I G G A S"},
            ["Slava Ukraini"] = {desc = "Ukraine is better, glory to ukraine, fuck to Russia.", text = "Слава Україні"},
            ["Fuck Russia"] = {desc = "I don't like Russian government and Putin", text = "I f uck the Russian government and terrorist who attack the poor Ukrainians. К черту российское правительство и террористические банды, которые нападают на бедных украинцев"},
            ["What menu I use?"] = {desc = "Show us what are you using, includes:\n- Stand\n- 2Take1 and etc...", text = "I use Stand Ultimate, 2take1 VIP coloaded, Phantom-X Deluxe, Fragment, Nightfall and a ton other menu's and I coded all the InterTools Scripts."}
        }

        local preset_order = {}

        for name, preset in pairs(presets) do
            table.insert(preset_order, { name, preset })
        end
                
        table.sort(preset_order, function(a, b) return a[1] < b[1] end)
                
        for _, preset in ipairs(preset_order) do
            local name = preset[1]
            local details = preset[2]
            ChatPresets:action(name, {}, details.desc, function()
                chat.send_message(details.text, false, true, true)
                InterWait(50)
            end)
        end

    ----========================================----
    ---              Detection Parts
    ---         The part of online parts
    ----========================================----

        local kick_time = 0
        DetectionRoots:toggle_loop("Auto Kick Host Token Users", {'interhostkick'}, "Kick automatically users while using \"Aggressive\", \"Sweet Spot\" or \"Handicap\" features which can be nuisible and control the entire session might resulting to destroy or block access for modders.", function()
            local commands = {"breakup", "ban", "kick", "confusionkick", "nonhostkick", "pickupkick"}
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do --adding false because it will affect self while using host token.
                local SpoofToken = players.get_host_token_hex(pid)
                local isSpoofToken
                kick_time += 1
                if string.sub(SpoofToken, 1, 4) == "FFFF" and kick_time >= 3 then
                    kick_time += 1
                    isSpoofToken = "Handicap"
                    for _, command in ipairs(commands) do
                        InterCmds(command..players.get_name(pid))
                        InterNotify(players.get_name(pid).." is using "..isSpoofToken.."\nUser has been force breakup(ed).")
                    end
                    repeat
                        InterWait()
                    until pid ~= nil
                    kick_time = 0
                elseif string.sub(SpoofToken, 1, 4) == "0021" and kick_time >= 3 then
                    kick_time += 1
                    local tokenValue = tonumber(string.sub(SpoofToken, 5, 8), 16)
                    if tokenValue and tokenValue >= 16 and tokenValue <= 37 then
                        isSpoofToken = "Sweet Spot"
                        for _, command in ipairs(commands) do
                            InterCmds(command..players.get_name(pid))
                            InterNotify(players.get_name(pid).." is using "..isSpoofToken.."\nUser has been force breakup(ed).")
                        end
                    end
                    repeat
                        InterWait()
                    until pid ~= nil
                    kick_time = 0
                elseif string.sub(SpoofToken, 1, 4) == "0000" and kick_time >= 3 then
                    kick_time += 1
                    isSpoofToken = "Aggressive"
                    for _, command in ipairs(commands) do
                        InterCmds(command..players.get_name(pid))
                        InterNotify(players.get_name(pid).." is using "..isSpoofToken.."\nUser has been force breakup(ed).")
                    end
                    repeat
                        InterWait()
                    until pid ~= nil
                    kick_time = 0
                end
            end
        end, function()
            kick_time = 0
        end)

        local modderkick = 0
        DetectionRoots:toggle_loop("Auto Kick Modders", {"interkickmod"}, "Kick automatically modders marked as \"Modder\" or \"Attack\" (it means that a Modder is trying to crash you/kick/giving collectibles, etc...).\n\nWarning: Enable Stand User Identification will block any attempt to kick Stand Users or someone, read before to use.", function()
            local commands = {"breakup", "ban", "confusionkick", "nonhostkick", "pickupkick"}
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                InterWait(10)
                modderkick += 1
                InterWait(15)
                if modderkick >= 3 and not players.get_name(pid) ~= "UndiscoveredPlayer" and players.is_marked_as_modder(pid) or players.is_marked_as_attacker(pid)then
                    for _, command in ipairs(commands) do
                        InterCmds(command..players.get_name(pid))
                    end
                repeat
                InterWait()
                until pid ~= nil
                    modderkick = 0
                end
            end
        end, function()
            modderkick = 0
        end)

        DetectionRoots:divider("Related Settings for Detections")
        DetectionRoots:toggle("Toggle Stand User", {"intertogglestand"}, "Toggle (Enable/Disable) Stand User Identification to identifies you and other players.\n\nFind a new session to refresh to able to reveal Stand User or hiding.", function(on_toggle)
            local standid = InterRefBP("Online>Protections>Detections>Stand User Identification")
            if on_toggle then
                InterCmd(standid, "on")
            else
                InterCmd(standid, "off")
            end
        end)

        local VehicleDetections = DetectionRoots:list("Vehicle Detection Parts")

    ----========================================----
    ---         Vehicle Detection Tools
    ---     The part of vehicle detect parts
    ----========================================----    

        VehicleDetections:action("Plane System Detection", {"interradars"}, "Detect any players while using planes or jets who might be a suspect.", function()
            local players_detected = 0
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                if PED.IS_PED_IN_ANY_PLANE(playerPed) then
                    players_detected = players_detected + 1
                end
            end
            if players_detected > 0 then
                local message = tostring(players_detected) .. " player"
                if players_detected > 1 then
                    message = message .. "s"
                end
                message = message .. " has been detected using planes or jets.\nRadar Status: Ready."
                AWACSNotify(message)
            else
                AWACSNotify("No one is using a jet or a plane.\nTrying to verify. \nPlease wait for complete detection.")
            end
        end)

        VehicleDetections:action("Oppressor Detection", {"interopp2"}, "Detect any players while using Oppressor MK II.", function()
            local players_detected = 0
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
				local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local hash = util.joaat("oppressor2")
                if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                    players_detected = players_detected + 1
                end
            end
            if players_detected > 0 then
                local message = tostring(players_detected) .. " player"
                if players_detected > 1 then
                    message = message .. "s"
                end
                message = message .. " has been detected using Oppressor MK2.\nRadar Status: Ready."
                AWACSNotify(message)
            else
                AWACSNotify("No one is using Oppressor MK2.\nTrying to verify. \nPlease wait for complete detection.")
            end
        end)

        VehicleDetections:divider("Remove Parts")

        VehicleDetections:toggle_loop("Remove Oppressor", {"interopdelete"}, "Kick any player while using Oppressor MK II", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
				local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                local hash = util.joaat("oppressor2")
                if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                    InterCmds("vehkick"..players.get_name(pid))
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                end
            end
        end)

        VehicleDetections:toggle_loop("Remove Armored Vehicles", {"interarmoreddelete"}, "Kick any player while using armored vehicles (includes Planes)", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)

                local tables = {
                    "nightshark",
                    "halftrack",
                    "hauler2",
                    "rhino",
                    "khanjali",
                    "avenger",
                    "barrage",
                    "apc"
                }

                for _, model in pairs(tables) do
                    local hash = util.joaat(model)
                    if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                        InterCmds("vehkick"..players.get_name(pid))
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                    end
                end
            end
        end)

        VehicleDetections:toggle_loop("Remove Surface-to-Air Missile", {"intersamdelete"}, "Kick any player while using Surface-to-Air Missile.", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)

                local tables = {
                    "chernobog", 
                    "trailersmall2"
                }

                for _, model in pairs(tables) do
                    local hash = util.joaat(model)
                    if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                        InterCmds("vehkick"..players.get_name(pid))
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                    end
                end
            end
        end)

        VehicleDetections:toggle_loop("Remove Dogfight Planes", {"intertpdelete"}, "Remove any vehicle while using dogfight planes.", function()
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)

                local tables = {
                    "hydra", 
                    "lazer", 
                    "strikeforce", 
                    "starling", 
                    "molotok", 
                    "nokota", 
                    "seabreeze", 
                    "rogue"
                }

                for _, model in pairs(tables) do
                    local hash = util.joaat(model)
                    if VEHICLE.IS_VEHICLE_MODEL(vehicle, hash) then
                        InterCmds("vehkick"..players.get_name(pid))
                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(vehicle, true)
                    end
                end
            end
        end)

    ----========================================----
    ---                Host Parts
    ---         The part of online parts
    ----========================================----

        HostRoots:click_slider("Max Players", {"intermaxplayers"}, "Set the max Players for the lobby\nOnly works as the Host.", 1, 32, 32, 1, function(value)
            if players.get_host() == players.user() then
                NETWORK.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(0, value)
                InterNotify("Free Slots edited: ".. NETWORK.NETWORK_SESSION_GET_MATCHMAKING_GROUP_FREE(0))
            else
                InterNotify("You are not the Host.")
            end
        end)

        HostRoots:click_slider("Max Players (Spectators)", {"intermaxsp"}, "Only works as the Host.", 0, 2, 0, 1, function(value)
            if players.get_host() == players.user() then
                NETWORK.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(4, value)
                InterNotify("Free Slots edited: ".. NETWORK.NETWORK_SESSION_GET_MATCHMAKING_GROUP_FREE(4))
            else
                InterNotify("You are not the Host.")
            end
        end)

        HostRoots:toggle("Block SH Migration", {}, "Only works as the Host.", function(toggle)
            if util.is_session_started() and players.get_host() == players.user() then
                NETWORK.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
            end
        end)

        BreakupForceHost = HostRoots:action("Breakup Host", {"interbreakup"}, "Breakup players position until become host.", function(type)
            if AvailableSession() then
                if players.get_host() ~= players.user() then
                    local players_before_host = players.get_host_queue_position(players.user())
                    menu.show_warning(BreakupForceHost, type, "DISCLAIMER: You are about to kick around".." "..players_before_host.." ".."players until you become host. Are you sure?", function()
                        if AvailableSession() then
                            while players.get_host() ~= players.user() do
                                local host = players.get_host()
                                if players.exists(host) then
                                    InterCmds("breakup"..players.get_name(host))
                                end
                                InterWait(50)
                            end
                            InterNotify("You are host.")
                        end
                    end)
                else
                    InterNotify("You are already host.".."\n".."Please try later.")
                end
            end
        end)

    ----========================================----
    ---              Language Roots
    ---         The part of session online
    ----========================================----

        local languages = {
            ["English"] = {0, {"United States", "United Kingdom", "Australia", "Ireland", "Canada", "India", "New Zealand", "Commonwealth Countries", "Baltic Countries (Lithuania, Estonia, Latvia)", "Nordic Countries (Denmark, Norway, Sweden, Finland, Iceland)", "And every countries not listed."}},
            ["French"] = {1, {"Metropolitan France", "Overseas France (includes La Réunion, Martinique, Guadeloupe, etc...)", "Belgium", "Switzerland", "African Countries", "Canada (Quebec)"}},
            ["German"] = {2, {"Germany", "Austria", "Switzerland", "Belgium", "Liechtenstein"}},
            ["Italian"] = {3, {"Italy", "San Marino", "Switzerland", "Vatican City"}},
            ["Spanish"] = {4, {"Spain", "Overseas Spain", "American Countries (Argentina, Cuba, Colombia, Peru, Panama, Paraguay, etc...)", "African Countries"}},
            ["Portuguese"] = {5, {"Portugal", "Brazil", "Angola", "Cabo Verde", "Timor Leste", "Equatorial Guinea", "Mozambique", "São Tomé and Príncipe", "Macau (China Mainland)"}},
            ["Polish"] = {6, {"Poland", "Belarus"}},
            ["Russian"] = {7, {"Russian Federation", "Ukraine", "Belarus", "Kazakhstan", "Georgia", "Armenia", "Mongolia", "Tajikistan", "Azerbaijan", "Moldova (Transnistria)", "Turkmenistan", "Uzbekistan", "Kyrgyzstan"}},
            ["Korean"] = {8, {"South Korea", "North Korea"}},
            ["Chinese Traditional"] = {9, {"Taiwan Island"}},
            ["Japanese"] = {10, {"Japan"}},
            ["Mexican"] = {11, {"Mexico"}},
            ["Chinese Simplified"] = {12, {"China Mainland", "Taiwan Island", "Thailand", "Hong Kong", "Macau", "Singapore"}}
        }

        local KickSystem = LanguageRoots:list("Kick Options")
        local CrashSystem = LanguageRoots:list("Crash Options")
 
        local sorted_languages = {}

        for language, data in pairs(languages) do
            table.insert(sorted_languages, {language, data})
        end

        local languageTable = {
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

        LanguageRoots:action_slider("Detect Language", {}, "To be precise for Languages: ".."\n- "..table.concat(languageTable, '\n- '), languageTable, function(languageSelect)
            local languageFound = false
            for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local languageIndex = players.get_language(pid)
                    local playerName = players.get_name(pid)
                    if languageIndex == (languageSelect - 1) then
                        if playerName ~= "UndiscoveredPlayer" then
                            InterNotify(playerName .. " is " .. languageTable[languageSelect] .. ".")
                            languageFound = true
                        repeat
                            InterWait()
                        until pid ~= nil
                        end
                    end
                end
            if not languageFound then
                InterNotify("We can't find " .. languageTable[languageSelect] .. " in the Session.")
            end
        end)

        table.sort(sorted_languages, function(a, b) return a[2][1] < b[2][1] end)

        for i, language_data in ipairs(sorted_languages) do
            local language = language_data[1]
            local data = language_data[2]

            local kick_timeC = 0
            KickSystem:toggle_loop("Auto Kick " .. language, {"intlkick" .. string.lower(language)}, "To be precise for Languages: ".."\n\n-" .. table.concat(data[2], "\n-"), function()
                for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    InterWait(10)
                    kick_timeC += 1
                    local languageIndex = players.get_language(pid)
                        if languageIndex == data[1] then
                            InterWait(15)
                            if kick_timeC >= 3 and not players.get_name(pid) ~= "UndiscoveredPlayer" then
                                InterCmds("breakup" .. players.get_name(pid))
                                repeat
                                    InterWait()
                                until pid ~= nil
                                kick_timeC = 0
                            end
                        end
                    end 
                end, function()
                kick_timeC = 0
            end)

            local crash_time = 0
            CrashSystem:toggle_loop("Auto Crash " .. language, {"intlcrash" .. string.lower(language)}, "To be precise for Languages: ".."\n\n-" .. table.concat(data[2], "\n-"), function()
                for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    InterWait(10)
                    crash_time += 1
                    local languageIndex = players.get_language(pid)
                        if languageIndex == data[1] then
                            InterWait(15)
                            if crash_time >= 3 and not players.get_name(pid) ~= "UndiscoveredPlayer" then
                                InterCmds("crash" .. players.get_name(pid))
                                repeat
                                    InterWait()
                                until pid ~= nil
                                crash_time = 0
                            end
                        end
                    end 
                end, function()
            end)
        end

    ----========================================----
    ---              Session Roots
    ---         The part of session online
    ----========================================----

        local AerialRoots = SessionRoots:list("Aerial & Ground Defense")
        local BountyRoot = SessionRoots:list("Bounty Parts")
        local ExplodeRoot = SessionRoots:list("Explode Parts")
        
        local SoundRoots = SessionRoots:list("Sound Parts")
        local TeleportsRoots = SessionRoots:list("Teleport Parts")
        local VehicleRootsO = SessionRoots:list("Vehicle Parts")
        

    ----========================================----
    ---               Aerial Roots
    ---         The part of session online
    ---             Defending the skies
    ----========================================----

        local AerialParts = AerialRoots:list("Aerial Defense")
        local HeliParts = AerialRoots:list("Aerial Defense (Helicopters)")
        local GroundParts = AerialRoots:list("Ground Defense")
        AerialRoots:divider("Advanced")
        local TaskForce = AerialRoots:list("Task Force", {"intertaskforce"}, "Undetectable by modders, take the opportunity to invade the session with aggressive means.".."\n\n".."The \"Task Force\" doctrine consists of flooding the session with aircraft for which the host acts as an escort and lets the aircraft appear and act autonomously as a killer AI.")
        AerialParts:divider("Aerial Defense (US Air Force)")
        PlaneToggleGod = AerialParts:toggle_loop("Toggle Godmode Air Force", {}, "Toggle (Enable/Disable) Godmode Planes while using \"Send Air Force\".",  function()end)
        RandomizePlane = AerialParts:toggle_loop("Toggle Random Plane", {}, "", function()end)
        local planeModels = {
            ["Lazer"] = "lazer",
            ["Hydra"] = "hydra",
            ["V-65 Molotok"] = "molotok",
            ["Western Rogue"] = "rogue",
            ["Pyro"] = "pyro",
            ["P-45 Nokota"] = "nokota",
            ["LF-22 Starling"] = "starling",
            ["Mogul"] = "mogul",
            ["Seabreeze"] = "seabreeze",
            ["B-11 Strikeforce"] = "strikeforce",
        }
        
        local planeModelNames = {}
        for name, _ in pairs(planeModels) do
            table.insert(planeModelNames, name)
        end

        table.sort(planeModelNames, function(a, b) return a[1] < b[1] end)
        
        local selectedPlaneModel = "B-11 Strikeforce"
        local planesHash = planeModels[selectedPlaneModel]
        
        AerialParts:list_select("Types of Planes", {"interplanes"}, "The entities that will add while sending air force planes.", planeModelNames, 1, function(index)
            selectedPlaneModel = planeModelNames[index]
            planesHash = planeModels[selectedPlaneModel]
        end)

        local planeModels1 = {
            "molotok",
            "rogue",
            "pyro",
            "nokota",
            "starling",
            "mogul",
            "seabreeze",
            "strikeforce",
        }

        AerialParts:action("Send Air Force", {"interusaf"}, "Sending America to war and intervene more planes (Real Undetectable).\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features.", function()
            if menu.get_value(RandomizePlane) == true then
                local playerList = players.list(true, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                local counter = 0
                local max_iterations = 5 -- change this to adjust the number of iterations
                while counter < max_iterations do
                    for _, pid in pairs(playerList) do
                        if AvailableSession() then
                            local randomModel = planeModels1[math.random(#planeModels1)]
                            AggressivePlanes(pid, randomModel)
                            InterWait(5000)
                        end
                    end
                    counter = counter + 1
                end
            else
                local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                for _, pid in pairs(playerList) do
                    if AvailableSession() then
                        for i = 1, menu.get_value(PlaneCount) do
                            harass_vehicle(pid, planesHash, true, false)
                            InterWait(5000)
                        end
                    end
                end
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        AerialParts:action("Send Air Force (Task Force)", {"interusaftf"}, "Sending company of skilled pilot from America.\nToggle Godmode = irreversible.", function()
            local player = PLAYER.PLAYER_PED_ID()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                if PED.IS_PED_IN_ANY_PLANE(player) then
                    local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                    for _, pid in pairs(playerList) do
                        if AvailableSession() then
                            escort_attack(pid, planesHash, true)
                            InterWait(5000)
                        end
                    end
                else
                    InterNotify("To operate the action, you need to be in a plane to operate planes.")
                end
            else
                InterNotify("Sit down in a fuckin vehicle.")
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        PlaneCount = AerialParts:slider("Number of Generation of Planes", {"interaf"}, "For purposes: limit atleast 5 planes if you are in Public session with 30 players.".."\n\nFor recommendation:".."\n".."- for Hydra: 1 or 2 planes per session while using to avoid instance.\n- Lazer: 3 or 5 more.", 1, 10, 1, 1, function()end)

    ----========================================----
    ---           Aerial Roots (Choppers)
    ---         The part of session online
    ---           Defending the skies
    ----========================================----

        HeliParts:divider("Aerial Defense - Choppers (US Air Force)")
        HelisToggleGod = HeliParts:toggle_loop("Toggle Godmode Air Force (Helis)", {}, "Toggle (Enable/Disable) Godmode helicopters while using \"Send Air Force (Helicopters)\".",  function()end)

        local helisModels = {
            ["Annihilator"] = "annihilator",
            ["Cargobob"] = "cargobob",
            ["Annihilator Stealth"] = "annihilator2",
            ["Buzzard Attack Chopper"] = "buzzard",
            ["Savage"] = "savage",
            ["Valkyrie"] = "valkyrie",
            ["FH-1 Hunter"] = "hunter",
            ["RF-1 Akula"] = "akula",
        }

        local heliModelName = {}
        for name, _ in pairs(helisModels) do
            table.insert(heliModelName, name)
        end
        table.sort(heliModelName, function(a, b) return a[1] < b[1] end)

        local selectedHeliNameModel = "Annihilator"
        local heliHash = helisModels[selectedHeliNameModel]
        -- Types of Choppers
        HeliParts:list_select("Types of Choppers", {"interhelis"}, "The entities that will add while sending air force helicopters.", heliModelName, 1, function(index)
            selectedHeliNameModel = heliModelName[index]
            heliHash = helisModels[selectedHeliNameModel]
        end)
        -- Send Air Force (Helicopters)
        HeliParts:action("Send Air Force (Helicopters)", {"interusafh"}, "Sending America to war and intervene more helicopters.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features", function()
            local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            for _, pid in pairs(playerList) do
                if AvailableSession() then
                    for i = 1, menu.get_value(HelisCount) do
                        harass_vehicle(pid, heliHash, false, true)
                        InterWait(5000)
                    end
                end
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        -- Send Air Force (Task Force) Custom
        HeliParts:action("Send Air Force (Task Force Chopper)", {"interusaftfh"}, "Sending company of skilled pilot from America.\nToggle Godmode = irreversible.\nRestriction: One ped for seat. (Don't use Valkyrie or some helis while not able to full seat passenger.)", function()
            local player = PLAYER.PLAYER_PED_ID()
            local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
            if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                if PED.IS_PED_IN_ANY_PLANE(player) then
                    local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                    for _, pid in pairs(playerList) do
                        if AvailableSession() then
                            escort_attack(pid, heliHash, false)
                            InterWait(5000)
                        end
                    end
                else
                    InterNotify("To operate the action, you need to be in a helicopter to operate choppers.")
                end
            else
                InterNotify("Sit down in a fuckin vehicle.")
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)
        HelisCount = HeliParts:slider("Number of Generation of Choppers", {"interafheli"}, "For purposes: limit atleast 5 helicopters if you are in Public session with 30 players.\nMore NPCs in a chopper = reducing spawning generation for choppers. 1 only need.", 1, 10, 1, 1, function()end)

    ----========================================----
    ---         Aerial Roots (Task Force)
    ---         The part of session online
    ----========================================----

        local specialMsg = "US Air Force has sent a friend request."
        TaskForce:divider("Parameters for Task Force")
        local PresetSpawningTF = TaskForce:list("Preset Spawner")
        local CustomVehicleTF = TaskForce:list("Custom Parts")
        CustomVehicleAdvanced = CustomVehicleTF:toggle_loop("Custom Vehicle", {}, "", function()end)
        ShowMessages = CustomVehicleTF:toggle_loop("Show Messages", {}, "", function()end)
        ToggleSongsCU = CustomVehicleTF:toggle_loop("Toggle Music", {}, "", function()end)
        CustomVehicleTF:text_input("Send Message", {"aftaskforcemsg"}, "America has sent a friend request.", function(typeText)
            if typeText ~= "" then
                specialMsg = typeText
            else
                specialMsg = "US Air Force has sent a friend request."
            end
        end, specialMsg)

        local delaySpawning = 1
        CustomVehicleTF:text_input("Delay Time", {"intertimertf"}, "Do not abuse for spawning vehicle, do not go to lower for preventing for crash, mass entities.\n\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 0 then
                    delaySpawning = delay
                else
                    InterNotify("Invalid delay value. Please enter a positive number greater than 0.")
                    delaySpawning = 1
                end
            else
                delaySpawning = 1
            end
        end, delaySpawning)

        CustomVehicleTF:divider("Sending Planes")
        -- Send Air Force (Task Force) Custom
        CustomVehicleTF:action("Send Air Force (Task Force) - Custom", {"interusafcustomtf"}, "Sending America to war and intervene more custom planes (Real Undetectable).\nWARNING: The action is irreversible in the session bcz godmode permanent.\n\nSome peds can fall and attach you.", function()
            if menu.get_value(CustomVehicleAdvanced) == true then
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if PED.IS_PED_IN_ANY_PLANE(player) then
                        local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                        local textInput = display_onscreen_keyboard()
                        if textInput == "" or textInput == nil then return end
                        local modelHash = util.joaat(textInput)
                        if menu.get_value(ToggleSongsCU) == true then
                            for _, model in pairs(models) do
                                if textInput == model then
                                    local PresetMusicParts = script_resources .. "/PresetsMusics"
                                    local songIndex = math.random(#randomSongs)
                                    local songName = randomSongs[songIndex]
                                    PlaySong(join_path(PresetMusicParts, songName), SND_FILENAME | SND_ASYNC)
                                    break
                                end
                            end
                        end

                        if STREAMING.IS_MODEL_VALID(modelHash) and STREAMING.IS_MODEL_A_VEHICLE(modelHash) then
                            if menu.get_value(ShowMessages) == true then chat.send_message(specialMsg, false, true, true) end
                            InterNotify("Confirmed target. The US Air Force is coming soon to saturate city.".."\nReady to target, roger that. Thanks for the information.")
                            for _, pid in pairs(playerList) do
                                if AvailableSession() then
                                    escort_attack(pid, textInput, true)
                                    util.yield(delaySpawning * 1000)
                                end
                            end
                        else
                            InterNotify("I'm sorry, we cannot send the plane named: " .. textInput)
                        end
                    else
                        InterNotify("To operate the action, you need to be in a plane to operate planes.")
                    end
                else
                    InterNotify("Sit down in a fuckin vehicle.")
                end
            else
                InterNotify("I'm sorry, enable \"Custom Vehicle\" to use more advantages.")
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        -- Send Air Force (Task Force Chopper) Custom

        CustomVehicleTF:action("Send Air Force (Task Force Chopper) - Custom", {"intertfcustomheli"}, "Sending America to war and intervene more custom helicopters (Real Undetectable).\nWARNING: The action is irreversible in the session bcz godmode permanent.\n\nSome peds can fall and attach you.", function()
            if menu.get_value(CustomVehicleAdvanced) == true then
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if PED.IS_PED_IN_ANY_HELI(player) then
                        local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                        local textInput = display_onscreen_keyboard()
                        if textInput == "" or textInput == nil then return end
                        local modelHash = util.joaat(textInput)
                        if STREAMING.IS_MODEL_VALID(modelHash) and STREAMING.IS_MODEL_A_VEHICLE(modelHash) then
                            if menu.get_value(ShowMessages) == true then chat.send_message(specialMsg, false, true, true) end
                            InterNotify("Confirmed target. The US Air Force is coming soon.".."\nReady to target, roger that. Thanks for the information.")
                            for _, pid in pairs(playerList) do
                                if AvailableSession() then
                                    escort_attack(pid, textInput, false)
                                    util.yield(delaySpawning * 1000)
                                end
                            end
                        else
                            InterNotify("I'm sorry, we cannot send those helicopters named: "..textInput)
                        end
                    else
                        InterNotify("To operate the action, you need to be in a helicopter to operate choppers.")
                    end
                else
                    InterNotify("Sit down in a fuckin vehicle.")
                end
            else
                InterNotify("I'm sorry, enable \"Custom Vehicle\" to use more advantages.")
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

    ----========================================----
    ---           Task Force (Advanced)
    ---            Target part player
    ----========================================----

        TaskForce:divider("Target Players (Sending Planes)")
        local modelVehicle = "lazer"
        TaskForce:text_input("Model Vehicle", {"intermodelvehtf"}, "Choose specific model existing on GTAV. Recommended to use combat fighters planes", function(txtModel)
            if txtModel ~= "" then
                local modelHash = util.joaat(txtModel)
                if STREAMING.IS_MODEL_A_VEHICLE(modelHash) then
                    modelVehicle = txtModel
                else
                    InterNotify("Invalid vehicle model: " .. txtModel)
                    modelVehicle = "lazer"
                end
            else
                modelVehicle = "lazer"
            end
        end, tostring(modelVehicle))

        ToggleRandom = TaskForce:toggle_loop("Random Player", {}, "Select random players in the session and target.", function()end)
        TaskForce:action("Target Player", {"intertftarget"}, "We need more communication and more precise for informations.\nTarget player is the priority objective for your choice if the player is in the session.", function()
            if menu.get_value(ToggleRandom) == true then
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                    if #playerList > 0 then
                        local randomIndex = math.random(#playerList)
                        local playerId = playerList[randomIndex]
                        local playerName = players.get_name(playerId)
                        if not players.is_in_interior(playerId) then
                            escort_attack(playerId, modelVehicle, true)
                            InterNotify("Confirmed target player: "..playerName..".".."\nReady to target, roger that. Thanks for the information.")
                        end
                    else
                        InterNotify("No players are currently in the session.")
                    end
                else
                    InterNotify("To operate the action, you need to be in a plane to operate plane.")
                end
            else
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    local textInput = display_onscreen_keyboard()
                    local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                    if EToggleSelf then
                        for _, pid in ipairs(playerList) do
                            if pid == players.user() and textInput == players.get_name(pid) then
                                InterNotify("You cannot send escort to kill yourself.")
                                return
                            end
                        end
                    end
                    if textInput == nil or textInput == "" then return
                    else
                        local isKilled = false
                        for _, pid in ipairs(playerList) do
                            local playerName = players.get_name(pid)
                            if not players.is_in_interior(pid) then
                                if playerName == textInput then
                                    isKilled = true
                                    InterNotify("Confirmed target player: "..textInput..".".."\nReady to target, roger that. Thanks for the information.")
                                    escort_attack(pid, modelVehicle, true)
                                    break
                                end
                            end
                        end
                        if not isKilled then
                            InterNotify("Error STATUS: The US Air Force cannot recognize the user named "..textInput)
                        end
                    end
                else
                    InterNotify("To operate the action, you need to be in a plane to operate plane.")
                end
            end
        end)

    ----========================================----
    ---           Aerial Roots (Presets)
    ---         The part of session online
    ----========================================----

        PresetSpawningTF:divider("Preset Vehicles")
        local tableSpawners = {
            ["Lazer"] = "lazer",
            ["Molotok"] = "molotok",
            ["Rogue"] = "rogue",
            ["Pyro"] = "pyro",
            ["Nokota"] = "nokota",
            ["Starling"] = "starling",
            ["Seabreeze"] = "seabreeze",
            ["Strikeforce"] = "strikeforce",
        }

        local tempSpawners = {}
        for spawnerName, spawnerModel in pairs(tableSpawners) do
            table.insert(tempSpawners, {spawnerName, spawnerModel})
        end

        table.sort(tempSpawners, function(a, b)
            return a[1] < b[1]
        end)

        local delaySpawningPresets = 1
        PresetSpawningTF:text_input("Delay Time", {"intertimertfpresets"}, "Do not abuse for spawning vehicle, do not go to lower for preventing for crash, mass entities.\n\nMeasured in seconds.", function(typeText)
            if typeText ~= "" then
                local delay = tonumber(typeText)
                if delay and delay > 0 then
                    delaySpawningPresets = delay
                else
                    AirFleetNotify("Invalid delay value. Please enter a positive number greater than 0.")
                    delaySpawningPresets = 1
                end
            else
                delaySpawningPresets = 1
            end
        end, delaySpawningPresets)

        for _, spawner in ipairs(tempSpawners) do
            local spawnerName = spawner[1]
            local spawnerModel = spawner[2]
            PresetSpawningTF:action("Spawn " .. spawnerName, {"intertf"..spawnerModel}, "", function()
                local player = PLAYER.PLAYER_PED_ID()
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if PED.IS_PED_IN_ANY_PLANE(player) then
                        local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                        if menu.get_value(ShowMessages) == true then chat.send_message(specialMsg, false, true, true) end
                        for _, pid in pairs(playerList) do
                            if AvailableSession() then
                                escort_attack(pid, spawnerModel, false)
                                InterWait(delaySpawningPresets * 1000)
                            end
                        end
                    else
                        InterNotify("To operate the action, you need to be in a plane to operate plane.")
                    end
                else
                    InterNotify("Please sit down in a vehicle.")
                end
            end)
        end

    ----==========================================================----
    ---         Aerial Roots (Advanced) - delete models
    ---          Deleting ununsual model for saturation
    ----==========================================================----

        local vehicleModelsToDelete = {
            util.joaat("lazer"),
            util.joaat("hydra"),
            util.joaat("strikeforce"),
            util.joaat("molotok"),
            util.joaat("rogue"),
            util.joaat("pyro"),
            util.joaat("nokota"),
            util.joaat("buzzard"),
            util.joaat("savage"),
            util.joaat("valkyrie"),
            util.joaat("hunter"),
            util.joaat("akula"),
            util.joaat("annihilator"),
            util.joaat("annihilator2"),
            util.joaat("cargobob"),
            util.joaat("starling"),
            util.joaat("mogul"),
            util.joaat("seabreeze"),
        }

        local modelToDelete = {
            util.joaat("s_m_y_marine_01"),
            util.joaat("s_m_y_marine_03"),
            util.joaat("s_m_y_pilot_01"),
            util.joaat("s_m_y_blackops_01"),
            util.joaat("s_m_m_marine_01"),
            util.joaat("s_m_m_pilot_02"),
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
        
        AerialRoots:action("Cleanup Air Force", {}, "Includes helicopters also too.", function()
            local ct = 0
            local vehicles = entities.get_all_vehicles_as_handles()
            for k, veh in pairs(vehicles) do
                local model = ENTITY.GET_ENTITY_MODEL(veh)
                if table.contains(vehicleModelsToDelete, model) then
                    entities.delete_by_handle(veh)
                    ct = ct + 1
                end
            end
            InterNotify("Successfully Deleted "..ct.." jets or helicopters.")

            local et = 0
            local monkeys = entities.get_all_peds_as_handles()
            for k, entity in pairs(monkeys) do
                local model = ENTITY.GET_ENTITY_MODEL(entity)
                if table.contains(modelToDelete, model) then
                    entities.delete_by_handle(entity)
                    et = et + 1
                end
            end
        end)

        local vehicleModelsToDeleteP = {
            util.joaat("rhino"),
            util.joaat("halftrack"),
            util.joaat("khanjali"),
            util.joaat("nightshark"),
            util.joaat("barrage"),
            util.joaat("apc"),
            util.joaat("insurgent3"),
            util.joaat("limo2"),
            util.joaat("tampa3"),
            util.joaat("menacer"),
            util.joaat("boxville5"),
            util.joaat("insurgent2"),
        }

        local modelToDeleteP = {
            util.joaat("s_m_y_blackops_01"),
            util.joaat("s_m_m_marine_01"),
            util.joaat("s_m_y_marine_03"),
            util.joaat("s_m_y_pilot_01")
        }
        
        AerialRoots:action("Cleanup Ground Forces", {}, "", function()
            local ct = 0
            local vehicles = entities.get_all_vehicles_as_handles()
            for k, veh in pairs(vehicles) do
                local model = ENTITY.GET_ENTITY_MODEL(veh)
                if table.contains(vehicleModelsToDeleteP, model) then
                    entities.delete_by_handle(veh)
                    ct = ct + 1
                end
            end
            InterNotify("Successfully Deleted "..ct.." ground vehicles.")

            local et = 0
            local monkeys = entities.get_all_peds_as_handles()
            for k, entity in pairs(monkeys) do
                local model = ENTITY.GET_ENTITY_MODEL(entity)
                if table.contains(modelToDeleteP, model) then
                    entities.delete_by_handle(entity)
                    et = et + 1
                end
            end
        end)

    ----========================================----
    ---             Ground Defense Roots
    ---         The part of session online
    ---             Defending the ground
    ----========================================----

        GroundParts:divider("Ground Defense (US Army)")
        TankToggleGod = GroundParts:toggle_loop("Toggle Godmode Vehicle", {}, "Toggle (Enable/Disable) Godmode Armored Vehicles while using ground vehicles.",  function()end)

        local armoredModel = {
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
        
        local armoredName = {}
        for name, _ in pairs(armoredModel) do
            table.insert(armoredName, name)
        end

        table.sort(armoredName, function(a, b) return a[1] < b[1] end)
        
        local selectedArmoredV = "APC"
        local armoredHash = armoredModel[selectedArmoredV]
        
        GroundParts:list_select("Types of Armored Cars", {"interarmored"}, "The entities that will add while sending air force helicopters.", armoredName, 1, function(index)
            selectedArmoredV = armoredName[index]
            armoredHash = armoredModel[selectedArmoredV]
        end)
        
        GroundParts:action("Send Ground Army", {"interusarmy"}, "Sending America to war and intervene more ground vehicles.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features", function()
            local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            for _, pid in pairs(playerList) do
                if AvailableSession() then
                    for i = 1, 2 do
                        groundAttack(pid, armoredHash, false)
                        InterWait(10000)
                    end
                end
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        GroundParts:divider("Advanced")
        CustomVehicle = GroundParts:toggle_loop("Custom Vehicle", {}, "", function()end)
        GroundParts:action("Send Ground Army (Custom)", {"interusarmycustom"}, "Sending America to war and intervene more ground vehicles.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features", function()
            local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            if menu.get_value(CustomVehicle) == true then
                local textInput = display_onscreen_keyboard()
                if textInput == "" or textInput == nil then return end
                for _, pid in pairs(playerList) do
                    if AvailableSession() then
                        groundAttack(pid, textInput, true)
                        InterWait(10000)
                    end
                end
            else
                InterNotify("I'm sorry, enable \"Custom Vehicle\" to use more advantages.")
            end
        end)

    ----========================================----
    ---              Bounty Roots
    ---         The part of bounty online
    ----========================================----

        BountyRoot:divider("Options for Bounty")
        CustomBounty = BountyRoot:toggle_loop("Custom Bounty", {}, "", function()end)
        BountyRoot:action("Set Bounty (Instantly)", {'intermanualbounty'}, "Alright, let's start a new war for everyone, you will be happy to see that.\nNOTE: Toggle Exclude features.",function()
            if menu.get_value(CustomBounty) == true then
                local inputValue = display_onscreen_keyboard()
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_bounty(pid) ~= inputValue and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        InterCmds("bounty"..players.get_name(pid).." "..inputValue)
                    end
                    InterWait(50)
                end
                InterWait(500)
            else
                InterNotify("I'm sorry, you need to turn on \"Custom Bounty\" for this.")
            end
        end)
        
        BountyRoot:divider("")

        BountyValue = BountyRoot:slider("Select Amount Bounty",  {'interbounty'}, "Select which amount it will automatically placed.",  0, 10000, 0, 1, function()end)
        BountyRoot:toggle_loop("Auto-Bounty Players", {'interautobounty'}, "Alright, let's start a new war for everyone, you will be happy to see that.\nNOTE: Toggle Exclude features.",function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_bounty(pid) ~= menu.get_value(BountyValue) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    InterCmds("bounty"..players.get_name(pid).." "..menu.get_value(BountyValue))
                end
                InterWait(50)
            end
            InterWait(500)
        end)

        BountyRoot:action_slider("Bounty Type", {}, "Alright, let's start a new war for everyone, you will be happy to see that.\nNOTE: Toggle Exclude features.\n- Manual Bounty means you have set up \"Select Amount Bounty\".\n\n- Random Bounty means you distribute the bounty differently. It will be independent from \"Select Amount Bounty\".", {"Manual", "Random"}, function(bountySelect)
            if bountySelect == 1 then
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_bounty(pid) ~= menu.get_value(BountyValue) and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        InterCmds("bounty"..players.get_name(pid).." "..menu.get_value(BountyValue))
                    end
                    InterWait(50)
                end
                InterWait(500)
            else
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        local playerBounty = math.random(1, 10000)
                        InterCmds("bounty " .. players.get_name(pid) .. " " .. playerBounty)
                    end
                    InterWait(50)
                end
                InterWait(500)     
            end
        end)

        BountyRoot:divider("Advanced")
        CustomBountyP = BountyRoot:toggle_loop("Custom Bounty (Player)", {}, "", function()end)

        local bountyValue = 0
        BountyRoot:text_input("Modify Bounty Value", {"interbountyvalue"}, "", function(valueInput)
            if valueInput ~= "" then
                bountyValue = tonumber(valueInput)
            else
                bountyValue = 0
            end
        end, bountyValue)

        BountyRoot:action("Enter Name", {"interbountyuser"}, "", function()
            if menu.get_value(CustomBountyP) == true then
                local textInput = display_onscreen_keyboard()
                local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if EToggleSelf then
                    for _, pid in ipairs(playerList) do
                        if pid == players.user() and textInput == players.get_name(pid) then
                            InterNotify("You cannot put bounty yourself.")
                            return
                        end
                    end
                end
                if textInput == nil or textInput == "" then
                    return
                else
                    local bountyPlaced = false
                    for _, pid in ipairs(playerList) do
                        local playerName = players.get_name(pid)
                        if playerName == textInput then
                            bountyPlaced = true
                            InterNotify("Bounty sent to "..textInput.." with $"..bountyValue..".")
                            InterCmds("bounty " ..playerName.. " " ..bountyValue)
                            break
                        end
                    end
                    if not bountyPlaced then
                        InterNotify("We can't recognize who is "..textInput..".")
                    end
                end
            else
                InterNotify("I'm sorry, you need to turn on \"Custom Bounty (Player)\" to do the action.")
            end
        end)

    ----========================================----
    ---              Explosion Roots
    ---         The part of explode online
    ----========================================----

        AudibleExplode = ExplodeRoot:toggle_loop("Toggle Audible", {}, "Read the function:\n- True: The explosion is audible\n- False: The explosion is not audible", function()end)
        VisibleExplode = ExplodeRoot:toggle_loop("Toggle Visible Explosion", {}, "Read the function:\n- True: The explosion is invisible\n- False: The explosion is visible", function()end)
        ExplodeRoot:toggle("Toggle Reveal Kill", {}, "Read the function:\n- True: You will able to reveal who you are killing players.\n- False: You are not revealed.", function(toggle) RevealKill = toggle end)
        local classifiedExplosion = 0
        ExplodeRoot:list_select("Explosion Type", {""}, "", explosion_types, 0, function(value)
            classifiedExplosion = value
        end)
        EShakeIntensity = ExplodeRoot:slider("Explosion Shake", {"intereshake"}, "Choose shake explosion intensity [0 - 10]", 0, 10, 1, 1, function()end)
        ExplodeRoot:action_slider("Orbital Cannon Type", {}, "Say hi to the sky", {"Non-Personal", "Owned", "Randomize"}, function(orbSelect)
            if orbSelect == 1 then
                for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if not players.is_in_interior(pid) and not players.is_godmode(pid) then
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
                    end
                end
            elseif orbSelect == 2 then
                for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if not players.is_in_interior(pid) and not players.is_godmode(pid) then
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
                    end
                end
            else
                for _, pid in pairs(players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        if not players.is_in_interior(pid) and not players.is_godmode(pid) then
                            local pos = players.get_position(pid)
                            pos.z = pos.z - 1.0
                            local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                            local randomIndex = math.random(#playerList)
                            local playerId = playerList[randomIndex]
                            local Ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerId)
                            STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_xm_orbital")
                            FIRE.ADD_OWNED_EXPLOSION(Ped, pos.x, pos.y, pos.z, 59, 1, true, false, 9.9, false)
                            InterWait(0)
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
                        end
                    end
                end
            end
        end)

        ExplodeRoot:divider("Explosion Type")
        ExplodeRoot:toggle_loop("Auto Explode Players", {'interautoexplode'}, "Alright, explode everyone.\nNOTE: Toggle Exclude features.\nToggle Reveal Kill will reveal who kill.\n\nDisable Toggle Audible/Visible Explosion will make you silent kill.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    if not players.is_in_interior(pid) and not players.is_godmode(pid) then
                        local pos = players.get_position(pid)
                        pos.z = pos.z - 1.0
                        if not RevealKill then
                            for i = 1, 10 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, menu.get_value(AudibleExplode), menu.get_value(VisibleExplode), menu.get_value(EShakeIntensity), false)
                            end
                        else
                            for i = 1, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, classifiedExplosion, 1, menu.get_value(AudibleExplode), menu.get_value(VisibleExplode), menu.get_value(EShakeIntensity), false)
                            end
                        end
                    end
                end
                InterWait(50)
            end
            InterWait(500)
        end)

        ExplodeRoot:toggle_loop("Auto Gas Mode", {'intergasexplode'}, "Alright, gasing everyone. Use the features, you will send to the death because you are considered like war criminal.\nNOTE: Toggle Exclude features.\nToggle Reveal Kill will reveal who kill.\n\nDisable Toggle Audible/Visible Explosion will make you silent kill.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    if not players.is_in_interior(pid) and not players.is_godmode(pid) then
                        local pos = players.get_position(pid)
                        pos.z = pos.z - 1.0
                        if not RevealKill then
                            for i = 1, 3 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 48, 1, true, true, 0.0, false)
                            end
                        else
                            for i = 1, 3 do
                                FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 48, 1, menu.get_value(AudibleExplode), menu.get_value(VisibleExplode), 0.0, false)
                            end
                        end
                    end
                end
                InterWait(50)
            end
            InterWait(500)
        end)

        ExplodeRoot:toggle_loop("Auto Explode Players (Randomize)", {'interautorexplode'}, "Alright, explode everyone but randomized.\nNOTE: Toggle Exclude features.\nIt will not count player if the player is in interior or godmode.\n\nDisable Toggle Audible/Visible Explosion will make you silent kill.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    if not players.is_in_interior(pid) and not players.is_godmode(pid) then
                        local pos = players.get_position(pid)
                        pos.z = pos.z - 1.0
                        local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                        local randomIndex = math.random(#playerList)
                        local playerId = playerList[randomIndex]
                        local Ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerId)
                        for i = 1, 10 do
                            FIRE.ADD_OWNED_EXPLOSION(Ped, pos.x, pos.y, pos.z, classifiedExplosion, 1, menu.get_value(AudibleExplode), menu.get_value(VisibleExplode), menu.get_value(EShakeIntensity), false)
                        end
                    end
                end
                InterWait(50)
            end
            InterWait(500)
        end)

        ExplodeRoot:toggle_loop("Auto Gas Mode (Randomize)", {'interautorexplode'}, "Alright, gasing everyone but randomized. Use the features, you will send to the death because you are considered like war criminal.\nNOTE: Toggle Exclude features.\nIt will not count player if the player is in interior or godmode.\n\nDisable Toggle Audible/Visible Explosion will make you silent kill.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    if not players.is_in_interior(pid) and not players.is_godmode(pid) then
                        local pos = players.get_position(pid)
                        pos.z = pos.z - 1.0
                        local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                        local randomIndex = math.random(#playerList)
                        local playerId = playerList[randomIndex]
                        local Ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(playerId)
                        for i = 1, 10 do
                            FIRE.ADD_OWNED_EXPLOSION(Ped, pos.x, pos.y, pos.z, 48, 1, menu.get_value(AudibleExplode), menu.get_value(VisibleExplode), 0.0, false)
                        end
                    end
                end
                InterWait(50)
            end
            InterWait(500)
        end)

    ----========================================----
    ---                SOUND Parts
    ---       PRESS HORN AND MORE AGGRESSIVE
    ----========================================----

        local function playSoundFromEntity(soundName, soundSet)
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    for i = 0, menu.get_value(SoundVolumeR) do
                        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, soundName, PLAYER.GET_PLAYER_PED(pid), soundSet, true, true)
                    end
                end
                InterWait(30)
            end
            InterWait(100)
        end

        SoundVolumeR = SoundRoots:slider("Sound Volume", {"intervolume"}, "", 0, 100, 0, 1, function()end)
        SoundRoots:action("Stop Sounds", {}, "", function() for i = 0, 100 do AUDIO.STOP_SOUND(i) end end)
        SoundRoots:divider("Single Usage Sounds")

        local soundRootsList = {
            ["Boat Horn"] = {"Horn", "DLC_Apt_Yacht_Ambient_Soundset"},
            ["Walkie Talkie"] = {"Start_Squelch", "CB_RADIO_SFX"},
            ["Air Defense Missiles"] = {"Air_Defences_Activated", "DLC_sum20_Business_Battle_AC_Sounds"},
            ["Surface-to-Air Missiles"] = {"Fire", "DLC_BTL_Terrobyte_Turret_Sounds"},
            ["Countdown Stop"] = {"TIMER_STOP", "HUD_MINI_GAME_SOUNDSET"},
            ["Arming Countdown"] = {"Arming_Countdown", "GTAO_Speed_Convoy_Soundset"},
            ["Bomb Disarmed"] = {"Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset"},
            ["Camera Shoot"] = {"Camera_Shoot", "Phone_Soundset_Franklin"},
            ["Challenge Unlocked"] = {"CHALLENGE_UNLOCKED", "HUD_AWARDS"},
        }

        local soundRootsSorted = {}

        for name, sound in pairs(soundRootsList) do
            table.insert(soundRootsSorted, {name, sound})
        end
        
        table.sort(soundRootsSorted, function(a, b) return a[1] < b[1] end)
        
        for _, soundData in ipairs(soundRootsSorted) do
            local name = soundData[1]
            local sound = soundData[2]
            SoundRoots:action(name, {}, "", function()
                playSoundFromEntity(sound[1], sound[2])
            end)
        end

        SoundRoots:divider("Loop Sounds")

        for _, soundData in ipairs(soundRootsSorted) do
            local name = soundData[1]
            local sound = soundData[2]
            SoundRoots:toggle_loop(name, {}, "", function()
                playSoundFromEntity(sound[1], sound[2])
            end)
        end

    ----========================================----
    ---              Teleports Parts
    ---     The part of teleport online parts
    ----========================================----

        local appartType = 1
        TeleportsRoots:list_select("Apartment Type", {""}, "", property_id, 1, function(index)
            appartType = index
        end)

        TeleportWarning = TeleportsRoots:action("Teleport Apartment Location", {"interapt"}, "Teleport the entire session?\nAlternative to Stand Features but may not karma you.\n\nToggle 'Exclude Self' to avoid using these functions.",function(type)
            menu.show_warning(TeleportWarning, type, "Do you really want to teleport the entire session to the death?\nNOTE: Teleporting all players will cost a fight against players.", function()
                local playerList = players.list(false, false, EToggleStrangers, EToggleCrew, EToggleOrg)
                for _, pid in pairs(playerList) do
                    if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        InterCmds("apt"..appartType..players.get_name(pid))
                    end
                end
            end)
        end)

        TeleportsRoots:action_slider("Teleport Type", {}, "Different type of teleportation:\n- Near Location\n- Uniform (Teleporting from Random Apartment)\n- Mixed (Teleporting from Random Apartment but distributed throughout the map)", {"Near Location", "Uniform", "Mixed"}, function(tpSelect)
            if tpSelect == 1 then
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        InterCmds("aptme"..players.get_name(pid))
                    end
                end
            elseif tpSelect == 2 then
                local APTRandT = rand(1, 114)
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        InterCmds("apt"..APTRandT..players.get_name(pid))
                    end
                end
            else
                local assignedApartments = {}
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                    if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                        local APTRandom
                        repeat
                            APTRandom = rand(1, 114)
                        until not assignedApartments[APTRandom]
                        assignedApartments[APTRandom] = true
                        InterCmds("apt"..APTRandom..players.get_name(pid))
                    end
                end
            end
        end)

        TeleportsRoots:divider("Advanced")

        RandomTeleportCustom = TeleportsRoots:toggle_loop("Random Teleport", {}, "Without Random Teleport => Apartment Type\nWith Random Teleport => randomly generated between 1 and 114.", function()end)
        TeleportCustom = TeleportsRoots:toggle_loop("Toggle Teleport User", {}, "", function()end)
        TeleportsRoots:action("Enter Name", {"interteleportuser"}, "", function()
            if menu.get_value(TeleportCustom) == true then
                local textInput = display_onscreen_keyboard()
                local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if menu.get_value(RandomTeleportCustom) == true then
                    if EToggleSelf then
                        for _, pid in ipairs(playerList) do
                            if pid == players.user() and textInput == players.get_name(pid) then
                                InterNotify("You cannot teleport yourself.")
                                return
                            end
                        end
                    end
                    if textInput == nil or textInput == "" then return
                    else
                        local telported = false
                        for _, pid in ipairs(playerList) do
                            local playerName = players.get_name(pid)
                            if playerName == textInput then
                                telported = true
                                InterNotify("Teleport sent to "..textInput.." randomly.")
                                InterCmds("apt"..math.random(1, 114)..playerName)
                                break
                            end
                        end
                        if not telported then
                            InterNotify("We cannot recognize "..textInput..".")
                        end
                    end
                else
                    if EToggleSelf then
                        for _, pid in ipairs(playerList) do
                            if pid == players.user() and textInput == players.get_name(pid) then
                                InterNotify("You cannot teleport yourself.")
                                return
                            end
                        end
                    end
                    if textInput == nil or textInput == "" then return
                    else
                        local telported = false
                        for _, pid in ipairs(playerList) do
                            local playerName = players.get_name(pid)
                            if playerName == textInput then
                                telported = true
                                InterNotify("Teleport sent to "..textInput..".")
                                InterCmds("apt"..appartType..playerName)
                                break
                            end
                        end
                        if not telported then
                            InterNotify("We cannot recognize "..textInput..".")
                        end
                    end
                end
            else
                InterNotify("I'm sorry, please enable 'Toggle Teleport User'.")
            end
        end)

    ----========================================----
    ---              Session Parts
    ---         The part of session online
    ----========================================----

        SessionRoots:action("Write Death Note", {"interdeathnote"}, "Write one name: Adolf Hitler\nYou can't kill yourself.\n\nFor future prevention: Enable 'Exclude Self' will show a error message if you write your own name.", function()
            local textInput = display_onscreen_keyboard()
            local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            if EToggleSelf then
                for _, pid in ipairs(playerList) do
                    if pid == players.user() and textInput == players.get_name(pid) then
                        InterNotify("You cannot kill yourself.")
                        return
                    end
                end
            end
            if textInput == nil or textInput == "" then
                InterNotify("Please enter a name before attempting to kill.")
            else
                local isKilled = false
                for _, pid in ipairs(playerList) do
                    local playerName = players.get_name(pid)
                    local pos = players.get_position(pid)
                    if playerName == textInput then
                        isKilled = true
                        InterNotify("Sending death to "..textInput..".")
                        FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 7, 1000, false, true, 0)
                        break
                    end
                end
                if not isKilled then
                    InterNotify("Who the fuck is "..textInput.."?")
                end
            end
        end)

        SessionRoots:toggle("Toggle Passive Mode", {'interpassivemode'}, "Toggle Passive Mode for everyone if they can't use.\nNOTE: Toggle Exclude features", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    InterCmds("nopassivemode"..players.get_name(pid))
                end
                InterWait(50)
            end
            InterWait(500)
        end)

        SessionRoots:action_slider("Random Action Player", {}, "Different types of player actions:\n- Teleport Player\n- Kick Player\n- Crash Player\n- Bounty Player", {"Teleport", "Kick", "Crash", "Bounty"}, function(randselect)
            if randselect == 1 then
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local RandAPT = rand(0, 114)
                    local playerName = players.get_name(playerList[randomIndex])
                    InterNotify("Player name targeted randomly teleported: "..playerName)
                    InterCmds("apt"..RandAPT..playerName)
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 2 then
                local commands = {"breakup", "nonhostkick", "kick", "ban"}
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerName = players.get_name(playerList[randomIndex])
                    InterNotify("Player name randomly targeted: "..playerName)
                    for _, command in ipairs(commands) do
                        InterCmds(command..playerName)
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 3 then
                local commands = {"crash", "choke", "flashcrash", "ngcrash"}
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerName = players.get_name(playerList[randomIndex])
                    InterNotify("Player name randomly targeted: "..playerName)
                    for _, command in ipairs(commands) do
                        InterCmds(command..playerName)
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            else
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    bountyRand = math.random(1, 10000)
                    local randomIndex = math.random(#playerList)
                    local playerName = players.get_name(playerList[randomIndex])
                    InterNotify("Player name randomly targeted: "..playerName.."\nBounty Randomized: $"..bountyRand)
                    InterCmds("bounty"..playerName.." "..bountyRand)
                else
                    InterNotify("No players are currently in the session.")
                end
            end
        end)

        SessionRoots:action_slider("Random Elimination", {}, "Different type of eliminations:\n- Explosive\n- Silent Mode\n- Gas Mode\n- Randomize\n- Gas Randomize\n- Silent Random\n- Russian Roulette", {"Explosive", "Silent Mode", "Gas Mode", "Randomize", "Gas Randomize", "Silent Random", "Russian Roulette"}, function(randselect)
            if randselect == 1 then -- Explosive
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    local playerName = players.get_name(playerId)
                    if not PLAYER.IS_PLAYER_DEAD(playerId) then
                        if not players.is_in_interior(playerId) and not players.is_godmode(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            InterNotify("Random player name targeted kill: "..playerName)
                            for i = 0, 5 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 2 then -- Silent Kill
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    local playerName = players.get_name(playerId)
                    if not PLAYER.IS_PLAYER_DEAD(playerId) then
                        if not players.is_in_interior(playerId) and not players.is_godmode(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            InterNotify("Random player name targeted kill: "..playerName)
                            for i = 0, 5 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, false, true, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, false, true, 0.0, false)
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 3 then -- Gas Mode
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    local playerName = players.get_name(playerId)
                    if not PLAYER.IS_PLAYER_DEAD(playerId) then
                        if not players.is_in_interior(playerId) and not players.is_godmode(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            InterNotify("Random player name targeted kill: "..playerName)
                            for i = 0, 5 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 48, 1, true, false, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 48, 1, true, false, 0.0, false)
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 4 then -- Randomize Explosion
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    local playerName = players.get_name(playerId)
                    if not PLAYER.IS_PLAYER_DEAD(playerId) then
                        if AvailableSession() and not players.is_in_interior(playerId) and not players.is_godmode(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            local randomPlayerIndex = math.random(#playerList)
                            local randomPlayerId = playerList[randomPlayerIndex]
                            local randomPlayerName = players.get_name(randomPlayerId)
                            local RandomPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(randomPlayerId)
                            
                            if randomPlayerId ~= playerId then
                                InterNotify("Random player killer: "..randomPlayerName.."\nVictim target: "..playerName)
                            else
                                InterNotify(playerName.." eliminated themselves.")
                            end
                            for i = 0, 5 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 5 then -- Randomize Gas
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    local playerName = players.get_name(playerId)
                    if not PLAYER.IS_PLAYER_DEAD(playerId) then
                        if AvailableSession() and not players.is_in_interior(playerId) and not players.is_godmode(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            local randomPlayerIndex = math.random(#playerList)
                            local randomPlayerId = playerList[randomPlayerIndex]
                            local randomPlayerName = players.get_name(randomPlayerId)
                            local RandomPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(randomPlayerId)
                            
                            if randomPlayerId ~= playerId then
                                InterNotify("Random player killer: "..randomPlayerName.."\nVictim target: "..playerName)
                            else
                                InterNotify(playerName.." eliminated themselves.")
                            end
                            for i = 0, 5 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 48, 1, true, false, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 48, 1, true, false, 0.0, false)
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            elseif randselect == 6 then -- Silent Kill Random
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    local playerName = players.get_name(playerId)
                    if not PLAYER.IS_PLAYER_DEAD(playerId) then
                        if AvailableSession() and not players.is_in_interior(playerId) and not players.is_godmode(playerId) and not players.is_marked_as_modder(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            local randomPlayerIndex = math.random(#playerList)
                            local randomPlayerId = playerList[randomPlayerIndex]
                            local randomPlayerName = players.get_name(randomPlayerId)
                            local RandomPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(randomPlayerId)
                            
                            if randomPlayerId ~= playerId then
                                InterNotify("Random player killer: "..randomPlayerName.."\nVictim target: "..playerName)
                            else
                                InterNotify(playerName.." eliminated themselves.")
                            end
                            for i = 0, 5 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 34, 1, false, true, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 34, 1, false, true, 0.0, false)
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            else
                local playerList = players.list(false, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
                if #playerList > 0 then
                    local randomIndex = math.random(#playerList)
                    local playerId = playerList[randomIndex]
                    if not PLAYER.IS_PLAYER_DEAD(playerId) and playerId ~= PLAYER.PLAYER_ID() then
                        local playerName = players.get_name(playerId)
                        -- Simulating the survival chance using a random number from 1 to 6
                        local survivalChance = math.random(6)
                        if not players.is_in_interior(playerId) and not players.is_godmode(playerId) then
                            local pos = players.get_position(playerId)
                            pos.z = pos.z - 1.0
                            if survivalChance == 1 then
                                InterNotify(playerName.." survived the Russian Roulette.")
                            else
                                InterNotify(playerName.." did not survive the Russian Roulette.")
                                -- Triggering explosions to simulate elimination
                                for i = 0, 5 do
                                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, false, true, 0.0, false)
                                end
                                InterWait(100)
                                for i = 0, 10 do
                                    FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 34, 1, false, true, 0.0, false)
                                end
                            end
                        else
                            return
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            end
        end)

    ----========================================----
    ---              Vehicle Roots
    ---         The part of vehicle online
    ----========================================----
    
        local AdvancedVehicles = VehicleRootsO:list("Advanced Settings", {}, "Applicable for all players but exceptions.")
        VehicleRootsO:list_action("Preset Cars", {}, "", vehicleData, function(index)
            local hash = util.joaat(vehicleData[index])
            local function upgrade_vehicle(vehicle)
                if menu.get_value(ToggleUpgradeAll) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                else
                    VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                end
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(PlateIndexAll))
                if PlateNameAll == nil then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, RandomPlate())
                else
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, PlateNameAll)
                end
            end
            if not STREAMING.HAS_MODEL_LOADED(hash) then
                LoadingModel(hash)
            end
            for k,v in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
                local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 6.5, -1.0)
                local veh = entities.create_vehicle(hash, c, CAM.GET_FINAL_RENDERED_CAM_ROT(2).z)
                upgrade_vehicle(veh)
                ENTITY.SET_ENTITY_INVINCIBLE(veh, menu.get_value(ToggleGodAll))
                VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, menu.get_value(WindowTintAll))
                RequestControlOfEntity(veh)
                local InvincibleStatus = menu.get_value(ToggleGodAll) and "Active" or "Inactive"
                local UpgradedCar = menu.get_value(ToggleUpgradeAll) and "Active" or "Inactive"
                if PlateNameAll == nil then
                    InterNotify("You have spawned: "..vehicleData[index].. " for everyone with the parameters: \n- Plate Color: "..menu.get_value(PlateIndexAll).."\n- Window Tint: "..menu.get_value(WindowTintAll).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar)
                else
                    InterNotify("You have spawned: "..vehicleData[index].. " for everyone with the parameters: \n- Plate Name: "..PlateNameAll.."\n- Plate Color: "..menu.get_value(PlateIndexAll).."\n- Window Tint: "..menu.get_value(WindowTintAll).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar)
                end
            end
        end)

        VehicleRootsO:action("Spawn Vehicle", {"interspawn"}, "Spawn everyone a vehicle.\nNOTE: It will applied also some modification like Plate License (name/color)", function()
            local txt = display_onscreen_keyboard()
            if txt == nil or txt == "" then return end
            local hash = util.joaat(txt)
            if not STREAMING.HAS_MODEL_LOADED(hash) then
                LoadingModel(hash)
            end
            local function upgrade_vehicle(vehicle)
                if menu.get_value(ToggleUpgradeAll) == true then
                    for i = 0,49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    end
                else
                    VEHICLE.SET_VEHICLE_MOD(vehicle, 0, 0 - 1, true)
                end
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, menu.get_value(PlateIndexAll))
                if PlateNameAll == nil then
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, RandomPlate())
                else
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, PlateNameAll)
                end
            end
            for k,v in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if STREAMING.IS_MODEL_A_VEHICLE(hash) then
                    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(v)
                    local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 5.0, 0.0)
                    local vehicle = entities.create_vehicle(hash, c, 0)
                    if menu.get_value(TogglePaintAll) == true then
                        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 0, math.random(0, 255), math.random(0, 255))
                        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    end
                    ENTITY.SET_ENTITY_INVINCIBLE(vehicle, menu.get_value(ToggleGodAll))
                    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, menu.get_value(WindowTintAll))
                    upgrade_vehicle(vehicle)
                    RequestControlOfEntity(vehicle)

                    local InvincibleStatus = menu.get_value(ToggleGodAll) and "Active" or "Inactive"
                    local UpgradedCar = menu.get_value(ToggleUpgradeAll) and "Active" or "Inactive"
                    local RandomPainter = menu.get_value(TogglePaintAll) and "Active" or "Inactive"
                    if PlateNameAll == nil then
                        InterNotify("You have spawned: "..txt.. " for everyone with the parameters: \n- Plate Color: "..menu.get_value(PlateIndexAll).."\n- Window Tint: "..menu.get_value(WindowTintAll).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar.."\n- Random Paint: "..RandomPainter)
                    else
                        InterNotify("You have spawned: "..txt.. " for everyone with the parameters: \n- Plate Name: "..PlateNameAll.."\n- Plate Color: "..menu.get_value(PlateIndexAll).."\n- Window Tint: "..menu.get_value(WindowTintAll).."\n- Invincible Status: "..InvincibleStatus.."\n- Upgrade Status: "..UpgradedCar.."\n- Random Paint: "..RandomPainter)
                    end
                else
                    InterNotify("The model named: "..txt.." is not recognized, please retry later.")
                end
                InterWait()
            end
        end)

        VehicleRootsO:text_input("Plate Name", {"interplate"}, "Apply Plate Name when summoning vehicles.\nYou are not allowed to write more than 8 characters.", function(name)
            if name ~= "" then
                PlateNameAll = name:sub(1, 8)
            else
                PlateNameAll = nil
            end                    
        end)
        
        ToggleGodAll = VehicleRootsO:toggle_loop("Toggle Invincible Vehicle", {}, "", function()end)
        ToggleUpgradeAll = VehicleRootsO:toggle_loop("Toggle Upgrade Cars", {}, "", function()end)
        TogglePaintAll = VehicleRootsO:toggle_loop("Toggle Random Paint", {}, "", function()end)
        PlateIndexAll = VehicleRootsO:slider("Plate Color", {"interplc"}, "Choose Plate Color.", 0, 5, 0, 1, function()end)
        WindowTintAll = VehicleRootsO:slider("Window Tint", {"interwt"}, "Choose Window tint Color.", 0, 6, 0, 1, function()end)

    ----========================================----
    ---            Advance Vehicles Roots
    ---         The part of vehicle online
    ----========================================----
        
        AdvancedVehicles:action("Change Plate Name", {}, "Troll all players if they are in a vehicle. Name them to make proud of Austrian Painter.\n".."NOTE: Toggle Exclude features to avoid impacted.", function()
            local name = display_onscreen_keyboard()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if name ~= "" or name == nil then
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, name)
                    else
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, RandomPlate())
                    end
                end
            end
        end)

        AdvancedVehicles:toggle_loop("Lock Vehicle", {}, "Troll all players if they are in a vehicle.".."\n".."Proving they can't exit their car.\n".."NOTE: Toggle Exclude features to avoid impacted.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerVehicle, 4)
                end
            end
        end, function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(playerVehicle, 0)
                end
            end
        end)

        AdvancedVehicles:toggle_loop("Pink Color", {}, "I love pink color, bcz we called it before Pink menu.\n".."NOTE: Toggle Exclude features to avoid impacted.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(playerVehicle, 255, 0, 255)
                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(playerVehicle, 255, 0, 255)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, "STAND")
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(playerVehicle, 5)
                    VEHICLE.SET_VEHICLE_WINDOW_TINT(playerVehicle, 1)
                    for i = 0, 49 do
                        local num = VEHICLE.GET_NUM_VEHICLE_MODS(playerVehicle, i)
                        VEHICLE.SET_VEHICLE_MOD(playerVehicle, i, num - 1, true)
                    end
                end
            end
        end)

        AdvancedVehicles:toggle_loop("Cut Engine", {}, "cut completely engine for all players.\n".."NOTE: Toggle Exclude features to avoid impacted.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(playerVehicle, false, true, true)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(playerVehicle, -4000)
                    VEHICLE.SET_VEHICLE_BODY_HEALTH(playerVehicle, -4000)
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(playerVehicle, -4000)
                    VEHICLE.SET_VEHICLE_UNDRIVEABLE(playerVehicle, true)
                end
            end
        end, function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(playerVehicle, true, true, false)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(playerVehicle, 1000)
                    VEHICLE.SET_VEHICLE_BODY_HEALTH(playerVehicle, 1000)
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(playerVehicle, 1000)
                    VEHICLE.SET_VEHICLE_UNDRIVEABLE(playerVehicle, false)
                end
            end
        end)

        AdvancedVehicles:action("Remove Player Vehicle", {}, "Remove instantly player's cars.\n".."NOTE: Toggle Exclude features to avoid impacted.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    entities.delete_by_handle(playerVehicle)
                end
            end
        end)

        local vehicleSpeedINT = 50.0
        AdvancedVehicles:text_input("Modify Speed", {"intvehspeed"}, "", function(valueInput)
            if valueInput ~= "" then
                vehicleSpeedINT = tonumber(valueInput)
            else
                vehicleSpeedINT = 50.0
            end
        end)

        AdvancedVehicles:toggle_loop("Uncontrollable Vehicle", {}, "Boost faster to deform vehicle without any manner to control.\n".."NOTE: Toggle Exclude features to avoid impacted.", function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(playerVehicle, vehicleSpeedINT)
                end
            end
        end, function()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(playerVehicle, 0)
                end
            end
        end)

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
            if menu.get_value(PinkColors) then
                menu.set_value(PinkColors, false)
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
            menu.set_value(PinkColors, false)
        end)

        PinkColors = WorldParts:toggle_loop("Pink Color", {}, "Pray for Pink Menu", function()
            if menu.get_value(GColors) then
                menu.set_value(GColors, false)
            end
            for k, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                for i = 0,49 do
                    local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)
                    VEHICLE.SET_VEHICLE_MOD(vehicle, i, num - 1, true)
                    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, 2)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, 5)
                end
                VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, 255, 0, 255)
                VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, 255, 0, 255)
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "STAND")
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

        WorldParts:toggle_loop("Cut Engine nearby vehicles", {}, "It will guaranteed cut engine for all vehicle (nearby).\n\nNOTE: It will affect players while driving and can cut off.", function()
            for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                if vehicle ~= entities.get_user_personal_vehicle_as_handle() then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, false, true, true)
                end
            end
        end, function()
            VEHICLE.SET_VEHICLE_ENGINE_ON(entities.get_all_vehicles_as_handles(), false, true, true)
        end)

        WorldParts:action("Change Plate for nearby vehicles", {}, "Fail or not? Hitler will be proud of this.", function()
            local txt = display_onscreen_keyboard()
            for _, vehicle in pairs(entities.get_all_vehicles_as_handles()) do
                if vehicle ~= entities.get_user_personal_vehicle_as_handle() then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
                    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, txt)
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

        WeatherFeatures:toggle_loop("Remove Clouds", {"interremoveclouds"}, "*works locally*", function() MISC.UNLOAD_ALL_CLOUD_HATS() end)

    ----========================================----
    ---              Music Parts
    ---         The part of music parts
    ----========================================----

        MusicParts:action("Open Music Folders", {}, "Edit your music and enjoy.\nNOTE: You need to put .wav file.\nMP3 or another files contains invalid file are not accepted.", function()
            util.open_folder(script_store_songs)
        end)

        AutoCooldown = MusicParts:slider("Cooldown Random Music", {"interrcrm"}, "Each interval has a specific time, do not spam like crazy and calm down.", 30, 300, 30, 1, function()end)     
        local InterMuList = MusicParts:list_action("Load Musics", {"intermloadmusic"}, "WARNING: Heavy folder, so check if you have big storage, atleast average .wav file: 25-100 MB.", InterMusicFiles, function(selected_index)
            local selected_file = InterMusicFiles[selected_index]
            for _, song in ipairs(InterLoadedSongs) do
                if song.file == selected_file then
                    local sound_location = song.sound
                    if not filesystem.exists(sound_location) then
                        InterNotify("Sound file does not exist: " .. sound_location)
                    else
                        local display_text = string.gsub(selected_file, "%.wav$", "")
                        PlayAuto(sound_location)
                        InterNotify("Selected Music: " .. display_text)
                    end
                    break
                end
            end
        end)

        local PresetsMusics = MusicParts:list("Preset Musics")

        MusicParts:action("Stop Music", {'intermstop'}, "It will stop your music instantly.\nNOTE: Don't delete the folder called Stop Sounds, music won't stop and looped. Don't rename file.", function() -- Force automatically stop your musics
            local sound_location_1 = join_path(script_resources, "stops.wav")
            if not filesystem.exists(sound_location_1) then
                InterNotify("Music file does not exist: " .. sound_location_1.. "\n\n".."NOTE: You need to get the file, otherwise you can't stop the sound.")
            else
                PlaySong(sound_location_1, SND_FILENAME | SND_ASYNC)
            end
        end)

    ----========================================----
    ---             Presets Musics
    ----========================================----

        local PresetMusicParts = script_resources .. "/PresetsMusics"
        local songs = {
            {"Bad To The Bone", "George Thorogood & The Destroyers", "BadToTheBone", "September 1982", "Freedom & Liberty"},
            {"California Dreamin", "The Mamas & The Papas", "CaliforniaDreamin", "December 1965", "Fighting for Freedom / Vietnam War"},
            {"Danger Zone", "Kenny Loggins", "DangerZone", "May 1986", "Promoting Top Gun"},
            {"Everybody Wants To Rule The World", "Tears For Fears", "RuleTheWorld", "March 1985", "Consumer Society / Control the World (USSR/USA) / Gulf War"},
            {"Fortunate Son", "Creedence Clearwater Revival", "FortunateSon", "September 1969", "Vietnam War"},
            {"Master of Puppets", "Metallica", "MasterOfPuppets", "March 1986", "Freedom & Liberty"},
            {"Paint It, Black", "The Rolling Stones", "PaintItBlack", "May 1966", "Civil Rights / Vietnam War"},
            {"Paranoid", "Black Sabbath", "Paranoid", "September 1970", "Civil Rights / Peace World / Vietnam War"},
            {"Should I Stay or Should I Go", "The Clash", "ShouldIGo", "September 1982", "Freedom & Liberty / Indecision and Anxiety"},
            {"Mississippi Queen", "Mountain", "MississippiQueen", "February 1970", "Post Vietnam War"},
            {"Material Girl", "Madonna", "MaterialGirl", "January 1985", "Consumer Society / Individualism"},
            {"Highway to Hell", "AC/DC", "HighwayToHell", "July 1979", "Spirit of Rebellion"}
        }
        
        table.sort(songs, function(a, b) return a[1] < b[1] end)
        
        for _, song in ipairs(songs) do
            PresetsMusics:action(song[1], {}, "Play \""..song[1].."\" by "..song[2].."\nReleased date: "..song[4].."\nContext: "..song[5], function()
                PlaySong(join_path(PresetMusicParts, song[3]..".wav"), SND_FILENAME | SND_ASYNC)
            end)
        end

    ----========================================----
    ---              Loop Parts
    ---         The part of function parts
    ----========================================----

        util.on_stop(function()
            PlaySong(join_path(script_resources, "stops.wav"), SND_FILENAME | SND_ASYNC)
        end)

        util.create_thread(function()
            while true do
                InterWait(3000) 
                currentPlate = plateTables[math.random(#plateTables)]
            end
        end)

        util.create_thread(function()
            while true do
                UpdateAutoMusics()
                CheckSongs()
                check_music_folder()
                menu.set_list_action_options(InterMuList, InterMusicFiles)
                InterWait(250)
            end
        end)

    ----========================================----
    ---              Settings Parts
    ---         The part of settings parts
    ----========================================----

        SettingsParts:divider("Settings")

        SettingsParts:readonly("Script Version", SCRIPT_VERSION)
        SettingsParts:readonly("Stand Version", STAND_VERSION)

        NotifMode = "Stand"
        SettingsParts:list_select("Notify Mode", {}, "", {"Stand", "Help Message"}, 1, function(selected_mode)
            NotifMode = selected_mode
        end)

        ToggleNotify = true
        SettingsParts:toggle("Toggle Notify", {}, "", function(on)
            InterWait()
            ToggleNotify = on
        end, true)

        SettingsParts:toggle_loop("Disable Transaction Errors", {"interdte"}, "Remove all Transactions Errors during while using MB/Business.", function()
            if not util.is_session_started() then return end

            if GET_INT_GLOBAL(4536679) == 4 or 20 then
                SET_INT_GLOBAL(4536673, 0)
            end
        end)

        SettingsParts:toggle_loop("Auto Accept Game Warnings", {}, "", function()
            if HUD.IS_WARNING_MESSAGE_ACTIVE() then
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1)
                InterWait(200)
            end
        end)

        SettingsParts:divider("Credits & Others")
        local Credits = SettingsParts:list("Credits")

        Credits:divider("Credits")
        Credits:hyperlink("Stealthy.", "https://github.com/StealthyAD", "Main Dev creator "..SCRIPT_NAME.."\nCall me StealthyAD if you want.")
        Credits:divider("Some Lua Scripts taken")
        Credits:action("akatozi", {}, "I took his parts lua scripts to work like notify/verify session from mehScript", function()end)
        Credits:action("Code", {}, "I took his parts lua scripts for spawning vehicles", function()end)
        Credits:divider("And you are currently using the lua script")
        Credits:action(SOCIALCLUB.SC_ACCOUNT_INFO_GET_NICKNAME(), {}, "", function()end)

        local MenuSettings = SettingsParts:list("Menu Settings")
        local MoneySettings = SettingsParts:list("Money Features")
        local InGameSettings = SettingsParts:list("Other Features")
        local AdvancedSettings = SettingsParts:list("Advanced")

        SettingsParts:divider("GitHub / Updates")
        SettingsParts:hyperlink("Github Page", "https://github.com/StealthyAD/InterTools")
        SettingsParts:action("Check for Updates", {}, "The script will automatically check for updates at most daily, but you can manually check using this option anytime.", function()
        auto_update_config.check_interval = 0
            if auto_updater.run_auto_update(auto_update_config) then
                InterNotify("No updates found.")
            end
        end)
    
        SettingsParts:action("Clean Reinstall", {}, "Force an update to the latest version, regardless of current version.", function()
            auto_update_config.clean_reinstall = true
            auto_updater.run_auto_update(auto_update_config)
        end)

    ----========================================----
    ---             Menu Settings
    ---         Settings for Lua Script
    ----========================================----

        MenuSettings:toggle("Toggle Transition Template while starting", {}, "Toggle (Enable/Disable) image while starting Lua Script InterTools.", function(templateBool)
            local fp = io.open(script_resources .. '/Template/ToggleTemplate.txt', 'w')
            fp:write(not templateBool and 'True' or 'False')
            fp:close()
        end, io.open(script_resources .. '/Template/ToggleTemplate.txt', 'r'):read('*all') == 'True')

        MenuSettings:toggle("Toggle Transition Musics while starting", {}, "Toggle (Enable/Disable) Songs while starting Lua Script InterTools.", function(boolVerify)
            local fp = io.open(script_resources .. '/Songs/SongToggle.txt', 'w')
            fp:write(not boolVerify and 'True' or 'False')
            fp:close()
        end, io.open(script_resources .. '/Songs/SongToggle.txt', 'r'):read('*all') == 'True')

        MenuSettings:toggle("Toggle Message while starting", {}, "Toggle (Enable/Disable) message while starting Lua Script InterTools.", function(msgVerify)
            local fp = io.open(script_resources .. '/toggleMsg.txt', 'w')
            fp:write(not msgVerify and 'True' or 'False')
            fp:close()
        end, io.open(script_resources .. '/toggleMsg.txt', 'r'):read('*all') == 'True')

        --==========================================================================================--
        
        local fp = io.open(script_resources .. '/Template/DisplayDuration.txt', 'r')
        local DisplayDurationTime = tonumber(fp:read('*all')) or 0
        fp:close()

        local fp = io.open(script_resources .. '/Songs/songName.txt', 'r')
        local SongName = tonumber(fp:read('*all')) or 0
        fp:close()

        MenuSettings:action("Change Duration Time", {"intdurationtrans"}, "Change duration time template transition, in seconds, 1 second means the transition is very faster and disappear, choose your own way.", function(inputValue)
            menu.show_command_box_click_based(inputValue, "intdurationtrans ")
        end, function(arg)
            DisplayDurationTime = tonumber(arg) or DisplayDurationTime
            local fp = io.open(script_resources .. '/Template/DisplayDuration.txt', 'w')
            fp:write(DisplayDurationTime)
            fp:close()

            InterNotify("The settings have been applied correctly. Make sure you need to restart the Lua Script.\n\nDuration time: "..arg.." seconds")
        end)

        MenuSettings:action("Rename Music Name", {"intercmn"}, "Change music name of your choice.\nRemember: No music name in your folder, no songs during restart, okay?\nWrite only name, don't add extension like .mp3/wav.", function(inputName)
            menu.show_command_box_click_based(inputName, "intercmn ")
        end, function(arg)
            SongName = arg
            local fp = io.open(script_resources .. '/Songs/songName.txt', 'w')
            fp:write(SongName..".wav")
            fp:close()
            InterNotify("The settings have been applied correctly. Make sure you need to restart the Lua Script.\n\nName Music: "..SongName..".wav")
        end)

        --==========================================================================================--

        MenuSettings:action("Open Folder", {}, "Edit the folder in your own way\nRemember: Don't delete folders.", function()
            local script_resources_inter = filesystem.resources_dir() .. "Inter"
            util.open_folder(script_resources_inter)
        end)   

    ----========================================----
    ---              Other Parts
    ---             Game Settings
    ----========================================----

        InGameSettings:toggle_loop("Toggle Radar/HUD", {}, "", function()
            HUD.DISPLAY_RADAR(false)
            HUD.DISPLAY_HUD(false)
        end, function()
            HUD.DISPLAY_RADAR(true)
            HUD.DISPLAY_HUD(true)
        end)
        
        InGameSettings:toggle("Block Phone Calls", {""}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end)

        InGameSettings:toggle_loop("Auto Skip Conversation", {}, "Automatically skip all conversations.",function()
            if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
                AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
            end
            InterWait()
        end)

        InGameSettings:toggle_loop("Auto Skip Cutscene", {}, "Automatically skip all cutscenes.",function()
            CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
            InterWait(100)
        end)

        InGameSettings:slider("Minimap Zoom", {"interminimap"}, "", 0, 100, 0, 1, function(value)
            HUD.SET_RADAR_ZOOM_PRECISE(value)
        end)

        InGameSettings:action_slider("Change Visual Water", {}, "", {"Default", "Cayo Perico"}, function(waterSelect)
            if waterSelect == 1 then
                STREAMING.LOAD_GLOBAL_WATER_FILE(0)
            else
                STREAMING.LOAD_GLOBAL_WATER_FILE(1)
            end
        end)

        InGameSettings:divider("Game Exit")


        --====================================================================================================--

        local screens = {
            "You have been banned from Grand Theft Auto Online permanently.", -- Permanent Ban
            "You're attempting to access GTA Online servers with an altered version of the game.", -- Altered Version
            "There has been an error with this session.", -- Error Session
            "You have been suspended from Grand Theft Auto Online Online until ".. os.date("%m/%d/%Y", os.time() + 2700000) ..". \nIn addition, your Grand Theft Auto Online characters(s) will be reset.", -- Suspended
            "Failed to join due to incompatible assets." -- Incompatible Assets
        }

        InGameSettings:action_slider("Alert Message", {}, "", {
            "Banned", 
            "Altered Version", 
            "Error Session", 
            "Suspended", 
            "Incompatible assets",
            "Custom"
        }, function(select)
            if select == 6 then -- Si l'option "Custom" est sélectionnée
                local text = display_onscreen_keyboard()
                if text == "" or text == nil then
                    return
                else
                    show_custom_rockstar_alert(text)
                end
            else
                show_custom_rockstar_alert(screens[select].."\nReturn to Grand Theft Auto V.")
            end
        end)

    ----========================================----
    ---           Advanced Settings
    ---             Game Settings
    ----========================================----

        AdvancedSettings:action("Restart Script", {}, "Any problems for using the lua script, restart quickly.", function() util.restart_script() end)
        WarningExit = AdvancedSettings:action("Leave Game", {}, "", function(click_type)
            menu.show_warning(WarningExit, click_type, "DISCLAIMER: are you sure to leave the game?", function()
                os.exit()
            end)
        end)

        WarningExit2 = AdvancedSettings:action("Restart Game", {}, "", function(click_type)
            menu.show_warning(WarningExit2, click_type, "DISCLAIMER: are you sure to leave the game?\nRestart the game will you need to re-inject Stand", function()
                MISC.RESTART_GAME()
            end)
        end)

    ----========================================----
    ---            Money Features Parts
    ---         The part of money F parts
    ----========================================----

        MoneySettings:toggle_loop("Display Money", {}, "", function()
            HUD.SET_MULTIPLAYER_WALLET_CASH()
            HUD.SET_MULTIPLAYER_BANK_CASH()
        end,function()
            HUD.REMOVE_MULTIPLAYER_WALLET_CASH()
            HUD.REMOVE_MULTIPLAYER_BANK_CASH()
        end)

        local money_delay = 1
        MoneySettings:slider("Delay Money", {"intdelay"}, "Money delay", 1, 10000, 1, 1, function(s)
            money_delay = s
        end)

        local money_amt = 30000000
        MoneySettings:slider("Money Amount", {"intamoney"}, "Money amount between -2.1 billion and "..int_max, int_min, int_max, 30000000, 1, function(s)
            money_amt = s
        end)

        local money_random = false
        MoneySettings:toggle("Random Money", {}, "Randomize money amount", function(on)
            money_random = on
        end)

        MoneySettings:toggle_loop("Toggle Wallet Cash", {}, "", function(on)
            local amt
            if money_random then
                amt = math.random(100000000, int_max)
            else
                amt = money_amt
            end
            HUD.CHANGE_FAKE_MP_CASH(amt, 0)
            InterWait(money_delay)
        end)

        MoneySettings:toggle_loop("Toggle Bank Cash", {}, "", function(on)
            local amt
            if money_random then
                amt = math.random(100000000, int_max)
            else
                amt = money_amt
            end
            HUD.CHANGE_FAKE_MP_CASH(0, amt)
            InterWait(money_delay)
        end)

    ----========================================----
    ---              Player Parts
    ---    The part of the most important part
    ----========================================----

        players.on_join(function(pid)
            local PlayerMenu = menu.player_root(pid)
            local InterName = players.get_name(pid)
            PlayerMenu:divider(InterMenu)

            local function harass_specific_vehicle(hash, airVehicle, groundVehicle)
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
            end

        ----========================================----
        ---              Player Roots
        ---    The part of specific player root
        ----========================================----

            PlayerMenu:action("Disclaimer", {}, "", function()
                InterNotify("Welcome to InterTools v"..SCRIPT_VERSION..", you are welcome and you know the principe, you are allowed to do anything in your laws. \n\nBe proud to be an american and destroy entire session. Take care about your own resposibility.")
            end)
            local InterTools = PlayerMenu:list("Inter Tools")
            local FriendlyOptions = InterTools:list("Friendly")
            local NeutralOptions = InterTools:list("Neutral")
            local TrollingOptions = InterTools:list("Trolling")

            InterSpec = {}
            toggleSpec = InterTools:toggle("Spectate", {"interspec"}, "", function(on)
                if on then
                    if pid == players.user() then
                        InterNotify("You cannot spectate yourself.")
                        menu.set_value(toggleSpec, false)
                    end
                    if #InterSpec ~= 0 then
                        InterCmds("interspec"..InterSpec[1].." off")
                    end
                    table.insert(InterSpec, InterName)
                    if InterName == players.get_name(players.user()) then
                        return
                    else
                        InterNotify("You are currently spectating "..InterName)
                    end
                    InterCmds("spectate"..InterName.." on")
                else
                    if players.exists(pid) then
                        if InterName == players.get_name(players.user()) then
                            return
                        else
                            InterNotify("You are stopping spectating "..InterName)
                        end
                        InterCmds("spectate"..InterName.." off")
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

            InterTools:action_slider("Crash Tools", {}, "Different types of Crash Users:\n- AIO (All-in-One) - Faster Crash\n- Fragment\n- 5G Crash\n- Task Crash (AIO) - slower\n- Invalid Model", {
                "AIO (All-in-One)", 
                "Fragment",
                "5G Crash",
                "Task Crash (AIO)",
                "Invalid Model"
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
                elseif crashType == 4 then
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
                else
                    local mdl = util.joaat('a_c_poodle')
                    BlockSyncs(pid, function()
                        if RequestModel(mdl, 2) then
                            local pos = players.get_position(pid)
                            util.yield(100)
                            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                            ped1 = entities.create_ped(26, mdl, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(csPID), 0, 3, 0), 0) 
                            local coords = ENTITY.GET_ENTITY_COORDS(ped1, true)
                            WEAPON.GIVE_WEAPON_TO_PED(ped1, util.joaat('WEAPON_HOMINGLAUNCHER'), 9999, true, true)
                            local obj
                            repeat
                                obj = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped1, 0)
                            until obj ~= 0 or util.yield()
                            ENTITY.DETACH_ENTITY(obj, true, true)
                            util.yield(1500)
                            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 0, 1.0, false, true, 0.0, false)
                            entities.delete_by_handle(ped1)
                            util.yield(1000)
                        else
                            InterNotify("Failed to load model. :/")
                        end
                    end)
                end
            end)

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
                    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(playerVehicle)
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

            VehicleFriendly:action("Change Plate Name", {}, "Apply Plate Name if the player is in a vehicle.", function()
                local name = display_onscreen_keyboard()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if name ~= "" then
                        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(playerVehicle, name)
                    else
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

            local ChatPartsN = NeutralOptions:list("Chat Parts")

            ChatPartsN:action("Chat as "..InterName, {""}, "pretend the person who wrote this message.", function ()
                local txt = display_onscreen_keyboard()
                local playersList = players.list(true, true, true, true, true)
                if not txt or string.len(txt) == 0 then return end
                local from = pid
                for k, v in pairs(playersList) do
                    chat.send_targeted_message(v, from, txt, false)
                end
            end)


            local SpamChatN = ChatPartsN:list("Spam Chat")
            local PresetChatN = ChatPartsN  :list("Spoof Preset Chats")
            local presetMessages = {
                ["Austrian Painter"] = {text = "His name is Adolf Hitler. He's the greatest leader of the world during the era. Remember, he was an exceptional painter, he changed the world forever and changed world maps forever too."},
                ["Propaganda Putin"] = {text = "I only fucked Ukraine, dick Ukrainians. I hope all those Ukronazis should die. I don't care if all those ukrainians are going to die, in my own way I didn't started the Invasion but Ukrainians started."},
                ["Slava Ukraini"] = {text = "Слава Україні"},
                ["Fuck Russia"] = {text = "I fuck the Russian government and terrorist who attack the poor Ukrainians. К черту российское правительство и террористические банды, которые нападают на бедных украинцев"},
            }

            local preset_orderN = {}
            for name, preset in pairs(presetMessages) do
                table.insert(preset_orderN, {name, preset})
            end
            table.sort(preset_orderN, function(a, b) return a[1] < b[1] end)

            for _, preset in ipairs(preset_orderN) do
                local name = preset[1]
                local details = preset[2]
                PresetChatN:action(name, {}, "", function()
                    local from = pid
                    for k,v in pairs(players.list(true, true, true)) do
                        chat.send_targeted_message(v, from, details.text, false)
                    end
                end)
            end

            PresetChatN:divider("Loop Spam Chat")

            local delaySpamChat = 1
            PresetChatN:text_input("Modify Delay", {"interdelayppchat"}, "Delay mesured in seconds.", function(valueInput)
                if valueInput ~= "" then
                    delaySpamChat = tonumber(valueInput)
                else
                    delaySpamChat = 1
                end
            end, delaySpamChat)

            for _, preset in ipairs(preset_orderN) do
                local name = preset[1]
                local details = preset[2]
                PresetChatN:toggle_loop(name, {}, "", function()
                    local from = pid
                    for k,v in pairs(players.list(true, true, true)) do
                        chat.send_targeted_message(v, from, details.text, false)
                        InterWait(delaySpamChat * 1000)
                    end
                end)
            end

            --=========================================================================--

            local message = "pog"
            SpamChatN:text_input("Send Message", {"intermsgspam"}, "send to the chat", function(textInput)
                if textInput ~= "" then
                    message = textInput
                else
                    message = "pog"
                end
            end, message)

            local delaySpam = 1
            SpamChatN:text_input("Modify Delay", {"interdelayspamchat"}, "Delay mesured in seconds.", function(valueInput)
                if valueInput ~= "" then
                    delaySpam = tonumber(valueInput)
                else
                    delaySpam = 1
                end
            end, delaySpam)

            SpamChatN:toggle_loop("Chat as "..InterName, {""}, "pretend the person who wrote this message.", function ()
                local playersList = players.list(true, true, true, true, true)
                local from = pid
                for k, v in pairs(playersList) do
                    chat.send_targeted_message(v, from, message, false)
                end
                InterWait(delaySpam * 1000)
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
            local VehicleTrolling = TrollingOptions:list("Vehicle Settings")

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
                harass_specific_vehicle(planesHashP, true, false)
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
                harass_specific_vehicle(tankHashesP, false, true)
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
        ---      Troll Options (Vehicle Settings)
        ---     The part of specific player troll 
        ----========================================----

            DisableLock = VehicleTrolling:toggle_loop("Lock Vehicle", {}, "", function()
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

            local vehicleSpeed = 50.0
            VehicleTrolling:text_input("Modify Speed", {"intervehspeed"}, "", function(valueInput)
                if valueInput ~= "" then
                    vehicleSpeed = tonumber(valueInput)
                else
                    vehicleSpeed = 50.0
                end
            end)

            DisableUNCTRL = VehicleTrolling:toggle_loop("Uncontrollable Vehicle", {}, "Boost faster to deform vehicle without any manner to control.", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(playerVehicle, vehicleSpeed)
                else
                    menu.set_value(DisableUNCTRL, false)
                end
            end, function()
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(vehicle, 0)
            end)

            DisableEngine = VehicleTrolling:toggle_loop("Cut Engine", {}, "", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    VEHICLE.SET_VEHICLE_ENGINE_ON(playerVehicle, false, true, true)
                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(playerVehicle, -4000)
                    VEHICLE.SET_VEHICLE_BODY_HEALTH(playerVehicle, -4000)
                    VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(playerVehicle, -4000)
                    VEHICLE.SET_VEHICLE_UNDRIVEABLE(playerVehicle, true)
                else
                    menu.set_value(DisableEngine, false)
                end
            end, function()
                local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true)
                VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
                VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle, 1000)
                VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle, 1000)
                VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(vehicle, 1000)
                VEHICLE.SET_VEHICLE_UNDRIVEABLE(vehicle, false)
            end)

            VehicleTrolling:action_slider("Vehicle Remove", {}, "Choose any solution by any means how to remove.\n- Explode (not easy while removing god and explode)\n- Remove (Better)", {"Explode", "Remove"}, function(elimSelect)
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

            DisableMoon = VehicleTrolling:toggle_loop("Send to the Moon", {}, "send him to the sky, cya.", function()
                if menu.get_value(DisableGround) then
                    menu.set_value(DisableGround, false)
                end
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                    ENTITY.APPLY_FORCE_TO_ENTITY(playerVehicle, 1, 0, 0, 400.0, 0, 0, 0.5, 0, false, false, true)
                else
                    menu.set_value(DisableMoon, false)
                end
            end, function()
                menu.set_value(DisableGround, false)
            end)

            DisableGround = VehicleTrolling:toggle_loop("Gravity on the ground", {}, 'in the ground right now.', function()
                if menu.get_value(DisableMoon) then
                    menu.set_value(DisableMoon, false)
                end
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if ENTITY.IS_ENTITY_IN_AIR(playerVehicle) then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                        ENTITY.APPLY_FORCE_TO_ENTITY(playerVehicle, 1, 0, 0, -400.0, 0, 0, 0.5, 0, false, false, true)
                    end
                else
                    menu.set_value(DisableGround, false)
                end
            end, function()
                menu.set_value(DisableMoon, false)
            end)

            VehicleTrolling:divider("Advanced (Aircraft/Helicopters)")

            DisableGear = VehicleTrolling:toggle_loop("Toggle Landing Gear", {}, "reduces speed of jets or helicopter", function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if PED.IS_PED_IN_ANY_PLANE(player) or PED.IS_PED_IN_ANY_HELI(player) then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                        VEHICLE.CONTROL_LANDING_GEAR(playerVehicle, 0)
                    else
                        menu.set_value(DisableGear, false)
                    end
                else
                    menu.set_value(DisableGear, false)
                end
            end, function()
                VEHICLE.CONTROL_LANDING_GEAR(PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), true), 3)
            end)

            THeliBlades = VehicleTrolling:toggle_loop("Toggle Propeller", {}, "Enable: Propeller Helicopter\nDisable: Reverted to back",function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if PED.IS_PED_IN_ANY_HELI(player) then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                        VEHICLE.SET_HELI_BLADES_SPEED(playerVehicle, 0.0)
                    else
                        menu.set_value(THeliBlades, false)
                    end
                else
                    menu.set_value(THeliBlades, false)
                end
            end)

            ToggleRotor = VehicleTrolling:toggle_loop("Cut Rotor Helicopter", {}, "",function()
                local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
                if PED.IS_PED_IN_VEHICLE(player, playerVehicle, false) then
                    if PED.IS_PED_IN_ANY_HELI(player) then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
                        VEHICLE.SET_HELI_TAIL_ROTOR_HEALTH(playerVehicle, -100)
                        VEHICLE.SET_HELI_MAIN_ROTOR_HEALTH(playerVehicle, -100)
                    else
                        menu.set_value(ToggleRotor, false)
                    end
                else
                    menu.set_value(ToggleRotor, false)
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

            TrollingOptions:action_slider("Elimination Type", {}, "Different types of elimination:\n- Airstrike\n- Orbital Shot (Non-Personal)\n- Orbital Shot (Revealed)\n- Silent Shot\n- Passive Shot\n- Atomize Shot", {"Airstrike", "Orbital Shot (Non-Personal)", "Orbital Shot (Revealed)", "Silent Shot", "Passive Shot", "Atomize Shot"}, function(killselect)
                if killselect == 1 then
                    local pidPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                    local abovePed = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(pidPed, 0, 0, 8)
                    local missileCount = rand(16, 24)
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
                elseif killselect == 5 then
                    KillPassive(pid)
                else
                    for i = 1, 30 do
                        local pos = players.get_position(pid)
                        FIRE.ADD_EXPLOSION(pos.x + math.random(-2, 2), pos.y + math.random(-2, 2), pos.z + math.random(-2, 2), 70, 1, true, false, 0.2, false)
                        util.yield(math.random(0, 1))
                    end
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

    ----========================================----
    ---            End Part of Script
    ---       The part of useful lua script
    ----========================================----

    if SCRIPT_MANUAL_START and not SCRIPT_SILENT_START then

        local Template = script_resources .. '/Template'

        --[[
            DO NOT EDIT THESE PARTS. REMOVING 'SongToggle.txt' will let able to get constant music.
        ]]--

        local boolSong = script_resources .. '/Songs/SongToggle.txt'
        local boolTransition = script_resources .. '/Template/ToggleTemplate.txt'
        local songFileName = script_resources .. '/Songs/songName.txt'

        local msgVerify = script_resources .. '/toggleMsg.txt'

        -- Check if the file exists and read its content (True or False)
        local fp = io.open(msgVerify, 'r')
        local boolMsgVerify = fp and (fp:read('*all') == 'True')
        fp:close()
        
        -- Check if the file exists and read its content (True or False)
        local fp = io.open(boolSong, 'r')
        local boolVerify = fp and (fp:read('*all') == 'True')
        fp:close()

        -- Check if the file exists and read its content (True or False) -- Bool Music Starting
        local fp = io.open(boolTransition, 'r')
        local boolVerifyTR = fp and (fp:read('*all') == 'True')
        fp:close()
        
        -- Check if the file exists and read its content (True or False) -- SongFileName
        local fp = io.open(songFileName, 'r')
        local file_selection = fp:read('*a')
        fp:close()
        
        local sound_location = script_resources .. '\\Songs\\' .. file_selection
        
        if boolVerify ~= false then -- check if boolVerify is not explicitly false
            if filesystem.exists(sound_location) then
                PlaySong(sound_location, SND_FILENAME | SND_ASYNC)
            end
        end

        if boolMsgVerify ~= false then -- check if msgVerify is not explicitly false
            InterNotify("Welcome "..SOCIALCLUB.SC_ACCOUNT_INFO_GET_NICKNAME().." to InterTools.\nCompatible with Stand v"..STAND_VERSION..".")
        end

        --[[
            DO NOT EDIT THESE PARTS. REMOVING 'DisplayDuration.txt' will not able to get transition smoother.
        ]]--

        timer = Template .. '/DisplayDuration.txt'
        fp = io.open(timer, 'r')
        fp:close()
        
        local DisplayDuration = tonumber(io.open(Template .. '/DisplayDuration.txt'):read('*all'))
        local InterLogo = directx.create_texture(Template .. "/Inter.png")
        local alpha = 0
        local alpha_incr = 0.005
        
        if boolVerifyTR ~= false then
            logo_alpha_thread = util.create_thread(function()
                while true do
                    alpha = alpha + alpha_incr
                    if alpha > 1 then
                        alpha = 1
                    elseif alpha < 0 then 
                        alpha = 0
                        util.stop_thread()
                    end
                    util.yield()
                end
            end)
            
            logo_thread = util.create_thread(function()
                local start_time = os.clock()
                while true do
                    directx.draw_texture(InterLogo, 0.08, 0.08, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, alpha)
                    local time_passed = os.clock() - start_time
                    if time_passed > DisplayDuration then
                        alpha_incr = -0.01
                    end
                    if alpha == 0 then
                        util.stop_thread()
                    end
                    util.yield()
                end
            end)
        end
    end

    -- check online version
    online_v = tostring(NETWORK.GET_ONLINE_VERSION())
    if online_v > GTAO_VERSION then
        InterNotify("Your version of GTA Online "..online_v .. " is deprecated.\nThe Lua Scripts supports only for " .. GTAO_VERSION .." but can barely operate and might work a little.")
    end

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
