local _, SAP = ... -- Internal namespace
local Grid2Status
local fullCharList = {}
local fullNameList = {}
local sortedCharList = {}
local CharList = {}
local LibTranslit = LibStub("LibTranslit-1.0")

function SAP_API:GetCharacters(str) -- Returns table of all Characters from Nickname or Character Name
    if not str then
        error("SAP_API:GetCharacters(str), str is nil")
        return
    end
    if not sortedCharList[str] then
        return CharList[str] and CopyTable(CharList[str])
    else
        return sortedCharList[str] and CopyTable(sortedCharList[str])
    end
end

function SAP_API:GetAllCharacters()
    return CopyTable(fullCharList)
end

function SAP_API:GetName(str, AddonName) -- Returns Nickname
    local unitname = UnitExists(str) and UnitName(str) or str
    if SAPRT.Settings["Translit"] then
        unitname = LibTranslit:Transliterate(unitname)
    end
    -- check if setting for the requesting addon is enabled, if not return the original name.
    -- if no AddonName is given we assume it's from an old WeakAura as they never specified
    if (not SAPRT.Settings["GlobalNickNames"]) or (AddonName and not SAPRT.Settings[AddonName]) then
        return unitname
    end

    if not str then
        error("SAP_API:GetName(str), str is nil")
        return
    end
    if UnitExists(str) then
        local name, realm = UnitFullName(str)
        if not realm then
            realm = GetNormalizedRealmName()
        end
        local nickname = name and realm and fullCharList[name.."-"..realm]
        if nickname and SAPRT.Settings["Translit"] then
            nickname = LibTranslit:Transliterate(nickname)
        end
        if SAPRT.Settings["Translit"] then
            name = LibTranslit:Transliterate(name)
        end
        return nickname or name
    else
        local nickname = fullCharList[str]
        if not nickname then
            nickname = fullNameList[str]
        end
        if nickname and SAPRT.Settings["Translit"] then
            nickname = LibTranslit:Transliterate(nickname)
        end
        return nickname or unitname
    end
end

function SAP_API:GetChar(name, nick) -- Returns Char in Raid from Nickname or Character Name with nick = true
    name = nick and SAP_API:GetName(name) or name
    if UnitExists(name) and UnitIsConnected(name) then return name end
    local chars = SAP_API:GetCharacters(name)
    if chars then
        for k, _ in pairs(chars) do
            local _name, realm = strsplit("-", k)
            local i = UnitInRaid(k)
            if UnitIsVisible(_name) or (i and select(3, GetRaidRosterInfo(i)) <= 4)  then
                return _name, realm
            end
        end
    end
    return name -- Return input if nothing was found
end

-- Own NickName Change
function SAP:NickNameUpdated(nickname)
    local name, realm = UnitFullName("player")
    if not realm then
        realm = GetNormalizedRealmName()
    end
    local oldnick = SAPRT.NickNames[name .. "-" .. realm]
    if (not oldnick) or oldnick ~= nickname then
        SAP:SendNickName("Any")
        SAP:NewNickName("player", nickname, name, realm)
    end
end

-- Grid2 Option Change
function SAP:Grid2NickNameUpdated(all, unit)
    if Grid2 then
        if all then
            for u in SAP:IterateGroupMembers() do
                Grid2Status:UpdateIndicators(u)
            end
        else
            for u in SAP:IterateGroupMembers() do -- if unit is in group refresh grid2 display, could be a guild message instead
                if unit then
                    if UnitExists(unit) and UnitIsUnit(u, unit) then
                        Grid2Status:UpdateIndicators(u)
                        break
                    end
                else
                    Grid2Status:UpdateIndicators(u)
                end    
            end
        end
     end
end

-- Wipe NickName Database
function SAP:WipeNickNames()
    SAP:WipeCellDB()
    SAPRT.NickNames = {}
    fullCharList = {}
    fullNameList = {}
    sortedCharList = {}
    CharList = {}
    -- all addons that need a display update, which is basically all but WA
    SAP:UpdateNickNameDisplay(true)
end

function SAP:WipeCellDB()
    if CellDB then
        for name, nickname in pairs(SAPRT.NickNames) do -- wipe cell database
            local i = tIndexOf(CellDB.nicknames.list, name..":"..nickname)
            if i then
                local charname = strsplit("-", name)
                Cell.Fire("UpdateNicknames", "list-update", name, charname)
                table.remove(CellDB.nicknames.list, i)
            end
        end
    end
end

