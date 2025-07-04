local _, SAP = ...
local f = CreateFrame("Frame")
for _, event in ipairs({
    "ENCOUNTER_START", "ENCOUNTER_END", "UNIT_AURA", "READY_CHECK",
    "GROUP_FORMED", "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_REGEN_ENABLED"
}) do f:RegisterEvent(event) end

local function initSettings()
    SAPSaved = SAPSaved or {}
    SAPSaved.SAPUI = SAPSaved.SAPUI or {scale = 1}
    SAPSaved.SAPUI.externals_anchor = SAPSaved.SAPUI.externals_anchor or {}
    SAPSaved.Settings = SAPSaved.Settings or {}
    local defaults = {
        Blizzard = false, WA = false, MRT = false, Cell = false, Grid2 = false,
        OmniCD = false, ElvUI = false, Translit = false, Unhalted = false,
        WeakAurasImportAccept = 1, MRTNoteComparison = false, TTS = true,
        TTSVolume = 50, TTSVoice = 2, Minimap = {hide = false},
        VersionCheckRemoveResponse = false, Debug = false, DebugLogs = false,
        VersionCheckPresets = {}
    }
    for k, v in pairs(defaults) do
        if SAPSaved.Settings[k] == nil then SAPSaved.Settings[k] = v end
    end
    SAPSaved.SAPUI.AutoComplete = SAPSaved.SAPUI.AutoComplete or {}
    SAPSaved.SAPUI.AutoComplete.WA = SAPSaved.SAPUI.AutoComplete.WA or {}
    SAPSaved.SAPUI.AutoComplete.Addon = SAPSaved.SAPUI.AutoComplete.Addon or {}
end

local function ensureMacro()
    local macrotext = "/run SAP_API:PrivateAura();"
    local pafound, macrocount = false, 0
    for i = 1, 120 do
        local name = C_Macro.GetMacroName(i)
        if not name then break end
        macrocount = i
        if name == "SAP PA Macro" then
            EditMacro(i, "SAP PA Macro", 132288, macrotext, false)
            pafound = true
            break
        end
    end
    if not pafound then
        if macrocount >= 120 then
            print("You reached the global Macro cap so the Private Aura Macro could not be created")
        else
            CreateMacro("SAP PA Macro", 132288, macrotext, false)
        end
    end
end

f:SetScript("OnEvent", function(_, e, ...)
    SAP:EventHandler(e, true, false, ...)
end)

