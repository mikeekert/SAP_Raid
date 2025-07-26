---@diagnostic disable: undefined-field
local addOnName, LUP = ...

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

function LUP:GetInstalledAuraDataByUID(uid)
    local installedAuraID = UIDToID[uid]
    
    return installedAuraID and WeakAuras.GetData(installedAuraID)
end

function LUP:GetVersionsTableForGUID(GUID)
    return guidToVersionsTable[GUID]
end

function LUP:UpdateVersionsTableForGUID(GUID, versionsTable)
    guidToVersionsTable[GUID] = versionsTable
end

local function BroadcastVersions()
    local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"

    AceComm:SendCommMessage("AU_Versions", serializedTable, "GUILD")
    AceComm:SendCommMessage("AU_Versions", serializedTable, chatType)

    UpdateVersionsForUnit(playerVersionsTable, "player")
end

local function SerializeVersionsTable()
    for displayName, auraData in pairs(SAPUpdaterSaved.WeakAuras) do
        local uid = auraData.d.uid
        local installedAuraID = uid and UIDToID[uid]
        local installedVersion = installedAuraID and WeakAuras.GetData(installedAuraID).sapVersion or 0

        playerVersionsTable.auras[displayName] = installedVersion
    end

    local serialized = LibSerialize:Serialize(playerVersionsTable)
    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)

    serializedTable = encoded

    if not serializedTable then
        LUP:ErrorPrint("could not serialize version table")
    end
end

local function UpdateNickname(nickname)
    nickname = strtrim(nickname)

    if nickname == "" then nickname = nil end

    local oldNickname = playerVersionsTable.nickname

    SAPUpdaterSaved.nickname = nickname
    playerVersionsTable.nickname = nickname

    return oldNickname ~= nickname
end

function LUP:QueueNicknameUpdate(nickname)
    if nicknameUpdateTimer and not nicknameUpdateTimer:IsCancelled() then
        nicknameUpdateTimer:Cancel()
    end

    nicknameUpdateTimer = C_Timer.NewTimer(
        3,
        function()
            local shouldBroadcast = UpdateNickname(nickname)

            if shouldBroadcast then
                SerializeVersionsTable()
                BroadcastVersions()
            end
        end
    )
end

-- Returns true if a new group member was ignored
local function UpdateIgnoredPlayers()
    local foundNew = false
    local newIgnoredNames = {}

    for unit in LUP:IterateGroupMembers() do
        if C_FriendList.IsIgnored(unit) then
            local name = UnitNameUnmodified(unit)

            table.insert(newIgnoredNames, name)
        end
    end

    table.sort(newIgnoredNames)

    if not tCompare(newIgnoredNames, playerVersionsTable.ignores) then
        foundNew = true
    end

    playerVersionsTable.ignores = newIgnoredNames

    return foundNew
end

-- Calculates checksum for the player's public MRT note
-- Original code by Mikk (https://warcraft.wiki.gg/wiki/StringHash)
local function GetMRTNoteHash()
    local text = VMRT and VMRT.Note.Text1

    if not text then return end

    local counter = 1
    local len = string.len(text)

    for i = 1, len, 3 do 
        counter = math.fmod(counter * 8161, 4294967279) + (string.byte(text, i) * 16776193) + ((string.byte(text, i + 1) or (len - i + 256)) * 8372226) + ((string.byte(text, i + 2) or (len - i + 256)) * 3932164)
    end

    return math.fmod(counter, 4294967291)
end

-- Returns true if a new MRT note was found
local function UpdateMRTNoteHash()
    if not C_AddOns.IsAddOnLoaded("MRT") then return end

    local foundNew = false
    local hash = GetMRTNoteHash()

    if playerVersionsTable.mrtNoteHash ~= hash then
        foundNew = true
    end

    playerVersionsTable.mrtNoteHash = hash

    return foundNew
end

function LUP:UpdateMinimapIconVisibility()
    if LUP.upToDate then
        if SAPUpdaterSaved.settings.hideMinimapIcon then
            LDBIcon:Hide("Aura Updater")
        else
            LDBIcon:Show("Aura Updater")
        end

        LUP.LDB.icon = [[Interface\Addons\SAP_Raid_Updater\Media\Textures\minimap_logo.tga]]
    else
        LDBIcon:Show("Aura Updater")

        LUP.LDB.icon = [[Interface\Addons\SAP_Raid_Updater\Media\Textures\minimap_logo_red.tga]]
    end
end

local function BuildAuraImportElements()
    lastUpdate = GetTime()
    updateQueued = false

    -- Check if addon requires an update
    local addOnVersionsBehind = LUP.highestSeenVersionsTable.addOn - playerVersionsTable.addOn

    -- Check which auras require updates
    local aurasToUpdate = {}

    for displayName, highestSeenVersion in pairs(LUP.highestSeenVersionsTable.auras) do
        local auraData = SAPUpdaterSaved.WeakAuras[displayName]
        local uid = auraData and auraData.d.uid
        local importedVersion = auraData and auraData.d.sapVersion or 0
        local installedAuraID = uid and UIDToID[uid]
        local installedVersion = installedAuraID and WeakAuras.GetData(installedAuraID).sapVersion or 0

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
    local parent = LUP.updateWindow

    for _, element in ipairs(auraImportElementPool) do
        element:Hide()
    end

    -- AddOn element
    if addOnVersionsBehind > 0 then
        local auraImportFrame = auraImportElementPool[1] or LUP:CreateAuraImportElement(parent)

        auraImportFrame:SetDisplayName("SAP_Raid_Updater")
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
        local auraImportFrame = auraImportElementPool[i] or LUP:CreateAuraImportElement(parent)

        auraImportFrame:SetDisplayName(auraData.displayName)
        auraImportFrame:SetVersionsBehind(auraData.highestSeenVersion - auraData.installedVersion)
        auraImportFrame:SetRequiresAddOnUpdate(auraData.highestSeenVersion > auraData.importedVersion)

        auraImportFrame:Show()
        auraImportFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", spacing, -(i - 1) * (auraImportFrame.height + spacing) - spacing)
        auraImportFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -spacing, -(i - 1) * (auraImportFrame.height + spacing) - spacing)
        
        auraImportElementPool[i] = auraImportFrame
    end

    LUP.upToDate = addOnVersionsBehind <= 0 and next(aurasToUpdate) == nil

    allAurasUpdatedText:SetShown(LUP.upToDate)

    LUP:UpdateMinimapIconVisibility()
