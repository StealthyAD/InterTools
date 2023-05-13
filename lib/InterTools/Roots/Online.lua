--[[

    ██╗███╗   ██╗████████╗███████╗██████╗ ████████╗ ██████╗  ██████╗ ██╗     ███████╗
    ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
    ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝   ██║   ██║   ██║██║   ██║██║     ███████╗
    ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗   ██║   ██║   ██║██║   ██║██║     ╚════██║
    ██║██║ ╚████║   ██║   ███████╗██║  ██║   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
    ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝
                                                                                    
    Features:
    - Compatible All Stand Versions if deprecated versions too.
    - Largest Lua Script ain't even written.
    - Bigger and complete script.

    Help with Lua?
    - GTAV Natives: https://nativedb.dotindustries.dev/natives/
    - FiveM Docs Natives: https://docs.fivem.net/natives/
    - Stand Lua Documentation: https://stand.gg/help/lua-api-documentation
    - Lua Documentation: https://www.lua.org/docs.html

    Part: Online
]]--

        local int_max = 2147483647

    ----========================================----
    ---              Exclude Functions
    ---     The part of functions, exclusions
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

    ----========================================----
    ---              Online Roots
    ---         The part of online parts
    ----========================================----

        local OnlineParts = InterRoot:list("Online Settings", {"intonline"})
        local ExcludeRoot = OnlineParts:list("Exclude Parts", {}, "Exclude every features.\nIncludes: \n- Session Parts")
        local ChatParts = OnlineParts:list("Chat Parts")
        local DetectionRoots = OnlineParts:list("Detection Parts")
        local LanguageRoots = OnlineParts:list("Language Parts")
        local SessionRoots = OnlineParts:list("Session Parts")

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
                    InterWait(50)
                end
            else
                InterNotify("Please enter a message to send.\nPlease try later")
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

        local AerialRoots = SessionRoots:list("Aerial Defense")
        local BountyRoot = SessionRoots:list("Bounty Parts")
        local ExplodeRoot = SessionRoots:list("Explode Parts")
        local HostRoots = SessionRoots:list("Host Parts")
        local SoundRoots = SessionRoots:list("Sound Parts")
        local TeleportsRoots = SessionRoots:list("Teleport Parts")
        local VehicleRootsO = SessionRoots:list("Vehicle Parts")
        local VehicleDetections = SessionRoots:list("Vehicle Detection Parts")

    ----========================================----
    ---               Aerial Roots
    ---         The part of session online
    ---             Defending the skies
    ----========================================----

        AerialRoots:divider("Aerial Defense (US Air Force)")
        PlaneToggleGod = AerialRoots:toggle_loop("Toggle Godmode Air Force", {}, "Toggle (Enable/Disable) Godmode Planes while using \"Send Air Force\".",  function()end)
        
        local planeModels = {
            ["Lazer"] = util.joaat("lazer"),
            ["Hydra"] = util.joaat("hydra"),
            ["V-65 Molotok"] = util.joaat("molotok"),
            ["Western Rogue"] = util.joaat("rogue"),
            ["Pyro"] = util.joaat("pyro"),
            ["P-45 Nokota"] = util.joaat("nokota"),
        }
        
        local planeModelNames = {}
        for name, _ in pairs(planeModels) do
            table.insert(planeModelNames, name)
        end

        table.sort(planeModelNames, function(a, b) return a[1] < b[1] end)
        
        local selectedPlaneModel = "Hydra"
        local planesHash = planeModels[selectedPlaneModel]
        
        AerialRoots:list_select("Types of Planes", {"interplanes"}, "The entities that will add while sending air force planes.", planeModelNames, 1, function(index)
            selectedPlaneModel = planeModelNames[index]
            planesHash = planeModels[selectedPlaneModel]
        end)
        
        AerialRoots:action("Send Air Force", {"interusaf"}, "Sending America to war and intervene more planes.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features.", function()
            local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            for _, pid in pairs(playerList) do
                if AvailableSession() then
                    for i = 1, menu.get_value(PlaneCount) do
                        harass_vehicle(pid, planesHash, true, false)
                        InterWait(menu.get_value(delayAirForce) * 1000)
                    end
                end
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

    ----========================================----
    ---           Aerial Roots (Choppers)
    ---         The part of session online
    ---           Defending the skies
    ----========================================----

        AerialRoots:divider("Aerial Defense - Choppers (US Air Force)")
        HelisToggleGod = AerialRoots:toggle_loop("Toggle Godmode Air Force (Helis)", {}, "Toggle (Enable/Disable) Godmode helicopters while using \"Send Air Force (Helicopters)\".",  function()end)

        local helisModels = {
            ["Annihilator"] = util.joaat("annihilator"),
            ["Cargobob"] = util.joaat("cargobob"),
            ["Annihilator Stealth"] = util.joaat("annihilator2"),
            ["Buzzard Attack Chopper"] = util.joaat("buzzard"),
            ["Savage"] = util.joaat("savage"),
            ["Valkyrie"] = util.joaat("valkyrie"),
            ["FH-1 Hunter"] = util.joaat("hunter"),
            ["RF-1 Akula"] = util.joaat("akula"),
        }
        
        local heliModelName = {}
        for name, _ in pairs(helisModels) do
            table.insert(heliModelName, name)
        end

        table.sort(heliModelName, function(a, b) return a[1] < b[1] end)
        
        local selectedHeliNameModel = "Annihilator"
        local heliHash = helisModels[selectedHeliNameModel]
        
        AerialRoots:list_select("Types of Choppers", {"interhelis"}, "The entities that will add while sending air force helicopters.", heliModelName, 1, function(index)
            selectedHeliNameModel = heliModelName[index]
            heliHash = helisModels[selectedHeliNameModel]
        end)
        
        AerialRoots:action("Send Air Force (Helicopters)", {"interusafh"}, "Sending America to war and intervene more helicopters.\nWARNING: The action is irreversible in the session if toggle godmode on.\nNOTE: Toggle Exclude features", function()
            local playerList = players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)
            for _, pid in pairs(playerList) do
                if AvailableSession() then
                    for i = 1, menu.get_value(HelisCount) do
                        harass_vehicle(pid, heliHash, false, true)
                        InterWait(menu.get_value(delayAirForce) * 1000)
                    end
                end
            end
        end, nil, nil, COMMANDPERM_AGGRESSIVE)

        AerialRoots:divider("Advanced")

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
        }

        local modelToDelete = {
            util.joaat("s_m_y_marine_01"),
            util.joaat("s_m_y_marine_03"),
            util.joaat("s_m_y_pilot_01")
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

        delayAirForce = AerialRoots:slider("Delay Time", {"interdelayaf"}, "Recommended to not spam if you are in public session to avoid saturation of vehicle.\nRecommended: 3 seconds.\nApplies also for helicopters & Planes", 2, int_max, 3, 1, function()end)
        HelisCount = AerialRoots:slider("Number of Generation of Choppers", {"interafheli"}, "For purposes: limit atleast 5 helicopters if you are in Public session with 30 players.\nMore NPCs in a chopper = reducing spawning generation for choppers. 1 only need.", 1, 10, 1, 1, function()end)
        PlaneCount = AerialRoots:slider("Number of Generation of Planes", {"interaf"}, "For purposes: limit atleast 5 planes if you are in Public session with 30 players.".."\n\nFor recommendation:".."\n".."- for Hydra: 1 or 2 planes per session while using to avoid instance.\n- Lazer: 3 or 5 more.", 1, 10, 1, 1, function()end)

    ----========================================----
    ---              Bounty Roots
    ---         The part of bounty online
    ----========================================----

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

        BountyRoot:action("Manual Bounty Player (Input)", {'intermanualbounty'}, "Alright, let's start a new war for everyone, you will be happy to see that.\nNOTE: Toggle Exclude features.",function()
            local inputValue = display_onscreen_keyboard()
            for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
                if AvailableSession() and players.get_bounty(pid) ~= inputValue and players.get_name(pid) ~= "UndiscoveredPlayer" then
                    InterCmds("bounty"..players.get_name(pid).." "..inputValue)
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
    ---              Teleports Parts
    ---     The part of teleport online parts
    ----========================================----

        local appartType = 1
        TeleportsRoots:list_select("Apartment Type", {""}, "", property_id, 1, function(index)
            appartType = index
        end)

        TeleportWarning = TeleportsRoots:action("Teleport Apartment Location", {"interapt"}, "Teleport the entire session?\nAlternative to Stand Features but may not karma you.\n\nToggle 'Exclude Self' to avoid using these functions.",function(type)
            menu.show_warning(TeleportWarning, type, "Do you really want to teleport the entire session to the death?\nNOTE: Teleporting all players will cost a fight against players.", function()
                for _, pid in pairs(players.list(EToggleSelf, EToggleFriend, EToggleStrangers, EToggleCrew, EToggleOrg)) do
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
                local APTRandT = RandomGenerator(1, 114)
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
                            APTRandom = RandomGenerator(1, 114)
                        until not assignedApartments[APTRandom]
                        assignedApartments[APTRandom] = true
                        InterCmds("apt"..APTRandom..players.get_name(pid))
                    end
                end
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
            if textInput == nil then
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
                    local RandAPT = RandomGenerator(0, 114)
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

        SessionRoots:action_slider("Random Elimination", {}, "Different type of eliminations:\n- Explosive\n- Silent Mode\n- Gas Mode\n- Randomize\n- Gas Randomize\n- Silent Random", {"Explosive", "Silent Mode", "Gas Mode", "Randomize", "Gas Randomize", "Silent Random"}, function(randselect)
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
                            InterNotify(playerName.." can't be eliminated.")
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
                            InterNotify(playerName.." can't be eliminated.")
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
                            InterNotify(playerName.." can't be eliminated.")
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
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 34, 1, true, false, 0.0, false)
                            end
                        else
                            InterNotify(playerName.." can't be eliminated.")
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
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 48, 1, true, false, 0.0, false)
                            end
                            InterWait(100)
                            for i = 0, 10 do
                                FIRE.ADD_OWNED_EXPLOSION(RandomPed, pos.x, pos.y, pos.z, 48, 1, true, false, 0.0, false)
                            end
                        else
                            InterNotify(playerName.." can't be eliminated.")
                        end
                    end
                else
                    InterNotify("No players are currently in the session.")
                end
            else -- Silent Kill Random
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
                            InterNotify(playerName.." can't be eliminated.")
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
            if text == nil or text == "" then return end
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
