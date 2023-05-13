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

    Part: Main
]]--

        util.keep_running()
        util.require_natives(1681379138)

        aalib = require("aalib")
        PlaySong = aalib.play_sound
        local SND_ASYNC<const> = 0x0001
        local SND_FILENAME<const> = 0x00020000

        STAND_VERSION = menu.get_version().version
        SCRIPT_VERSION = "1.70LN"
        InterMenu = "InterTools v"..SCRIPT_VERSION
        InterRoot = menu.my_root()
        local GTAO_VERSION = "1.66"
        local InterToast = util.toast
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
            "lib\\InterTools\\Roots\\Self.lua",
            "lib\\InterTools\\Roots\\Weapons.lua",
            "lib\\InterTools\\Roots\\Vehicles.lua",
            "lib\\InterTools\\Roots\\Online.lua",
            "lib\\InterTools\\Roots\\World.lua",
            "lib\\InterTools\\Roots\\Music.lua",
            "lib\\InterTools\\Roots\\Settings.lua",
            "lib\\InterTools\\Roots\\Players.lua",

            "lib\\InterTools\\Functions.lua"
        }
        for _, file in pairs(Required_Files) do
            local file_path = ScriptDir .. file
            if not filesystem.exists(file_path) then
                InterNotify("Missing documents: " .. file_path, TOAST_ALL)
                util.stop_script()
            end
        end

        require "InterTools.Functions"

    ----========================================----
    ---           Shortcuts for Stand
    ---        The part of linking files
    ----========================================----

        InterCmd = menu.trigger_command
        InterCmds = menu.trigger_commands
        InterWait = util.yield
        InterRefBP = menu.ref_by_path

    ----========================================----
    ---              Update Parts
    ---     The part of update. Auto or manual
    ----========================================----

        -- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
        status, auto_updater = pcall(require, "auto-updater")
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
        auto_update_config = {
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
                {
                    name="Self",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Self.lua",
                    script_relpath="lib/InterTools/Roots/Self.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Weapons",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Weapons.lua",
                    script_relpath="lib/InterTools/Roots/Weapons.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Vehicles",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Vehicles.lua",
                    script_relpath="lib/InterTools/Roots/Vehicles.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Online",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Online.lua",
                    script_relpath="lib/InterTools/Roots/Online.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="World",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/World.lua",
                    script_relpath="lib/InterTools/Roots/World.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Music",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Music.lua",
                    script_relpath="lib/InterTools/Roots/Music.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Settings",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Settings.lua",
                    script_relpath="lib/InterTools/Roots/Settings.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Players",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Roots/Players.lua",
                    script_relpath="lib/InterTools/Roots/Players.lua",
                    check_interval=default_check_interval,
                },
                {
                    name="Functions",
                    source_url="https://raw.githubusercontent.com/StealthyAD/InterTools/main/lib/InterTools/Functions.lua",
                    script_relpath="lib/InterTools/Functions.lua",
                    check_interval=default_check_interval,
                },
            }
        }

        auto_updater.run_auto_update(auto_update_config)

    ----========================================----
    ---              Root Parts
    ---     The part of root which redirects.
    ----========================================----

        InterRoot:divider(InterMenu)
        InterRoot:action("Player Parts", {}, "", function() menu.ref_by_path("Players"):trigger()end)
        local rootModules = {
            "Self",
            "Weapons",
            "Vehicles",
            "Online",
            "World",
            "Music",
            "Settings",
            "Players"
        }
        
        for _, moduleName in ipairs(rootModules) do
            require("InterTools.Roots." .. moduleName)
        end

    ----========================================----
    ---              Loop Parts
    ---         The part of function parts
    ----========================================----

        util.on_stop(function()
            PlaySong(join_path(script_resources, "stops.wav"), SND_FILENAME | SND_ASYNC)
        end)

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