end

function LUP:QueueUpdate()
    if updateQueued then return end

    -- Don't update more than once per second
    -- This is mostly to prevent the update function from running when a large number of auras get added simultaneously
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
    local highestSeenAddOnVersion = LUP.highestSeenVersionsTable.addOn

    if not highestSeenAddOnVersion or highestSeenAddOnVersion < addOnVersion then
        LUP.highestSeenVersionsTable.addOn = addOnVersion

        shouldFullRebuildAura = true
    end

    -- Check aura versions
    for displayName, version in pairs(versionsTable.auras or {}) do
        local highestSeenVersion = LUP.highestSeenVersionsTable.auras[displayName]

        if highestSeenVersion and highestSeenVersion < version then
            LUP.highestSeenVersionsTable.auras[displayName] = version

            shouldFullRebuildAura = true
        end
    end

    -- Check RCLC version
    local RCLCVersion = versionsTable.RCLC

    if RCLCVersion then
        if not LUP.highestSeenRCLCVersion or LUP:CompareRCLCVersions(LUP.highestSeenRCLCVersion, RCLCVersion) == 1 then
            LUP.highestSeenRCLCVersion = RCLCVersion

            shouldFullRebuildOther = true
        end
    end

    -- Update nickname if necessary
    local oldNickname = AuraUpdater:GetNickname(unit)
    local nickname = versionsTable.nickname

    if oldNickname ~= nickname then
        LUP:UpdateNicknameForUnit(unit, nickname)
    end

    LUP:UpdateVersionsTableForGUID(GUID, versionsTable)

    if shouldFullRebuildAura then
        LUP:QueueUpdate()

        LUP.auraChecker:RebuildAllCheckElements()
    else
        LUP.auraChecker:UpdateCheckElementForUnit(unit, versionsTable)
    end

    if shouldFullRebuildOther then
        LUP.otherChecker:RebuildAllCheckElements()
    else
        LUP.otherChecker:UpdateCheckElementForUnit(unit, versionsTable)
    end
end

local function ReceiveVersions(_, payload, _, sender)
    if UnitIsUnit(sender, "player") then return end -- We handle our own versions directly, not through addon messages

    local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)

    if not decoded then
        LUP:ErrorPrint(string.format("could not decode version table received from %s", sender))

        return
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded)

    if not decoded then
        LUP:ErrorPrint(string.format("could not decompress version table received from %s", sender))

        return
    end

    local success, versionsTable = LibSerialize:Deserialize(decompressed)

    if not success then
        LUP:ErrorPrint(string.format("could not deserialize version table received from %s", sender))

        return
    end

    -- If the auras subtable doesn't exist, that means the user still has an old AuraUpdater version
    -- Convert it to the new format
    if not versionsTable.auras then
        local newVersionsTable = {
            addOn = versionsTable["SAP_Raid_Updater"],
            auras = {}
        }

        for displayName, version in pairs(versionsTable) do
            if displayName ~= "SAP_Raid_Updater" then
                newVersionsTable.auras[displayName] = version
            end
        end

        versionsTable = newVersionsTable
    end

    UpdateVersionsForUnit(versionsTable, sender)
