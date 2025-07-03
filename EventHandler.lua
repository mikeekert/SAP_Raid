local _, SAP = ... -- Internal namespace
local f = CreateFrame("Frame")
f:RegisterEvent("ENCOUNTER_START")
f:RegisterEvent("ENCOUNTER_END")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("GROUP_FORMED")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

f:SetScript("OnEvent", function(self, e, ...)
    SAP:EventHandler(e, true, false, ...)
end)

function SAP:EventHandler(e, wowevent, internal, ...) -- internal checks whether the event comes from addon comms. We don't want to allow blizzard events to be fired manually
    if e == "ADDON_LOADED" and wowevent then
        local name = ...
        if name == "SAP_Raid" then
            if not SAPRT then SAPRT = {} end
            if not SAPRT.SAPUI then SAPRT.SAPUI = {scale = 1} end
            if not SAPRT.SAPUI.externals_anchor then SAPRT.SAPUI.externals_anchor = {} end
            -- if not SAPRT.SAPUI.main_frame then SAPRT.SAPUI.main_frame = {} end
            -- if not SAPRT.SAPUI.external_frame then SAPRT.SAPUI.external_frame = {} end
            if not SAPRT.NickNames then SAPRT.NickNames = {} end
            if not SAPRT.Settings then SAPRT.Settings = {} end
            SAPRT.Settings["MyNickName"] = SAPRT.Settings["MyNickName"] or nil
            SAPRT.Settings["GlobalNickNames"] = SAPRT.Settings["GlobalNickNames"] or false
            SAPRT.Settings["Blizzard"] = SAPRT.Settings["Blizzard"] or false
            SAPRT.Settings["WA"] = SAPRT.Settings["WA"] or false
            SAPRT.Settings["MRT"] = SAPRT.Settings["MRT"] or false
            SAPRT.Settings["Cell"] = SAPRT.Settings["Cell"] or false
            SAPRT.Settings["Grid2"] = SAPRT.Settings["Grid2"] or false
            SAPRT.Settings["OmniCD"] = SAPRT.Settings["OmniCD"] or false
            SAPRT.Settings["ElvUI"] = SAPRT.Settings["ElvUI"] or false
            SAPRT.Settings["SuF"] = SAPRT.Settings["SuF"] or false
            SAPRT.Settings["Translit"] = SAPRT.Settings["Translit"] or false
            SAPRT.Settings["Unhalted"] = SAPRT.Settings["Unhalted"] or false
            SAPRT.Settings["ShareNickNames"] = SAPRT.Settings["ShareNickNames"] or 4 -- none default
            SAPRT.Settings["AcceptNickNames"] = SAPRT.Settings["AcceptNickNames"] or 4 -- none default
            SAPRT.Settings["NickNamesSyncAccept"] = SAPRT.Settings["NickNamesSyncAccept"] or 2 -- guild default
            SAPRT.Settings["NickNamesSyncSend"] = SAPRT.Settings["NickNamesSyncSend"] or 3 -- guild default
            SAPRT.Settings["WeakAurasImportAccept"] = SAPRT.Settings["WeakAurasImportAccept"] or 1 -- guild default
            SAPRT.Settings["PAExtraAction"] = SAPRT.Settings["PAExtraAction"] or false
            SAPRT.Settings["LIQUID_MACRO"] = SAPRT.Settings["LIQUID_MACRO"] or false
            SAPRT.Settings["PASelfPing"] = SAPRT.Settings["PASelfPing"] or false
            SAPRT.Settings["ExternalSelfPing"] = SAPRT.Settings["ExternalSelfPing"] or false
            SAPRT.Settings["MRTNoteComparison"] = SAPRT.Settings["MRTNoteComparison"] or false
            SAPRT.Settings["TTS"] = SAPRT.Settings["TTS"] or true
            SAPRT.Settings["TTSVolume"] = SAPRT.Settings["TTSVolume"] or 50
            SAPRT.Settings["TTSVoice"] = SAPRT.Settings["TTSVoice"] or 2
            SAPRT.Settings["Minimap"] = SAPRT.Settings["Minimap"] or {hide = false}
            SAPRT.Settings["VersionCheckRemoveResponse"] = SAPRT.Settings["VersionCheckRemoveResponse"] or false
            SAPRT.Settings["Debug"] = SAPRT.Settings["Debug"] or false
            SAPRT.Settings["DebugLogs"] = SAPRT.Settings["DebugLogs"] or false
            SAPRT.Settings["VersionCheckPresets"] = SAPRT.Settings["VersionCheckPresets"] or {}
            SAPRT.SAPUI.AutoComplete = SAPRT.SAPUI.AutoComplete or {}
            SAPRT.SAPUI.AutoComplete["WA"] = SAPRT.SAPUI.AutoComplete["WA"] or {}
            SAPRT.SAPUI.AutoComplete["Addon"] = SAPRT.SAPUI.AutoComplete["Addon"] or {}

            SAP.BlizzardNickNamesHook = false
            SAP.MRTNickNamesHook = false
            SAP.OmniCDNickNamesHook = false
            SAP:InitNickNames()
        end
    elseif e == "PLAYER_LOGIN" and wowevent then
        local pafound = false
        local extfound = false
        local innervatefound = false
        local macrocount = 0    
        for i=1, 120 do
            local macroname = C_Macro.GetMacroName(i)
            if not macroname then break end
            macrocount = i
            if macroname == "SAP PA Macro" then
                local macrotext = "/run SAP_API:PrivateAura();"
                if SAPRT.Settings["PASelfPing"] then
                    macrotext = macrotext.."\n/ping [@player] Warning;"
                end
                if SAPRT.Settings["PAExtraAction"] then
                    macrotext = macrotext.."\n/click ExtraActionButton1"
                end
                EditMacro(i, "SAP PA Macro", 132288, macrotext, false)
                pafound = true
            elseif macroname == "SAP Ext Macro" then
                local macrotext = SAPRT.Settings["ExternalSelfPing"] and "/run SAP_API:ExternalRequest();\n/ping [@player] Assist;" or "/run SAP_API:ExternalRequest();"
                EditMacro(i, "SAP Ext Macro", 135966, macrotext, false)
                extfound = true
            elseif macroname == "SAP Innervate" then
                EditMacro(i, "SAP Innervate", 136048, "/run SAP_API:InnervateRequest();", false)
                innervatefound = true
            end
            if pafound and extfound and innervatefound then break end
        end
        if macrocount >= 120 and not pafound then
            print("You reached the global Macro cap so the Private Aura Macro could not be created")
        elseif not pafound then
            macrocount = macrocount+1            
            local macrotext = "/run SAP_API:PrivateAura();"
            if SAPRT.Settings["PASelfPing"] then
                macrotext = macrotext.."\n/ping [@player] Warning;"
            end
            if SAPRT.Settings["PAExtraAction"] then
                macrotext = macrotext.."\n/click ExtraActionButton1"
            end
            if SAPRT.Settings["LIQUID_MACRO"] then
                macrotext = macrotext.."\n/run WeakAuras.ScanEvents(\"LIQUID_PRIVATE_AURA_MACRO\", true)"
            end
            CreateMacro("SAP PA Macro", 132288, macrotext, false)
        end
        if macrocount >= 120 and not extfound then 
            print("You reached the global Macro cap so the External Macro could not be created")
        elseif not extfound then
            macrocount = macrocount+1
            local macrotext = SAPRT.Settings["ExternalSelfPing"] and "/run SAP_API:ExternalRequest();\n/ping [@player] Assist;" or "/run SAP_API:ExternalRequest();"
            CreateMacro("SAP Ext Macro", 135966, macrotext, false)
        end
        if macrocount >= 120 and not inenrvatefound then
            print("You reached the global Macro cap so the Innervate Macro could not be created")
        elseif not innervatefound then
            macrocount = macrocount+1
            CreateMacro("SAP Innervate", 136048, "/run SAP_API:InnervateRequest();", false)
        end
        if SAPRT.Settings["MyNickName"] then SAP:SendNickName("Any") end -- only send nickname if it exists. If user has ever interacted with it it will create an empty string instead which will serve as deleting the nickname
        if SAPRT.Settings["GlobalNickNames"] then -- add own nickname if not already in database (for new characters)
            local name, realm = UnitName("player")
            if not realm then
                realm = GetNormalizedRealmName()
            end
            if (not SAPRT.NickNames[name.."-"..realm]) or (SAPRT.Settings["MyNickName"] ~= SAPRT.NickNames[name.."-"..realm]) then
                SAP:NewNickName("player", SAPRT.Settings["MyNickName"], name, realm)
            end
        end
        SAP.SAPUI:Init()
        SAP:InitLDB()
        if WeakAuras.GetData("Northern Sky Externals") then
            print("lease uninstall the |cFF00FFFFPNorthern Sky Externals Weakaura|r to prevent conflicts with the Northern Sky Raid Tools Addon.")
        end
        if C_AddOns.IsAddOnLoaded("NorthernSkyMedia") then
            print("Please uninstall the |cFF00FFFFPNorthern Sky Media Addon|r as this new Addon takes over all its functionality")
        end
    elseif e == "READY_CHECK" and (wowevent or SAPRT.Settings["Debug"]) then
        if WeakAuras.CurrentEncounter then return end
        if SAP:Difficultycheck() or SAPRT.Settings["Debug"] then -- only care about note comparison in normal, heroic&mythic raid
            local hashed = C_AddOns.IsAddOnLoaded("MRT") and SAP_API:GetHash(SAP_API:GetNote()) or ""
            SAP:Broadcast("MRT_NOTE", "RAID", hashed)
        end
    elseif e == "GROUP_FORMED" and (wowevent or SAPRT.Settings["Debug"]) then
        if WeakAuras.CurrentEncounter then return end
        if SAPRT.Settings["MyNickName"] then SAP:SendNickName("Any", true) end -- only send nickname if it exists. If user has ever interacted with it it will create an empty string instead which will serve as deleting the nickname

    elseif e == "MRT_NOTE" and SAPRT.Settings["MRTNoteComparison"] and (internal or SAPRT.Settings["Debug"]) then
        if WeakAuras.CurrentEncounter then return end
        local _, hashed = ...     
        if hashed ~= "" then
            local note = C_AddOns.IsAddOnLoaded("MRT") and SAP_API:GetHash(SAP_API:GetNote()) or ""
            if note ~= "" and note ~= hashed then
                SAP_API:DisplayText("MRT Note Mismatch detected", 5)
            end
        end
    elseif e == "UNIT_AURA" and (SAP.Externals and SAP.Externals.target) and ((UnitIsUnit(SAP.Externals.target, "player") and wowevent) or SAPRT.Settings["Debug"]) then
        local unit, info = ...
        if not SAP.Externals.AllowedUnits[unit] then return end
        if info and info.addedAuras then
            for _, v in ipairs(info.addedAuras) do
                if SAP.Externals.Automated[v.spellId] then
                    local key = SAP.Externals.Automated[v.spellId]
                    local num = (key and SAP.Externals.Amount[key..v.spellId])
                    SAP:EventHandler("SAP_EXTERNAL_REQ", false, true, unit, key, num, false, "skip", v.expirationTime)
                end
            end
        end
    elseif e == "SAP_VERSION_CHECK" and (internal or SAPRT.Settings["Debug"]) then
        if WeakAuras.CurrentEncounter then return end
        local unit, ver, duplicate = ...        
        SAP:VersionResponse({name = UnitName(unit), version = ver, duplicate = duplicate})
    elseif e == "SAP_VERSION_REQUEST" and (internal or SAPRT.Settings["Debug"]) then
        if WeakAuras.CurrentEncounter then return end
        local unit, type, name = ...        
        if UnitExists(unit) and UnitIsUnit("player", unit) then return end -- don't send to yourself
        if UnitExists(unit) and (UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)) then
            local u, ver, duplicate = SAP:GetVersionNumber(type, name, unit)
            SAP:Broadcast("SAP_VERSION_CHECK", "WHISPER", unit, ver, duplicate)
        end
    elseif e == "SAP_NICKNAMES_COMMS" and (internal or SAPRT.Settings["Debug"]) then
        if WeakAuras.CurrentEncounter then return end
        local unit, nickname, name, realm, requestback, channel = ...
        if UnitExists(unit) and UnitIsUnit("player", unit) then return end -- don't add new nickname if it's yourself because already adding it to the database when you edit it
        if requestback and (UnitInRaid(unit) or UnitInParty(unit)) then SAP:SendNickName(channel, false) end -- send nickname back to the person who requested it
        SAP:NewNickName(unit, nickname, name, realm, channel)

    elseif e == "PLAYER_REGEN_ENABLED" and (wowevent or SAPRT.Settings["Debug"]) then
        C_Timer.After(1, function()
            if SAP.SyncNickNamesStore then
                SAP:EventHandler("SAP_NICKNAMES_SYNC", false, true, SAP.SyncNickNamesStore.unit, SAP.SyncNickNamesStore.nicknametable, SAP.SyncNickNamesStore.channel)
                SAP.SyncNickNamesStore = nil
            end
            if SAP.WAString and SAP.WAString.unit and SAP.WAString.string then
                SAP:EventHandler("SAP_WA_SYNC", false, true, SAP.WAString.unit, SAP.WAString.string)
                SAP.WAString = nil
            end
        end)
    elseif e == "SAP_NICKNAMES_SYNC" and (internal or SAPRT.Settings["Debug"]) then
        local unit, nicknametable, channel = ...
        local setting = SAPRT.Settings["NickNamesSyncAccept"]
        if (setting == 3 or (setting == 2 and channel == "GUILD") or (setting == 1 and channel == "RAID") and (not C_ChallengeMode.IsChallengeModeActive())) then 
            if UnitExists(unit) and UnitIsUnit("player", unit) then return end -- don't accept sync requests from yourself
            if UnitAffectingCombat("player") or WeakAuras.CurrentEncounter then
                SAP.SyncNickNamesStore = {unit = unit, nicknametable = nicknametable, channel = channel}
            else
                SAP:NickNamesSyncPopup(unit, nicknametable)
            end
        end
    elseif e == "SAP_WA_SYNC" and (internal or SAPRT.Settings["Debug"]) then
        local unit, str = ...
        local setting = SAPRT.Settings["WeakAurasImportAccept"]
        if setting == 3 then return end
        if UnitExists(unit) and not UnitIsUnit("player", unit) then
            if setting == 2 or (GetGuildInfo(unit) == GetGuildInfo("player")) then -- only accept this from same guild to prevent abuse
                if UnitAffectingCombat("player") or WeakAuras.CurrentEncounter then
                    SAP.WAString = {unit = unit, string = str}
                else
                    SAP:WAImportPopup(unit, str)
                end
            end
        end

    elseif e == "SAP_API_SPEC" then -- Should technically rename to "SAP_SPEC" but need to keep this open for the global broadcast to be compatible with the database WA
        local unit, spec = ...
        SAP.specs = SAP.specs or {}
        SAP.specs[unit] = tonumber(spec)
    elseif e == "SAP_API_SPEC_REQUEST" then
        local specid = GetSpecializationInfo(GetSpecialization())
        SAP_API:Broadcast("SAP_API_SPEC", "RAID", specid)
    elseif e == "ENCOUNTER_START" and ((wowevent and SAP:Difficultycheck()) or SAPRT.Settings["Debug"]) then -- allow sending fake encounter_start if in debug mode, only send spec info in mythic, heroic and normal raids
        SAP.specs = {}
        for u in SAP:IterateGroupMembers() do
            if UnitIsVisible(u) then
                SAP.specs[u] = WeakAuras.SpecForUnit(u)
            end
        end
        -- broadcast spec info
        local specid = GetSpecializationInfo(GetSpecialization())
        SAP_API:Broadcast("SAP_API_SPEC", "RAID", specid)
        C_Timer.After(0.5, function()
            WeakAuras.ScanEvents("SAP_API_ENCOUNTER_START", true)
        end)
        SAP.MacroPresses = {}
        SAP.Externals:Init()
    elseif e == "ENCOUNTER_END" and ((wowevent and SAP:Difficultycheck()) or SAPRT.Settings["Debug"]) then
        local _, encounterName = ...
        if SAPRT.Settings["DebugLogs"] then
            if SAP.MacroPresses and next(SAP.MacroPresses) then SAP:Print("Macro Data for Encounter: "..encounterName, SAP.MacroPresses) end
            if SAP.AssignedExternals and next(SAP.AssignedExternals) then SAP:Print("Assigned Externals for Encounter: "..encounterName, SAP.AssignedExternals) end
            SAP.AssignedExternals = {}
            SAP.MacroPresses = {}
        end        
        C_Timer.After(1, function()
            if SAP.SyncNickNamesStore then
                SAP:EventHandler("SAP_NICKNAMES_SYNC", false, true, SAP.SyncNickNamesStore.unit, SAP.SyncNickNamesStore.nicknametable, SAP.SyncNickNamesStore.channel)
                SAP.SyncNickNamesStore = nil
            end
            if SAP.WAString and SAP.WAString.unit and SAP.WAString.string then
                SAP:EventHandler("SAP_WA_SYNC", false, true, SAP.WAString.unit, SAP.WAString.string)
            end
        end)
    elseif e == "SAP_EXTERNAL_REQ" and ... and UnitIsUnit(SAP.Externals.target, "player") then -- only accept scanevent if you are the "server"
        local unitID, key, num, req, range, expirationTime = ...
        local dead = SAP_API:DeathCheck(unitID)
        SAP.MacroPresses = SAP.MacroPresses or {}
        SAP.MacroPresses["Externals"] = SAP.MacroPresses["Externals"] or {}
        local formattedrange = {}
        if type(range) == "table" then
            for k, v in pairs(range) do
                formattedrange[v.name] = v.range 
            end
        else
            formattedrange = range
        end
        table.insert(SAP.MacroPresses["Externals"], {unit = SAP_API:Shorten(unitID, 8), time = Round(GetTime()-SAP.Externals.pull), dead = dead, key = key, num = num, automated = not req, rangetable = formattedrange})
        if SAP:Difficultycheck(true) and not dead then -- block incoming requests from dead people
            SAP.Externals:Request(unitID, key, num, req, range, false, expirationTime)
        end
    elseif e == "SAP_INNERVATE_REQ" and ... and UnitIsUnit(SAP.Externals.target, "player") then -- only accept scanevent if you are the "server"
        local unitID, key, num, req, range, expirationTime = ...
        local dead = SAP_API:DeathCheck(unitID)
        SAP.MacroPresses = SAP.MacroPresses or {}
        SAP.MacroPresses["Innervate"] = SAP.MacroPresses["Innervate"] or {}
        local formattedrange = {}
        if type(range) == "table" then
            for k, v in pairs(range) do
                formattedrange[v.name] = v.range 
            end
        else
            formattedrange = range
        end
        table.insert(SAP.MacroPresses["Innervate"], {unit = SAP_API:Shorten(unitID, 8), time = Round(GetTime()-SAP.Externals.pull), dead = dead, key = key, num = num, rangetable = formattedrange})
        if SAP:Difficultycheck(true) and not dead then -- block incoming requests from dead people
            SAP.Externals:Request(unitID, "", 1, true, range, true, expirationTime)
        end
    elseif e == "SAP_EXTERNAL_YES" and ... then
        local _, unit, spellID = ...
        SAP:DisplayExternal(spellID, unit)
    elseif e == "SAP_EXTERNAL_NO" then
        local unit, innervate = ...      
        if innervate == "Innervate" then
            SAP:DisplayExternal("NoInnervate")
        else
            SAP:DisplayExternal()
        end
    elseif e == "SAP_EXTERNAL_GIVE" and ... then
        local _, unit, spellID = ...
        local hyperlink = C_Spell.GetSpellLink(spellID)
        WeakAuras.ScanEvents("CHAT_MSG_WHISPER", hyperlink, unit)
    elseif e == "SAP_PAMACRO" and (internal or SAPRT.Settings["Debug"]) then
        local unitID = ...
        if unitID and UnitExists(unitID) and SAPRT.Settings["DebugLogs"] then
            SAP.MacroPresses = SAP.MacroPresses or {}
            SAP.MacroPresses["Private Aura"] = SAP.MacroPresses["Private Aura"] or {}
            table.insert(SAP.MacroPresses["Private Aura"], {name = SAP_API:Shorten(unitID, 8), time = Round(GetTime()-SAP.Externals.pull)})
        end
    end
