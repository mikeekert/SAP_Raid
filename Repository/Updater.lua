local addOnName, SAP = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")
local AceComm = LibStub("AceComm-3.0")

local lastUpdate = 0
local updateQueued = false

local UIDToID = {}
local auraUIDs = {}
local guidToVersionsTable = {}

local serializedTable
local playerVersionsTable

local UpdateVersionsForUnit = function(_, _) end

function SAP:GetInstalledAuraDataByUID(uid)
    local installedAuraID = UIDToID[uid]

    return installedAuraID and WeakAuras.GetData(installedAuraID)
end

function SAP:GetVersionsTableForGUID(GUID)
    return guidToVersionsTable[GUID]
end

function SAP:UpdateVersionsTableForGUID(GUID, versionsTable)
    guidToVersionsTable[GUID] = versionsTable
end

local function BroadcastVersions()
    local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"

    AceComm:SendCommMessage("AU_Versions", serializedTable, "GUILD")
    AceComm:SendCommMessage("AU_Versions", serializedTable, chatType)

    UpdateVersionsForUnit(playerVersionsTable, "player")
end

local function SerializeVersionsTable()
    for displayName, auraData in pairs(SAPSaved.WeakAuras) do
        local uid = auraData.d.uid
        local installedAuraID = uid and UIDToID[uid]
        local installedVersion = installedAuraID and WeakAuras.GetData(installedAuraID).version or 0

        playerVersionsTable.auras[displayName] = installedVersion
    end

    local serialized = LibSerialize:Serialize(playerVersionsTable)
    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

    serializedTable = encoded

    if not serializedTable then
        SAP:ErrorPrint("could not serialize version table")
    end
end

local function BuildAuraImportElements()
    lastUpdate = GetTime()
    updateQueued = false

    -- Check if addon requires an update
    local addOnVersionsBehind = SAP.highestSeenVersionsTable.addOn - playerVersionsTable.addOn

    -- Check which auras require updates
    local aurasToUpdate = {}

    for displayName, highestSeenVersion in pairs(SAP.highestSeenVersionsTable.auras) do
        local auraData = SAPSaved.WeakAuras[displayName]
        local uid = auraData and auraData.d.uid
        local importedVersion = auraData and auraData.d.version or 0
        local installedAuraID = uid and UIDToID[uid]
        local installedVersion = installedAuraID and WeakAuras.GetData(installedAuraID).version or 0

        if installedVersion < highestSeenVersion then
            table.insert(
                    aurasToUpdate,
                    {
                        displayName = displayName,
                        installedVersion = installedVersion,
                        importedVersion = importedVersion,
                        highestSeenVersion = highestSeenVersion
                    }
            )
        end
    end

    table.sort(
            aurasToUpdate,
            function(auraData1, auraData2)
                local versionsBehind1 = auraData1.highestSeenVersion - auraData1.installedVersion
                local versionsBehind2 = auraData2.highestSeenVersion - auraData2.installedVersion

                if versionsBehind1 ~= versionsBehind2 then
                    return versionsBehind1 > versionsBehind2
                else
                    return auraData1.displayName < auraData2.displayName
                end
            end
    )

    ---- Build the aura import elements
    --local parent = SAP.updateWindow
    --
    --for _, element in ipairs(auraImportElementPool) do
    --    element:Hide()
    --end
    --
    ---- AddOn element
    --if addOnVersionsBehind > 0 then
    --    local auraImportFrame = auraImportElementPool[1] or SAP:CreateAuraImportElement(parent)
    --
    --    auraImportFrame:SetDisplayName("AuraUpdater")
    --    auraImportFrame:SetVersionsBehind(addOnVersionsBehind)
    --    auraImportFrame:SetRequiresAddOnUpdate(true)
    --
    --    auraImportFrame:Show()
    --    auraImportFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", spacing, -spacing)
    --    auraImportFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -spacing, -spacing)
    --
    --    auraImportElementPool[1] = auraImportFrame
    --end
    --
    ---- Aura elements
    --for index, auraData in ipairs(aurasToUpdate) do
    --    -- If the addon requires an update, the first element indicates that
    --    -- Aura updates should use subsequent elements
    --    local i = addOnVersionsBehind > 0 and index + 1 or index
    --    local auraImportFrame = auraImportElementPool[i] or SAP:CreateAuraImportElement(parent)
    --
    --    auraImportFrame:SetDisplayName(auraData.displayName)
    --    auraImportFrame:SetVersionsBehind(auraData.highestSeenVersion - auraData.installedVersion)
    --    auraImportFrame:SetRequiresAddOnUpdate(auraData.highestSeenVersion > auraData.importedVersion)
    --
    --    auraImportFrame:Show()
    --    auraImportFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", spacing, -(i - 1) * (auraImportFrame.height + spacing) - spacing)
    --    auraImportFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -spacing, -(i - 1) * (auraImportFrame.height + spacing) - spacing)
    --
    --    auraImportElementPool[i] = auraImportFrame
    --end

    SAP.upToDate = addOnVersionsBehind <= 0 and next(aurasToUpdate) == nil
    --allAurasUpdatedText:SetShown(SAP.upToDate)

    SAP:UpdateMinimapIconVisibility()
end