function SAP:BlizzardNickNameUpdated()
    if C_AddOns.IsAddOnLoaded("Blizzard_CompactRaidFrames") and SAPRT.Settings["Blizzard"] and not SAP.BlizzardNickNamesHook then
        SAP.BlizzardNickNamesHook = true
        hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
            if frame:IsForbidden() or not frame.unit then
                return
            end
            frame.name:SetText(SAP_API:GetName(frame.unit, "Blizzard"))
        end)
    end
end

function SAP:MRTUpdateNoteDisplay(noteFrame)
    local note = noteFrame and noteFrame.text and noteFrame.text:GetText()
    if not note then return end
    local namelist = {}
    local colorlist = {}
    for name in note:gmatch("%S+") do -- finding all strings
        local charname = SAP_API:Shorten(SAP_API:GetChar(name, true), false, false, "MRT") -- getting color coded nickname for this character
        if charname ~= name then         
            namelist[name] = {name = charname, color = false}
        end
    end                
    for colorcode, name in note:gmatch(("|c(%x%x%x%x%x%x%x%x)(.-)|r")) do -- do the same for color coded strings again
        local charname =  SAP_API:Shorten(SAP_API:GetChar(name, true), false, false, "MRT") -- getting color coded nickname for this character
        if charname ~= name then
            namelist[name] = {name = charname, color = true}
        end
    end
    for notename, v in pairs(namelist) do
        note = note:gsub("(%f[%w])"..notename.."(%f[%W])", "%1"..v.name.."%2")
        if v.color then -- if initial name already had a colorcode, need to do different replacement
            note = note:gsub("|c%x%x%x%x%x%x%x%x"..notename.."|r", v.name)
        end
    end
    noteFrame.text:SetText(note)
end

function SAP:MRTNickNameUpdated(skipcheck)
    if C_AddOns.IsAddOnLoaded("MRT") then
        if skipcheck or SAPRT.Settings["MRT"] then -- on init we only do this if the player has MRT Nicknames enabled, also whenever the setting changes we skip the setting check
            SAP:MRTUpdateNoteDisplay(MRTNote)
        end
        if SAPRT.Settings["MRT"] and GMRT and GMRT.F and not SAP.MRTNickNamesHook then
            SAP.MRTNickNamesHook = true
            GMRT.F:RegisterCallback(
                "RaidCooldowSAP_Bar_TextName",
                function(event, bar, data)
                    if data and data.name then
                        data.name = SAP_API:GetName(data.name, "MRT")
                    end
                end
            )
            GMRT.F:RegisterCallback(
                "Note_UpdateText", 
                function(event, noteFrame)
                    SAP:MRTUpdateNoteDisplay(noteFrame)
                end    
            )
        end
    end
end

function SAP:OmniCDNickNameUpdated()
    if SAPRT.Settings["OmniCD"] and C_AddOns.IsAddOnLoaded("OmniCD") and not SAP.OmniCDNickNamesHook then
        SAP.OmniCDNickNamesHook = true
        -- Add OmniCD Hook
    end
end

-- Cell Option Change
function SAP:CellNickNameUpdated(all, unit, name, realm, oldnick, nickname)
    if CellDB then
        if SAPRT.Settings["Cell"] and SAPRT.Settings["GlobalNickNames"] then
            if all then -- update all units
                for u in SAP:IterateGroupMembers() do
                    local _name, _realm = UnitFullName(u)
                    if not _realm then
                        _realm = GetNormalizedRealmName()
                    end
                    if SAPRT.NickNames[_name .."-".. _realm] then
                        local nick = SAPRT.NickNames[_name .."-".. _realm]
                        local i = tIndexOf(CellDB.nicknames.list, _name .."-".. _realm ..":"..nick)
                        if i then -- update nickame if it already exists
                            CellDB.nicknames.list[i] = _name .."-".. _realm ..":"..nick
                            Cell.Fire("UpdateNicknames", "list-update", _name .."-".. _realm, nick)
                        else -- insert if it doesn't exist yet
                            SAP:CellInsertName(_name, _realm, nick, true)
                        end
                    end
                end
                return
            elseif nickname == "" then -- newnick is an empty string so remove any old nick we still have
                if oldnick then -- if there is an oldnick, remove it 
                    local i = tIndexOf(CellDB.nicknames.list, name.."-"..realm..":"..oldnick)
                    if i then
                        table.remove(CellDB.nicknames.list, i)
                        Cell.Fire("UpdateNicknames", "list-update", name.."-"..realm, name)
                    end
                end
            elseif unit then -- if the function was called for a sepcific unit
                local ingroup = false
                for u in SAP:IterateGroupMembers() do -- if unit is in group refresh cell display, could be a guild message instead
                    if UnitExists(unit) and UnitIsUnit(u, unit) then
                        ingroup = true
                        break
                    end
                end
                if oldnick then -- check if oldnick exists in database already and overwrite it if it does, otherwise insert
                    local i = tIndexOf(CellDB.nicknames.list, name.."-"..realm..":"..oldnick)
                    if i then
                        CellDB.nicknames.list[i] = name.."-"..realm..":"..nickname
                        if ingroup then
                            Cell.Fire("UpdateNicknames", "list-update", name.."-"..realm, nickname)
                        end
                    else
                        SAP:CellInsertName(name, realm, nickname, ingroup)
                    end
                else -- if no old nickname, just insert the new one
                    SAP:CellInsertName(name, realm, nickname, ingroup)
                end
            end
        else
            SAP:WipeCellDB()
        end
    end
