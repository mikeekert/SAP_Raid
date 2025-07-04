local addOnName, SAP = ...

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")
local LDBIcon = LibStub("LibDBIcon-1.0")
local AceComm = LibStub("AceComm-3.0")

local updatePopupWindow

local serializedTable
local spacing = 4
local lastUpdate = 0
local updateQueued = false

local mrtUpdateTimer, nicknameUpdateTimer

local auraImportElementPool = {}
local UIDToID = {} -- Installed aura UIDs to ID (ID is required for WeakAuras.GetData call)
local auraUIDs = {} -- UIDs of AuraUpdater auras
local guidToVersionsTable = {}

local allAurasUpdatedText
local playerVersionsTable -- Table containing all the version information. Serialized before sent to others. Used as-is for displaying our own versions.
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


function SAP:InitializeAuraUpdater()
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

    if MRTNote and MRTNote.text then
        hooksecurefunc(
                MRTNote.text,
                "SetText",
                function()
                    if mrtUpdateTimer and not mrtUpdateTimer:IsCancelled() then
                        mrtUpdateTimer:Cancel()
                    end

                    mrtUpdateTimer = C_Timer.NewTimer(
                            3,
                            function()
                                local shouldBroadcast = UpdateMRTNoteHash()

                                if shouldBroadcast then
                                    SerializeVersionsTable()
                                    BroadcastVersions()
                                end
                            end
                    )
                end
        )
    end

    SerializeVersionsTable()

    SAP:QueueUpdate()

    -- For some reason the minimap icon doesn't hide if this code runs on the same frame it's being created
    -- In other words, if all auras are up to date, and the user hides the minimap icon, it doesn't hide on log (or reload)
    C_Timer.After(0, function() SAP:UpdateMinimapIconVisibility() end)
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


function SAP:UpdateMinimapIconVisibility()
    if SAP.upToDate then
        if SAPUpdaterSaved.settings.hideMinimapIcon then
            LDBIcon:Hide("SAP Updater")
        else
            LDBIcon:Show("SAP Updater")
        end

        SAP.LDB.icon = [[Interface\Addons\SAP_Raid\Media\Images\S.tga]]
    else
        LDBIcon:Show("SAP Updater")

        SAP.LDB.icon = [[Interface\Addons\SAP_Raid\Media\Images\S_old.tga]]
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
        local auraData = SAPUpdaterSaved.WeakAuras[displayName]
        local uid = auraData and auraData.d.uid
        local importedVersion = auraData and auraData.d.liquidVersion or 0
        local installedAuraID = uid and UIDToID[uid]
        local installedVersion = installedAuraID and WeakAuras.GetData(installedAuraID).liquidVersion or 0

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

    -- Build the aura import elements
    local parent = SAP.updateWindow

    for _, element in ipairs(auraImportElementPool) do
        element:Hide()
    end

    -- AddOn element
    if addOnVersionsBehind > 0 then
        local auraImportFrame = auraImportElementPool[1] or SAP:CreateAuraImportElement(parent)

        auraImportFrame:SetDisplayName("AuraUpdater")
        auraImportFrame:SetVersionsBehind(addOnVersionsBehind)
        auraImportFrame:SetRequiresAddOnUpdate(true)

        auraImportFrame:Show()
        auraImportFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", spacing, -spacing)
        auraImportFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -spacing, -spacing)

        auraImportElementPool[1] = auraImportFrame
    end

    -- Aura elements
    for index, auraData in ipairs(aurasToUpdate) do
        -- If the addon requires an update, the first element indicates that
        -- Aura updates should use subsequent elements
        local i = addOnVersionsBehind > 0 and index + 1 or index
        local auraImportFrame = auraImportElementPool[i] or SAP:CreateAuraImportElement(parent)

        auraImportFrame:SetDisplayName(auraData.displayName)
        auraImportFrame:SetVersionsBehind(auraData.highestSeenVersion - auraData.installedVersion)
        auraImportFrame:SetRequiresAddOnUpdate(auraData.highestSeenVersion > auraData.importedVersion)

        auraImportFrame:Show()
        auraImportFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", spacing, -(i - 1) * (auraImportFrame.height + spacing) - spacing)
        auraImportFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -spacing, -(i - 1) * (auraImportFrame.height + spacing) - spacing)

        auraImportElementPool[i] = auraImportFrame
    end

    SAP.upToDate = addOnVersionsBehind <= 0 and next(aurasToUpdate) == nil

    allAurasUpdatedText:SetShown(SAP.upToDate)

    SAP:UpdateMinimapIconVisibility()
end