end

-- Called before updating an aura
-- Checks if the user already has the aura installed
-- If so, apply "load: never" settings from the existing aura (group) to the aura being imported
-- If "forceenable" is included in the description of an aura, always uncheck "load: never"
function LUP:ApplyLoadSettings(auraData, installedAuraData)
    if installedAuraData and installedAuraData.load and not (installedAuraData.regionType == "group" or installedAuraData.regionType == "dynamicgroup") then
        auraData.load.use_never = installedAuraData.load.use_never

        if auraData.desc and type(auraData.desc) == "string" and auraData.desc:match("forceenable") then
            auraData.load.use_never = nil
        end
    end
end

-- Similar to ApplyLoadSettings: preserves sound settings in action tab
function LUP:ApplySoundSettings(auraData, installedAuraData)
    if not (installedAuraData and installedAuraData.actions) then return end

    local start = installedAuraData.actions.start
    local finish = installedAuraData.actions.finish

    -- Preserve on show sounds
    if start then
        if not auraData.actions.start then auraData.actions.start = {} end

        auraData.actions.start.do_sound = start.do_sound
        auraData.actions.start.do_loop = start.do_loop
        auraData.actions.start.sound = start.sound
        auraData.actions.start.sound_channel = start.sound_channel
        auraData.actions.start.sound_repeat = start.sound_repeat
    end

    -- Preserve on hide sounds
    if finish then
        if not auraData.actions.finish then auraData.actions.finish = {} end

        auraData.actions.finish.do_sound = finish.do_sound
        auraData.actions.finish.do_sound_fade = finish.do_sound_fade
        auraData.actions.finish.sound = finish.sound
        auraData.actions.finish.sound_channel = finish.sound_channel
        auraData.actions.finish.stop_sound = finish.stop_sound
        auraData.actions.finish.stop_sound_fade = finish.stop_sound_fade
    end
end

-- Similar to the above: miscellaneous auras do not have an anchor associated with them
-- We don't want users to have to uncheck "group arrangement", so apply position settings of installed miscellaneous auras
-- We only do this for direct children of miscellaneous groups, not for children of children etc.
function LUP:ApplyMiscellaneousPositionSettings(groupAuraData)
    if not groupAuraData.c then return end

    -- Collect names of miscellaneous auras
    local miscellaneousAuraNames = {}

    for _, childAuraData in pairs(groupAuraData.c) do
        local isGroup = childAuraData.regionType == "group"
        local isMiscellaneousGroup = isGroup and childAuraData.groupIcon == "map-icon-ignored-bluequestion" and childAuraData.id:match("Miscellaneous")
        local miscellaneousGroupChildren = isMiscellaneousGroup and childAuraData.controlledChildren

        if miscellaneousGroupChildren then
            for _, auraName in ipairs(miscellaneousGroupChildren) do
                miscellaneousAuraNames[auraName] = true
            end
        end
    end

    -- Fill UID to auraData table for miscellaneous auras
    -- We want to use UIDs over IDs, since players may have renamed auras
    local uidToAuraData = {}

    for _, childAuraData in pairs(groupAuraData.c) do
        local auraName = childAuraData.id

        if miscellaneousAuraNames[auraName] then
            uidToAuraData[childAuraData.uid] = childAuraData
        end
    end

    -- Apply position settings
    for uid, auraData in pairs(uidToAuraData) do
        local installedAuraData = LUP:GetInstalledAuraDataByUID(uid)

        if installedAuraData then
            local xOffset = installedAuraData.xOffset
            local yOffset = installedAuraData.yOffset

            if xOffset and auraData.xOffset and yOffset and auraData.yOffset then
                auraData.xOffset = xOffset
                auraData.yOffset = yOffset
            end
        end
    end
end

-- Force updates the on init code, even if the user unchecked "actions" when importing
-- Users often do this to preserve their sounds/glow colors/etc. but it can break assignment functionality
function LUP:ForceUpdateOnInit(customOnInit)
    for id, customCode in pairs(customOnInit) do
        local data = WeakAuras.GetData(id)

        if data and data.actions and data.actions.init then
            data.actions.init.do_custom = true
            data.actions.init.custom = customCode
        end
    end
end

-- Called on callback from WeakAuras.Import (in AuraImportElement)
function LUP:OnUpdateAura()
    SerializeVersionsTable()
    
    LUP:QueueUpdate()

    BroadcastVersions()