end

function SAP:CellInsertName(name, realm, nickname, ingroup)
    if tInsertUnique(CellDB.nicknames.list, name.."-"..realm..":"..nickname) and ingroup then
        Cell.Fire("UpdateNicknames", "list-update", name.."-"..realm, nickname)
    end
end



-- ElvUI Option Change
function SAP:ElvUINickNameUpdated()
    if ElvUF and ElvUF.Tags then
        ElvUF.Tags:RefreshMethods("NSNickName")
        for i=1, 12 do
            ElvUF.Tags:RefreshMethods("NSNickName:"..i)
        end
    end    
end

-- UUFG Option Change
function SAP:UnhaltedNickNameUpdated()
    if UUFG then
        UUFG:UpdateAllTags() 
    end    
end

function SAP:WeakAurasNickNameUpdated()
    if SAPRT.Settings["WA"] then
        if not C_AddOns.IsAddOnLoaded("CustomNames") then
            function WeakAuras.GetName(name)
                return SAP_API:GetName(name, "WA")
            end

            function WeakAuras.UnitName(unit)
                local _, realm = UnitName(unit)
                return SAP_API:GetName(unit, "WA"), realm
            end

            function WeakAuras.GetUnitName(unit, server)
                local name = SAP_API:GetName(unit, "WA")
                if server then
                    local _, realm = UnitFullName(unit)
                    if not realm then
                        realm = GetNormalizedRealmName()
                    end
                    name = name.."-"..realm
                end
                return name
            end

            function WeakAuras.UnitFullName(unit)
                local name, realm = UnitFullName(unit)
                return SAP_API:GetName(name, "WA"), realm
            end
        end
    end
end

-- Global NickName Option Change
function SAP:GlobalNickNameUpdate()
    fullCharList = {}
    fullNameList = {}
    sortedCharList = {}
    CharList = {}
    if SAPRT.Settings["GlobalNickNames"] then
        for fullname, nickname in pairs(SAPRT.NickNames) do
            local name, realm = strsplit("-", fullname)
            fullCharList[fullname] = nickname
            fullNameList[name] = nickname
            if not sortedCharList[nickname] then
                sortedCharList[nickname] = {}
            end
            sortedCharList[nickname][fullname] = true
            if not CharList[nickname] then
                CharList[nickname] = {}
            end
            CharList[nickname][name] = true
        end
        if SAPRT.Settings["WA"] then
            if not C_AddOns.IsAddOnLoaded("CustomNames") then
                function WeakAuras.GetName(name)
                    return SAP_API:GetName(name, "WA")
                end

                function WeakAuras.UnitName(unit)
                    local _, realm = UnitName(unit)
                    return SAP_API:GetName(unit, "WA"), realm
                end

                function WeakAuras.GetUnitName(unit, server)
                    local name = SAP_API:GetName(unit, "WA")
                    if server then
                        local _, realm = UnitFullName(unit)
                        if not realm then
                            realm = GetNormalizedRealmName()
                        end
                        name = name.."-"..realm
                    end
                    return name
                end

                function WeakAuras.UnitFullName(unit)
                    local name, realm = UnitFullName(unit)
                    return SAP_API:GetName(name, "WA"), realm
                end
            end
        end
    end
    
    -- instant display update for all addons
    SAP:UpdateNickNameDisplay(true)
end



