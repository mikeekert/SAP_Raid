local _, SAP = ... -- Internal namespace

function SAP:RequestVersionNumber(type, name) -- type == "Addon" or "WA" or "Note"
    if (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
        local unit, ver, duplicate, url = SAP:GetVersionNumber(type, name, unit)
        SAP:VersionResponse({name = UnitName("player"), version = "No Response", duplicate = false})
        SAP:Broadcast("SAP_VERSION_REQUEST", "RAID", type, name)
        for _unit in SAP:IterateGroupMembers() do
            if UnitInRaid(_unit) and not UnitIsUnit("player", _unit) then
                local index = UnitInRaid(_unit)
                local response = select(8, GetRaidRosterInfo(index)) and "No Reponse" or "Offline"
                SAP:VersionResponse({ name = UnitName(_unit), version = response, duplicate = false})
            end
        end
        return {name = UnitName("player"), version = ver, duplicate = duplicate}, url
    end
end
function SAP:VersionResponse(data)
    SAP.SAPUI.version_scrollbox:AddData(data)
end


function SAP:GetVersionNumber(type, name, unit)
    if type == "Addon" then
        local ver = C_AddOns.GetAddOnMetadata(name, "Version") or "Addon Missing"
        if ver ~= "Addon Missing" then
            ver = C_AddOns.IsAddOnLoaded(name) and ver or "Addon not enabled"
        end
        return unit, ver, false, ""
    elseif type == "WA" then
        local waData = WeakAuras.GetData(name)
        local ver = "WA Missing"
        local url = ""
        if waData then
            ver = 0
            if waData["url"] then
                url = waData["url"]
                ver = tonumber(waData["url"]:match('.*/(%d+)$'))
            end
        end
        local duplicate = false
        for i=2, 10 do -- check for duplicates of the Weakaura
            waData = WeakAuras.GetData(name.." "..i)
            if waData then duplicate = true break end
        end
        return unit, ver, duplicate, url
    elseif type == "Note" then
        local note = SAP_API:GetNote()
        local hashed
        if C_AddOns.IsAddOnLoaded("MRT") then
            hashed = SAP_API:GetHash(note) or "Note Missing"
        else
            hashed = C_AddOns.GetAddOnMetadata("MRT", "Version") and "MRT not enabled" or "MRT not installed"
        end
    
        return unit, hashed, false, ""
    end
end