function SAP:EventHandler(e, wowevent, internal, ...)
    if e == "ADDON_LOADED" and wowevent then
        if (...) == "SAP_Raid" then initSettings() end
    elseif e == "PLAYER_LOGIN" and wowevent then
        ensureMacro()
        SAP.SAPUI:Init()
        SAP:InitLDB()
    elseif e == "READY_CHECK" and (wowevent or SAPSaved.Settings.Debug) then
        if not WeakAuras.CurrentEncounter and (SAP:DiffCheck() or SAPSaved.Settings.Debug) then
            local hashed = C_AddOns.IsAddOnLoaded("MRT") and SAP_API:GetHash(SAP_API:GetNote()) or ""
            SAP:Broadcast("MRT_NOTE", "RAID", hashed)
        end
    elseif e == "MRT_NOTE" and SAPSaved.Settings.MRTNoteComparison and (internal or SAPSaved.Settings.Debug) then
        if not WeakAuras.CurrentEncounter then
            local _, hashed = ...
            if hashed ~= "" then
                local note = C_AddOns.IsAddOnLoaded("MRT") and SAP_API:GetHash(SAP_API:GetNote()) or ""
                if note ~= "" and note ~= hashed then SAP_API:DisplayText("MRT Note Mismatch detected", 5) end
            end
        end
    elseif e == "UNIT_AURA" and SAP.Externals and SAP.Externals.target and ((UnitIsUnit(SAP.Externals.target, "player") and wowevent) or SAPSaved.Settings.Debug) then
        local unit, info = ...
        if SAP.Externals.AllowedUnits[unit] and info and info.addedAuras then
            for _, v in ipairs(info.addedAuras) do
                local key = SAP.Externals.Automated[v.spellId]
                if key then
                    local num = SAP.Externals.Amount[key..v.spellId]
                    SAP:EventHandler("SAP_EXTERNAL_REQ", false, true, unit, key, num, false, "skip", v.expirationTime)
                end
            end
        end
    elseif e == "SAP_VERSION_CHECK" and (internal or SAPSaved.Settings.Debug) then
        if not WeakAuras.CurrentEncounter then
            local unit, ver, duplicate = ...
            SAP:VersionResponse({name = UnitName(unit), version = ver, duplicate = duplicate})
        end
    elseif e == "SAP_VERSION_REQUEST" and (internal or SAPSaved.Settings.Debug) then
        if not WeakAuras.CurrentEncounter then
            local unit, type, name = ...
            if UnitExists(unit) and not UnitIsUnit("player", unit) and (UnitIsGroupLeader(unit) or UnitIsGroupAssistant(unit)) then
                local _, ver, duplicate = SAP:GetVersionNumber(type, name, unit)
                SAP:Broadcast("SAP_VERSION_CHECK", "WHISPER", unit, ver, duplicate)
            end
        end
    elseif e == "PLAYER_REGEN_ENABLED" and (wowevent or SAPSaved.Settings.Debug) then
        C_Timer.After(1, function()
            if SAP.WAString and SAP.WAString.unit and SAP.WAString.string then
                SAP:EventHandler("SAP_WA_SYNC", false, true, SAP.WAString.unit, SAP.WAString.string)
                SAP.WAString = nil
            end
        end)
    elseif e == "SAP_WA_SYNC" and (internal or SAPSaved.Settings.Debug) then
        local unit, str = ...
        local setting = SAPSaved.Settings.WeakAurasImportAccept
        if setting ~= 3 and UnitExists(unit) and not UnitIsUnit("player", unit) then
            if setting == 2 or (GetGuildInfo(unit) == GetGuildInfo("player")) then
                if UnitAffectingCombat("player") or WeakAuras.CurrentEncounter then
                    SAP.WAString = {unit = unit, string = str}
                else
                    SAP:WAImportPopup(unit, str)
                end
            end
        end
    elseif e == "SAP_API_SPEC" then
        local unit, spec = ...
        SAP.specs = SAP.specs or {}
        SAP.specs[unit] = tonumber(spec)
    elseif e == "SAP_API_SPEC_REQUEST" then
        SAP_API:Broadcast("SAP_API_SPEC", "RAID", GetSpecializationInfo(GetSpecialization()))
    elseif e == "ENCOUNTER_START" and ((wowevent and SAP:DiffCheck()) or SAPSaved.Settings.Debug) then
        SAP.specs = {}
        for u in SAP:IterateGroupMembers() do
            if UnitIsVisible(u) then SAP.specs[u] = WeakAuras.SpecForUnit(u) end
        end
        SAP_API:Broadcast("SAP_API_SPEC", "RAID", GetSpecializationInfo(GetSpecialization()))
        C_Timer.After(0.5, function() WeakAuras.ScanEvents("SAP_API_ENCOUNTER_START", true) end)
        SAP.MacroPresses = {}
        SAP.Externals:Init()
    elseif e == "ENCOUNTER_END" and ((wowevent and SAP:DiffCheck()) or SAPSaved.Settings.Debug) then
        local _, encounterName = ...
        if SAPSaved.Settings.DebugLogs then
            if SAP.MacroPresses and next(SAP.MacroPresses) then SAP:Print("Macro Data for Encounter: "..encounterName, SAP.MacroPresses) end
            if SAP.AssignedExternals and next(SAP.AssignedExternals) then SAP:Print("Assigned Externals for Encounter: "..encounterName, SAP.AssignedExternals) end
            SAP.AssignedExternals, SAP.MacroPresses = {}, {}
        end
        C_Timer.After(1, function()
            if SAP.WAString and SAP.WAString.unit and SAP.WAString.string then
                SAP:EventHandler("SAP_WA_SYNC", false, true, SAP.WAString.unit, SAP.WAString.string)
            end
        end)
    elseif e == "SAP_PAMACRO" and (internal or SAPSaved.Settings.Debug) then
        local unitID = ...
        if unitID and UnitExists(unitID) and SAPSaved.Settings.DebugLogs then
            SAP.MacroPresses = SAP.MacroPresses or {}
            SAP.MacroPresses["Private Aura"] = SAP.MacroPresses["Private Aura"] or {}
            table.insert(SAP.MacroPresses["Private Aura"], {name = SAP_API:Shorten(unitID, 8), time = Round(GetTime()-SAP.Externals.pull)})
        end
    end
end