function SAP:UpdateNickNameDisplay(all, unit, name, realm, oldnick, nickname)
    SAP:CellNickNameUpdated(all, unit, name, realm, oldnick, nickname) -- always have to do cell before doing any changes to the nickname database
    if nickname == ""  and SAPRT.NickNames[name.."-"..realm] then
        SAPRT.NickNames[name.."-"..realm] = nil
        fullCharList[name.."-"..realm] = nil
        fullNameList[name] = nil
        sortedCharList[nickname] = nil
        CharList[nickname] = nil
    end     
    SAP:Grid2NickNameUpdated(unit)
    SAP:ElvUINickNameUpdated()
    SAP:UnhaltedNickNameUpdated()
    SAP:BlizzardNickNameUpdated()
    SAP:MRTNickNameUpdated(true)
    SAP:OmniCDNickNameUpdated()
end

function SAP:InitNickNames()


    if SAPRT.Settings["GlobalNickNames"] then
        
        if not C_AddOns.IsAddOnLoaded("CustomNames") then
            function WeakAuras.GetName(name)
                return SAP_API:GetName(name, "WA")
            end

            function WeakAuras.UnitName(unit)
                local _, realm = UnitName(unit)
                return SAP_API:GetName(unit, "WA"), realm
            end

            function WeakAuras.GetUnitName(unit, server)
                local name = SAP_API:GetName(unit, "WA")
                if server then
                    local _, realm = UnitFullName(unit)
                    if not realm then
                        realm = GetNormalizedRealmName()
                    end
                    name = name.."-"..realm
                end
                return name
            end

            function WeakAuras.UnitFullName(unit)
                local name, realm = UnitFullName(unit)
                return SAP_API:GetName(name, "WA"), realm
            end
        end

    	SAP:MRTNickNameUpdated(false)
    	SAP:BlizzardNickNameUpdated()
    	SAP:OmniCDNickNameUpdated()
        for fullname, nickname in pairs(SAPRT.NickNames) do
            local name, realm = strsplit("-", fullname)
            fullCharList[fullname] = nickname
            fullNameList[name] = nickname
            if not sortedCharList[nickname] then
                sortedCharList[nickname] = {}
            end
            sortedCharList[nickname][fullname] = true
            if not CharList[nickname] then
                CharList[nickname] = {}
            end
            CharList[nickname][name] = true
        end
    end

    if Grid2 then
        Grid2Status = Grid2.statusPrototype:new("NSNickName")

        Grid2Status.IsActive = Grid2.statusLibrary.IsActive

        function Grid2Status:UNIT_NAME_UPDATE(_, unit)
            self:UpdateIndicators(unit)
        end

        function Grid2Status:OnEnable()
            self:RegisterEvent("UNIT_NAME_UPDATE")
        end

        function Grid2Status:OnDisable()
            self:UnregisterEvent("UNIT_NAME_UPDATE")
        end

        function Grid2Status:GetText(unit)
            local name = UnitName(unit)
            return name and SAP_API and SAP_API:GetName(name, "Grid2") or name
        end

        local function Create(baseKey, dbx)
            Grid2:RegisterStatus(Grid2Status, {"text"}, baseKey, dbx)
            return Grid2Status
        end

        Grid2.setupFunc["NSNickName"] = Create

        Grid2:DbSetStatusDefaultValue( "NSNickName", {type = "NSNickName"})        
    end

    if ElvUF and ElvUF.Tags then
        ElvUF.Tags.Events['NSNickName'] = 'UNIT_NAME_UPDATE'
        ElvUF.Tags.Methods['NSNickName'] = function(unit)
            local name = UnitName(unit)
            return name and SAP_API and SAP_API:GetName(name, "ElvUI") or name
        end
        for i=1, 12 do
            ElvUF.Tags.Events['NSNickName:'..i] = 'UNIT_NAME_UPDATE'
            ElvUF.Tags.Methods['NSNickName:'..i] = function(unit)
                local name = UnitName(unit)
                name = name and SAP_API and SAP_API:GetName(name, "ElvUI") or name
                return string.sub(name, 1, i)
            end
        end
    end

    if CellDB and SAPRT.Settings["Cell"] then
        for name, nickname in pairs(SAPRT.NickNames) do
            if tInsertUnique(CellDB.nicknames.list, name..":"..nickname) then
                Cell.Fire("UpdateNicknames", "list-update", name, nickname)
            end
        end
    end
end

