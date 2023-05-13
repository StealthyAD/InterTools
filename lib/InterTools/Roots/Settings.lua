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

    Part: Settings
]]--

        local int_min = -2147483647
        local int_max = 2147483647

    ---========================================----
    ---             Settings Roots
    ---        The part of world parts
    ----========================================----

        local SettingsParts = InterRoot:list("Settings Parts", {"intsettings"})

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

        SettingsParts:divider("Menu Settings")

         --==========================================================================================--

        SettingsParts:toggle("Toggle Transition Template while starting", {}, "Toggle (Enable/Disable) image while starting Lua Script InterTools.", function(templateBool)
            local fp = io.open(script_resources .. '/Template/ToggleTemplate.txt', 'w')
            fp:write(not templateBool and 'True' or 'False')
            fp:close()
        end, io.open(script_resources .. '/Template/ToggleTemplate.txt', 'r'):read('*all') == 'True')

        SettingsParts:toggle("Toggle Transition Musics while starting", {}, "Toggle (Enable/Disable) Songs while starting Lua Script InterTools.", function(boolVerify)
            local fp = io.open(script_resources .. '/Songs/SongToggle.txt', 'w')
            fp:write(not boolVerify and 'True' or 'False')
            fp:close()
        end, io.open(script_resources .. '/Songs/SongToggle.txt', 'r'):read('*all') == 'True')

        SettingsParts:toggle("Toggle Message while starting", {}, "Toggle (Enable/Disable) message while starting Lua Script InterTools.", function(msgVerify)
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

        SettingsParts:action("Change Duration Time", {"intdurationtrans"}, "Change duration time template transition, in seconds, 1 second means the transition is very faster and disappear, choose your own way.", function(inputValue)
            menu.show_command_box_click_based(inputValue, "intdurationtrans ")
        end, function(arg)
            DisplayDurationTime = tonumber(arg) or DisplayDurationTime
            local fp = io.open(script_resources .. '/Template/DisplayDuration.txt', 'w')
            fp:write(DisplayDurationTime)
            fp:close()

            InterNotify("The settings have been applied correctly. Make sure you need to restart the Lua Script.\n\nDuration time: "..arg.." seconds")
        end)

        SettingsParts:action("Rename Music Name", {"intercmn"}, "Change music name of your choice.\nRemember: No music name in your folder, no songs during restart, okay?\nWrite only name, don't add extension like .mp3/wav.", function(inputName)
            menu.show_command_box_click_based(inputName, "intercmn ")
        end, function(arg)
            SongName = arg
            local fp = io.open(script_resources .. '/Songs/songName.txt', 'w')
            fp:write(SongName..".wav")
            fp:close()
            InterNotify("The settings have been applied correctly. Make sure you need to restart the Lua Script.\n\nName Music: "..SongName..".wav")
        end)

        --==========================================================================================--

        SettingsParts:action("Open Folder", {}, "Edit the folder in your own way\nRemember: Don't delete folders.", function()
            local script_resources_inter = filesystem.resources_dir() .. "Inter"
            util.open_folder(script_resources_inter)
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

        local MoneySettings = SettingsParts:list("Money Features")
        SettingsParts:toggle("Block Phone Calls", {""}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end)

        SettingsParts:toggle_loop("Auto Skip Conversation", {}, "Automatically skip all conversations.",function()
            if AUDIO.IS_SCRIPTED_CONVERSATION_ONGOING() then
                AUDIO.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
            end
            InterWait()
        end)

        SettingsParts:toggle_loop("Auto Skip Cutscene", {}, "Automatically skip all cutscenes.",function()
            CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
            InterWait(100)
        end)

        local screens = {
            "You have been banned from Grand Theft Auto Online permanently.", -- Permanent Ban
            "You're attempting to access GTA Online servers with an altered version of the game.", -- Altered Version
            "There has been an error with this session.", -- Error Session
            "You have been suspended from Grand Theft Auto Online Online until ".. os.date("%m/%d/%Y", os.time() + 2700000) ..". \nIn addition, your Grand Theft Auto Online characters(s) will be reset.", -- Suspended
            "Failed to join due to incompatible assets." -- Incompatible Assets
        }

        SettingsParts:action_slider("Alert Message", {}, "", {
            "Banned", 
            "Altered Version", 
            "Error Session", 
            "Suspended", 
            "Incompatible assets"
        }, function(select)
            show_custom_rockstar_alert(screens[select].."\nReturn to Grand Theft Auto V.")
        end)

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
    ---            Money Features Parts
    ---         The part of money F parts
    ----========================================----

        MoneySettings:toggle("Display Money", {}, "", function(toggle)
            if toggle then
                HUD.SET_MULTIPLAYER_WALLET_CASH()
                HUD.SET_MULTIPLAYER_BANK_CASH()
            else
                HUD.REMOVE_MULTIPLAYER_WALLET_CASH()
                HUD.REMOVE_MULTIPLAYER_BANK_CASH()
            end
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

--[[

███████ ███    ██ ██████       ██████  ███████     ████████ ██   ██ ███████     ██████   █████  ██████  ████████ 
██      ████   ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██   ██ ██   ██ ██   ██    ██    
█████   ██ ██  ██ ██   ██     ██    ██ █████          ██    ███████ █████       ██████  ███████ ██████     ██    
██      ██  ██ ██ ██   ██     ██    ██ ██             ██    ██   ██ ██          ██      ██   ██ ██   ██    ██    
███████ ██   ████ ██████       ██████  ██             ██    ██   ██ ███████     ██      ██   ██ ██   ██    ██    
                                                                                                                                                                                                                               
]]--
