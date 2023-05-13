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

    Part: Music
]]--

        local SND_ASYNC<const> = 0x0001
        local SND_FILENAME<const> = 0x00020000
        
    ---========================================----
    ---              Music Roots
    ---        The part of musics roots
    ----========================================----

        local MusicParts = InterRoot:list("Music Parts", {"intmusics"})

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

        util.create_thread(function()
            while true do
                UpdateAutoMusics()
                CheckSongs()
                check_music_folder()
                menu.set_list_action_options(InterMuList, InterMusicFiles)
                InterWait(250)
            end
        end)