function SAP:SendNickName(channel, requestback)
    requestback = requestback or false
    local now = GetTime()
    if (SAP.LastNickNameSend and SAP.LastNickNameSend > now-0.25) or SAPRT.Settings["ShareNickNames"] == 4 then return end -- don't let user spam nicknames
    if requestback and (SAP.LastNickNameSend and SAP.LastNickNameSend > now-2) or SAPRT.Settings["ShareNickNames"] == 4 then return end -- don't overspam on forming raid
    SAP.LastNickNameSend = now
    local nickname = SAPRT.Settings["MyNickName"]
    if (not nickname) or WeakAuras.CurrentEncounter then return end
    local name, realm = UnitFullName("player")
    if not realm then
        realm = GetNormalizedRealmName()
    end
    if nickname then
        if UnitInRaid("player") and (SAPRT.Settings["ShareNickNames"] == 1 or SAPRT.Settings["ShareNickNames"] == 3) and (channel == "Any" or channel == "RAID") then
            SAP:Broadcast("SAP_NICKNAMES_COMMS", "RAID", nickname, name, realm, requestback, "RAID")
        end
        if (SAPRT.Settings["ShareNickNames"] == 2 or SAPRT.Settings["ShareNickNames"] == 3) and (channel == "Any" or channel == "GUILD") then
            SAP:Broadcast("SAP_NICKNAMES_COMMS", "GUILD", nickname, name, realm, requestback, "GUILD")
        end
    end
end

function SAP:NewNickName(unit, nickname, name, realm, channel)
    if WeakAuras.CurrentEncounter then return end
    if unit ~= "player" and SAPRT.Settings["AcceptNickNames"] ~= 3 then
        if channel == "GUILD" and SAPRT.Settings["AcceptNickNames"] ~= 2 then return end
        if channel == "RAID" and SAPRT.Settings["AcceptNickNames"] ~= 1 then return end
    end
    if not nickname or not name or not realm then return end   
    local oldnick = SAPRT.NickNames[name.."-"..realm]
    if oldnick and oldnick == nickname then  return end -- stop early if we already have this exact nickname  
    if nickname == "" then
        SAP:UpdateNickNameDisplay(false, unit, name, realm, oldnick, nickname)
        return
    end
    if string.len(nickname) > 12 then
        nickname = string.sub(nickname, 1, 12)
    end
    SAPRT.NickNames[name.."-"..realm] = nickname
    if SAPRT.Settings["GlobalNickNames"] then
        fullCharList[name.."-"..realm] = nickname
        fullNameList[name] = nickname
        if not sortedCharList[nickname] then
            sortedCharList[nickname] = {}
        end
        sortedCharList[nickname][name.."-"..realm] = true
        if not CharList[nickname] then
            CharList[nickname] = {}
        end
        CharList[nickname][name] = true
        SAP:UpdateNickNameDisplay(false, unit, name, realm, oldnick, nickname)
    end
end


function SAP:ImportNickNames(string) -- string format is charactername-realm:nickname;charactername-realm:nickname;...
    if string ~= "" then
        string = string.gsub(string, "%s+", "") -- remove all whitespaces
        for _, str in pairs({strsplit(";", string)}) do
            if str ~= "" then
                local namewithrealm, nickname = strsplit(":", str)
                if namewithrealm and nickname then
                    local name, realm = strsplit("-", namewithrealm)
                    local unit
                    if name and realm then
                        SAPRT.NickNames[name.."-"..realm] = nickname
                    end
                else
                    error("Error parsing names: "..str, 1)
            
                end
            end
        end
        SAP:GlobalNickNameUpdate()
    end
end

function SAP:SyncNickNames()
    local now = GetTime()
    if (SAP.LastNickNameSync and SAP.LastNickNameSync > now-4) or (SAPRT.Settings["NickNamesSyncSend"] == 3) then return end -- don't let user spam syncs / end early if set to none
    SAP.LastNickNameSync = now
    local channel = SAPRT.Settings["NickNamesSyncSend"] == 1 and "RAID" or "GUILD"
    SAP:Broadcast("SAP_NICKNAMES_SYNC", channel, SAPRT.NickNames, channel) -- channel is either GUILD or RAID
end

function SAP:SyncNickNamesAccept(nicknametable)
    for name, nickname in pairs(nicknametable) do
        SAPRT.NickNames[name] = nickname
    end
    SAP:GlobalNickNameUpdate()
end

function SAP:AddNickName(name, realm, nickname) -- keeping the nickname empty acts as removing the nickname for that character
    if name and realm and nickname then
        local unit
        if UnitExists(name) then
            for u in SAP:IterateGroupMembers() do
                if UnitIsUnit(u, name) then
                    unit = u
                    break
                end
            end
        end
        SAP:NewNickName(unit, nickname, name, realm, channel)
    end
end