end


--[[ add debug config
elseif e == "SAP_API_MACRO_RECEIVE" and aura_env.config.debug then
local unit = ...
local cname = SAP_API:Shorten(unit, 8)
print(cname, "pressed Macro")
DebugPrint(cname, "pressed Macro", GetTime())
-- WeakAuras.ScanEvents("SAP_MACRO_RECEIVE", unit) add this to another aura    ]]

    --[[ add custom option for this
elseif e == "MRT_NOTE_UPDATE" then
    if aura_env.config.mrtcheck and ((not aura_env.last) or aura_env.last < GetTime()-1) and VMRT.Note.Text1 and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not WeakAuras.CurrentEncounter then -- cap at max once per second because MRT sends this event multiple times on large notes. Also only check if you are group leader or assist
        local diff = select(3, GetInstanceInfo()) or 0
        if diff == 16 then -- Mythic only
            aura_env.last = GetTime()
            C_Timer.After(1, function() -- doing this delayed because the note is sent in multiple batches so need to wait until the entire note is there
                WeakAuras.ScanEvents("SAP_API_MRT_NOTE_CHECK", true)
            end)
        end
    end]]
    --[[
        elseif e == "SAP_API_MRT_NOTE_CHECK" and ... then
            local text = _G.VMRT.Note.Text1
            local list = false
            local startline = ""
            for line in text:gmatch('[^\r\n]+') do
                line = strtrim(line) --trim whitespace
                --check for start/end of the name list
                local charlist = {}
                local missing = {}
                local count = 0
                if string.match(line, "ns.*start") or line == "intstart" then -- match any string that starts with "ns" and ends with "start" as well as the interrupt WA
                    charlist = {}
                    missing = {}
                    count = 0
                    list = true
                    startline = line
                elseif string.match(line, "ns.*end") or line == "intend" then
                    list = false
                    local endline = line
                    if #missing >= 1 then
                        print("|cffff4040The following players between the lines |r|cff3ffc3f'"..startline.."'|r|cffff4040 and |r'|cff3ffc3f"..endline.."'|r |cffff4040are in the note but not in the raid:|r")
                        local s = ""
                        for _, v in ipairs(missing) do
                            s = s..v.." "
                        end
                        print(s)
                        local t = ""
                        for unit in WA_IterateGroupMembers() do
                            local i = UnitInRaid(unit)
                            if select(3, GetRaidRosterInfo(i)) <= 4 and not charlist[unit] then
                                if startline == "nsdispelstart" then -- only consider healers for the default dispel naming convention
                                    if UnitGroupRolesAssigned(unit) == "HEALER" then
                                        t = t..WA_ClassColorName(UnitName(unit)).." "
                                    end
                                else
                                    t = t..WA_ClassColorName(UnitName(unit)).." "
                                end
                            end
                        end
                        if t ~= "" then
                            print("|cff409fffThe following players are missing from this note:|r")
                            print(t)
                        end
                    end
                end
                if list then
                    line = line:gsub("{.-}", "") -- cleaning markers from line
                    for name in line:gmatch("%S+") do -- finding all remaining strings
                        local name2 = name:gsub("||r", "") -- clean colorcode
                        name2 = name2:gsub("||c%x%x%x%x%x%x%x%x", "") -- clean colorcode
                            name2 = SAP_API:GetChar(name2, true) -- first converts from character name to nickname and then back to a character name that's actually in the raid. This allows checking for any character of the player
                        local i = UnitInRaid(name2)
                        if i and select(3, GetRaidRosterInfo(i)) <= 4 then
                            charlist["raid"..i] = true
                        elseif name2 ~= name and not tIndexOf(missing, name2) then -- only check if string was color coded, this should ensure we're not counting things that aren't actually character names
                            name = name:gsub("||r", "") -- clean colorcode
                            name = name:gsub("||c%x%x%x%x%x%x%x%x", "") -- clean colorcode
                            table.insert(missing, name)
                        end
                    end
                end
            end
        end]]