function SAP:QueueUpdate()
    if updateQueued then return end

    local timeSinceLastUpdate = GetTime() - lastUpdate

    if timeSinceLastUpdate > 1 then
        BuildAuraImportElements()
    else
        updateQueued = true

        C_Timer.After(1 - timeSinceLastUpdate, BuildAuraImportElements)
    end
end

local function RequestVersions(chatType)
    AceComm:SendCommMessage("AU_Request", " ", chatType or "GUILD")
end

UpdateVersionsForUnit = function(versionsTable, unit)
    local shouldFullRebuildAura = false
    local shouldFullRebuildOther = false
    local GUID = UnitGUID(unit)

    if not GUID then return end

    -- Check addon version
    local addOnVersion = versionsTable.addOn
    local highestSeenAddOnVersion = SAP.highestSeenVersionsTable.addOn or 0

    if not highestSeenAddOnVersion or highestSeenAddOnVersion < addOnVersion then
        SAP.highestSeenVersionsTable.addOn = addOnVersion

        shouldFullRebuildAura = true
    end

    -- Check aura versions
    for displayName, version in pairs(versionsTable.auras or {}) do
        local highestSeenVersion = SAP.highestSeenVersionsTable.auras[displayName]

        if highestSeenVersion and highestSeenVersion < version then
            SAP.highestSeenVersionsTable.auras[displayName] = version

            shouldFullRebuildAura = true
        end
    end


    SAP:UpdateVersionsTableForGUID(GUID, versionsTable)

    --if shouldFullRebuildAura then
    --    SAP:QueueUpdate()
    --
    --    SAP.auraChecker:RebuildAllCheckElements()
    --else
    --    SAP.auraChecker:UpdateCheckElementForUnit(unit, versionsTable)
    --end
    --
    --if shouldFullRebuildOther then
    --    SAP.otherChecker:RebuildAllCheckElements()
    --else
    --    SAP.otherChecker:UpdateCheckElementForUnit(unit, versionsTable)
    --end
end


function SAP:InitializeSAP_Updater()

    SAP.highestSeenVersionsTable = {
        addOn = tonumber(C_AddOns.GetAddOnMetadata(addOnName, "Version")),
        auras = {}
    }

    playerVersionsTable = {
        addOn = tonumber(C_AddOns.GetAddOnMetadata(addOnName, "Version")),
        auras = {},
        ignores = {},
        nickname = SAPSaved.nickname
    }

    for displayName, auraData in pairs(SAPSaved.WeakAuras) do
        auraUIDs[auraData.d.uid] = true
        SAP.highestSeenVersionsTable.auras[displayName] = auraData.d.version
    end

    if WeakAuras and WeakAurasSaved and WeakAurasSaved.displays then
        for id, auraData in pairs(WeakAurasSaved.displays) do
            UIDToID[auraData.uid] = id
        end

        hooksecurefunc(
                WeakAuras,
                "Add",
                function(data)
                    local uid = data.uid

                    if uid then
                        UIDToID[uid] = data.id
                    end
                end
        )

        hooksecurefunc(
                WeakAuras,
                "Rename",
                function(data, newID)
                    local uid = data.uid

                    if uid then
                        UIDToID[uid] = newID
                    end
                end
        )

        hooksecurefunc(
                WeakAuras,
                "Delete",
                function(data)
                    local uid = data.uid

                    if uid then
                        UIDToID[uid] = nil

                        if auraUIDs[uid] then
                            SAP:OnUpdateAura()
                        end
                    end
                end
        )
    end

    SerializeVersionsTable()

    SAP:QueueUpdate()

    -- For some reason the minimap icon doesn't hide if this code runs on the same frame it's being created
    -- In other words, if all auras are up to date, and the user hides the minimap icon, it doesn't hide on log (or reload)
    C_Timer.After(0, function() SAP:UpdateMinimapIconVisibility() end)
end

function SAP:UpdateMinimapIconVisibility()
    if SAP.upToDate then
        if SAPSaved.Settings["Minimap"] == false then
            LDBIcon:Hide("SAP Raid")
        else
            LDBIcon:Show("SAP Raid")
        end

        SAP.LDB.icon = [[Interface\Addons\SAP_Raid\Media\Images\S.tga]]
    else
        LDBIcon:Show("SAP Raid")

        SAP.LDB.icon = [[Interface\Addons\SAP_Raid\Media\Images\S_old.tga]]
    end
end

local function OnEvent(_, event)
    if event == "GROUP_ROSTER_UPDATE" then
        --LUP.auraChecker:RemoveCheckElementsForInvalidUnits()
        --LUP.auraChecker:AddCheckElementsForNewUnits()
        --
        --LUP.otherChecker:RemoveCheckElementsForInvalidUnits()
        --LUP.otherChecker:AddCheckElementsForNewUnits()
        --
        --if UpdateIgnoredPlayers() then
        --    SerializeVersionsTable()
        --    BroadcastVersions()
        --end
    elseif event == "GROUP_JOINED" then

    elseif event == "PLAYER_ENTERING_WORLD" then
        local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
        --
        --RequestVersions(chatType)
        --RequestVersions() -- GUILD


        UpdateVersionsForUnit(playerVersionsTable, "player")
    elseif event == "IGNORELIST_UPDATE" then

    elseif event == "READY_CHECK" then

    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("GROUP_JOINED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("IGNORELIST_UPDATE")
f:RegisterEvent("READY_CHECK")
f:SetScript("OnEvent", OnEvent)