end

local function UpdateRCLCVersion()
	local version = C_AddOns.GetAddOnMetadata("RCLootCouncil", "Version")

	playerVersionsTable.RCLC = version

	LUP.highestSeenRCLCVersion = version
end

local function HookWeakAuras()
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
                        LUP:OnUpdateAura()
                    end
                end
            end
        )
    end
end

local function HookMRT()
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
end

function LUP:InitializeAuraUpdater()
    LUP.highestSeenVersionsTable = {
        addOn = tonumber(C_AddOns.GetAddOnMetadata(addOnName, "Version")),
        auras = {}
    }

    playerVersionsTable = {
        addOn = tonumber(C_AddOns.GetAddOnMetadata(addOnName, "Version")),
        auras = {},
        ignores = {},
        nickname = SAPUpdaterSaved.nickname
    }

    UpdateIgnoredPlayers()
    UpdateMRTNoteHash()

    if C_AddOns.IsAddOnLoaded("RCLootCouncil") then
        UpdateRCLCVersion()
    end
    
    AceComm:RegisterComm("AU_Request", BroadcastVersions)
    AceComm:RegisterComm("AU_Versions", ReceiveVersions)

    for displayName, auraData in pairs(SAPUpdaterSaved.WeakAuras) do
        auraUIDs[auraData.d.uid] = true

        LUP.highestSeenVersionsTable.auras[displayName] = auraData.d.sapVersion
    end

    if C_AddOns.IsAddOnLoaded("WeakAuras") then
        HookWeakAuras()
    end

    if C_AddOns.IsAddOnLoaded("MRT") then
        HookMRT()
    end

    allAurasUpdatedText = LUP.updateWindow:CreateFontString(nil, "OVERLAY")

    allAurasUpdatedText:SetFontObject(LiquidFont21)
    allAurasUpdatedText:SetPoint("CENTER", LUP.updateWindow, "CENTER")
    allAurasUpdatedText:SetText(string.format("|cff%sAll auras up to date!|r", LUP.gs.visual.colorStrings.green))

    SerializeVersionsTable()

    LUP:QueueUpdate()

    -- For some reason the minimap icon doesn't hide if this code runs on the same frame it's being created
    -- In other words, if all auras are up to date, and the user hides the minimap icon, it doesn't hide on log (or reload)
    C_Timer.After(0, function() LUP:UpdateMinimapIconVisibility() end)
end

local function OnEvent(_, event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        LUP.auraChecker:RemoveCheckElementsForInvalidUnits()
        LUP.auraChecker:AddCheckElementsForNewUnits()

        LUP.otherChecker:RemoveCheckElementsForInvalidUnits()
        LUP.otherChecker:AddCheckElementsForNewUnits()

        if UpdateIgnoredPlayers() then
            SerializeVersionsTable()
            BroadcastVersions()
        end
    elseif event == "GROUP_JOINED" then
        local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"

        RequestVersions(chatType)
    elseif event == "PLAYER_ENTERING_WORLD" then
        local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"

        RequestVersions(chatType)
        RequestVersions() -- GUILD

        UpdateVersionsForUnit(playerVersionsTable, "player") -- Just in case the player is not in a guild/group
    elseif event == "IGNORELIST_UPDATE" then
        if UpdateIgnoredPlayers() then
            SerializeVersionsTable()
            BroadcastVersions()
        end
    elseif event == "READY_CHECK" then
        if not updatePopupWindow then
            updatePopupWindow = LUP:CreatePopupWindowWithButton()

            updatePopupWindow:SetHideOnClickOutside(false)
            updatePopupWindow:SetText(string.format("|cff%sWarning|r|n|nYour addon/auras are outdated!", LUP.gs.visual.colorStrings.red))
            updatePopupWindow:SetButtonText(string.format("|cff%sOK|r", LUP.gs.visual.colorStrings.green))
            updatePopupWindow:AddCheckButton("Don't show again")
            updatePopupWindow:SetButtonOnClick(
                function(dontShowAgain)
                    LUP:SetNotifyOnReadyCheck(not dontShowAgain)

                    updatePopupWindow.checkButton:SetChecked(false)
                end
            )
        end

        if SAPUpdaterSaved.settings.readyCheckPopup and not LUP.upToDate then
            updatePopupWindow:Pop()
            updatePopupWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
        end
    elseif event == "ADDON_LOADED" then
		local name = ...
	
		if name == "RCLootCouncil" then
			UpdateRCLCVersion()
		elseif name == "WeakAuras" then
			HookWeakAuras()
		elseif name == "MRT" then
			HookMRT()
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("GROUP_JOINED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("IGNORELIST_UPDATE")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)