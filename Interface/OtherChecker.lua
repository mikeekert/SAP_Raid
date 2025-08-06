local _, LUP = ...

LUP.otherChecker = {}

-- Element variables
local nameFrameWidth = 150
local versionFramePaddingLeft = 10
local versionFramePaddingRight = 40
local elementHeight = 32

-- Version tables for GUIDs, used for comparison against their new table
-- Updates are only done if something changed
local cachedVersionsTables = {}

local scrollFrame, scrollBar, dataProvider, scrollView, labelFrame
local labels = {} -- Label fontstrings
local labelTitles = {
    "MRT note",
    "Ignore list",
    "RCLC"
}

LUP.highestSeenRCLCVersion = "0.0.0"
local mrtNoteHash

-- Compares two RCLC TOC versions
-- Returns -1 if version1 is higher, 0 if they are equal, 1 if version2 is higher
function LUP:CompareRCLCVersions(version1, version2)
    local major1, minor1, patch1 = version1:match("(%d+).(%d+).(%d+)")
    local major2, minor2, patch2 = version2:match("(%d+).(%d+).(%d+)")

    if major1 ~= major2 then
        major1 = tonumber(major1)
        major2 = tonumber(major2)

        return major1 > major2 and -1 or 1
    elseif minor1 ~= minor2 then
        minor1 = tonumber(minor1)
        minor2 = tonumber(minor2)

        return minor1 > minor2 and -1 or 1
    elseif patch1 ~= patch2 then
        patch1 = tonumber(patch1)
        patch2 = tonumber(patch2)

        return patch1 > patch2 and -1 or 1
    else
        return 0
    end
end

-- Checks a unit's new version table against their known one
-- Returns true if something changed
local function ShouldUpdate(GUID, newVersionsTable)
    local oldVersionsTable = cachedVersionsTables[GUID]

    if not oldVersionsTable then return true end
    if not newVersionsTable then return false end

    return not tCompare(oldVersionsTable, newVersionsTable, 3)
end

local function PositionLabels(_, width)
    local firstVersionFrameX = nameFrameWidth + versionFramePaddingLeft
    local versionFramesTotalWidth = width - firstVersionFrameX - versionFramePaddingRight - elementHeight
    local versionFrameSpacing = versionFramesTotalWidth / (#labels - 1)

    for i, versionFrame in ipairs(labels) do
        versionFrame:SetPoint("BOTTOM", labelFrame, "BOTTOMLEFT", firstVersionFrameX + (i - 1) * versionFrameSpacing + 0.5 * elementHeight, 0)
    end
end

local function BuildLabels()
    if not labelFrame then
        labelFrame = CreateFrame("Frame", nil, LUP.otherCheckWindow)
        labelFrame:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 0, 4)
        labelFrame:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 0, 4)
        labelFrame:SetHeight(24)

        labelFrame:SetScript("OnSizeChanged", PositionLabels)
    end

    for i, displayName in ipairs(labelTitles) do
        if not labels[i] then
            labels[i] = labelFrame:CreateFontString(nil, "OVERLAY")

            labels[i]:SetFontObject(LiquidFont15)
        end

        labels[i]:SetText(string.format("|cff%s%s|r", LUP.gs.visual.colorStrings.white, displayName))
    end

    PositionLabels(nil, scrollFrame:GetWidth())
end

function LUP.otherChecker:UpdateCheckElementForUnit(unit, versionsTable, force)
    local GUID = UnitGUID(unit)

    if not GUID then return end
    if not (force or ShouldUpdate(GUID, versionsTable)) then return end

    -- If this is the player's version table, and the mrt note hash is different, rebuild all elements (not just the player's)
    if UnitIsUnit(unit, "player") and versionsTable and versionsTable.mrtNoteHash and (not mrtNoteHash or mrtNoteHash ~= versionsTable.mrtNoteHash) then
        mrtNoteHash = versionsTable.mrtNoteHash
        LUP.otherChecker:RebuildAllCheckElements()

        return
    end

    cachedVersionsTables[GUID] = CopyTable(versionsTable or {})

    -- If this unit already has an element, remove it
    dataProvider:RemoveByPredicate(
        function(elementData)
            return elementData.GUID == GUID
        end
    )

    -- Create new data
    local _, class, _, _, _, name = GetPlayerInfoByGUID(GUID)

    if not (class and name) then return end

    name = SAP_Raid_Updater:GetNickname(unit) or name -- If this unit has a nickname, use that instead

    local colorStr = RAID_CLASS_COLORS[class].colorStr
    local coloredName = string.format("|c%s%s|r", colorStr, name)

    local data = {
        GUID = GUID,
        unit = GetUnitName(unit, true), -- Used for checking whether this unit still exists (that's why we use name)
        name = name, -- Used for sorting
        coloredName = coloredName
    }

    if versionsTable then
        data.sapUpdater = true -- Whether AuraUpdater is active
        data.mrtNoteHash = versionsTable.mrtNoteHash
        data.ignores = versionsTable.ignores
        data.RCLC = versionsTable.RCLC
    end
    
    dataProvider:Insert(data)
end

function LUP.otherChecker:AddCheckElementsForNewUnits()
    for unit in LUP:IterateGroupMembers() do
        local GUID = UnitGUID(unit)

        if not LUP:GetVersionsTableForGUID(GUID) then
            LUP.otherChecker:UpdateCheckElementForUnit(unit)
        end
    end
end

-- Iterates existing elements, and removes those whose units are no longer in our group
function LUP.otherChecker:RemoveCheckElementsForInvalidUnits()
    for i, data in dataProvider:ReverseEnumerate() do
        local unit = data.unit

        if not UnitExists(unit) then
            LUP:UpdateVersionsTableForGUID(data.GUID, nil)
            cachedVersionsTables[data.GUID] = nil

            dataProvider:RemoveIndex(i)
        end
    end
end

function LUP.otherChecker:RebuildAllCheckElements()
    for unit in LUP:IterateGroupMembers() do
        local GUID = UnitGUID(unit)
        local versionsTable = LUP:GetVersionsTableForGUID(GUID)

        LUP.otherChecker:UpdateCheckElementForUnit(unit, versionsTable, true)
    end

    BuildLabels()
end

local function CheckElementInitializer(frame, data)
    local versionFrameCount = #labelTitles

    -- Create version frames
    if not frame.versionFrames then frame.versionFrames = {} end

    for i = 1, versionFrameCount do
        local subFrame = frame.versionFrames[i] or CreateFrame("Frame", nil, frame)

        if not subFrame.versionsBehindIcon then
            subFrame.versionsBehindIcon = CreateFrame("Frame", nil, subFrame)
            subFrame.versionsBehindIcon:SetSize(24, 24)
            subFrame.versionsBehindIcon:SetPoint("CENTER", subFrame, "CENTER")

            subFrame.versionsBehindIcon.text = subFrame.versionsBehindIcon:CreateTexture(nil, "BACKGROUND")
            subFrame.versionsBehindIcon.text:SetAllPoints()
        end

        subFrame:SetSize(elementHeight, elementHeight)

        frame.versionFrames[i] = subFrame
    end

    if not frame.coloredName then
        frame.coloredName = frame:CreateFontString(nil, "OVERLAY")

        frame.coloredName:SetFontObject(LiquidFont21)
        frame.coloredName:SetPoint("LEFT", frame, "LEFT", 8, 0)
    end

    frame.coloredName:SetText(string.format("|cff%s%s|r", LUP.gs.visual.colorStrings.white, data.coloredName))

    -- MRT Note
    local versionFrame = frame.versionFrames[1]

    if not data.mrtNoteHash then
        if data.sapUpdater then
            versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

            LUP.LiquidUI:AddTooltip(
                versionFrame,
                "No information about MRT note received.|n|nUser is running an outdated Addon version, or has MRT disabled."
            )
        else
            versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

            LUP.LiquidUI:AddTooltip(
                versionFrame,
                "No information about MRT note received.|n|nUser is not running Addon."
            )
        end
    elseif mrtNoteHash == data.mrtNoteHash then
        versionFrame.versionsBehindIcon.text:SetAtlas("common-icon-checkmark")

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            "MRT note is the same as yours."
        )
    else
        versionFrame.versionsBehindIcon.text:SetAtlas("common-icon-redx")

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            "MRT note is different than yours."
        )
    end

    -- Ignore list
    versionFrame = frame.versionFrames[2]

    if not data.ignores then
        if data.sapUpdater then
            versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

            LUP.LiquidUI:AddTooltip(
                versionFrame,
                "No information about ignored players received.|n|nUser is running an outdated Addon version."
            )
        else
            versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

            LUP.LiquidUI:AddTooltip(
                versionFrame,
                "No information about ignored players received.|n|nUser is not running Addon."
            )
        end
    elseif next(data.ignores) then
        versionFrame.versionsBehindIcon.text:SetAtlas("common-icon-redx")

        local ignoredPlayers = ""

        for _, ignoredPlayer in ipairs(data.ignores) do
            ignoredPlayers = string.format("%s|n%s", ignoredPlayers, LUP:ClassColorName(ignoredPlayer))
        end

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            string.format("Players on ignore:%s", ignoredPlayers)
        )
    else
        versionFrame.versionsBehindIcon.text:SetAtlas("common-icon-checkmark")

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            "No group members on ignore."
        )
    end

    -- RCLC
    versionFrame = frame.versionFrames[3]

    if data.oldVersion then
        versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            "No information about RCLC version received.|n|nUser is running an outdated Addon version."
        )
    elseif not data.RCLC then
        if data.sapUpdater then
            versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

            LUP.LiquidUI:AddTooltip(
                versionFrame,
                "No information about RCLC received.|n|nUser is running an outdated Addon version, or has RCLC disabled."
            )
        else
            versionFrame.versionsBehindIcon.text:SetAtlas("QuestTurnin")

            LUP.LiquidUI:AddTooltip(
                versionFrame,
                "No information about RCLC note received.|n|nUser is not running Addon."
            )
        end
    elseif LUP:CompareRCLCVersions(LUP.highestSeenRCLCVersion, data.RCLC) == -1 then
        versionFrame.versionsBehindIcon.text:SetAtlas("common-icon-redx")

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            string.format("User has an outdated RCLC version.|n|nNewest version: %s|n%s's version: %s", LUP.highestSeenRCLCVersion, data.coloredName, data.RCLC)
        )
    else
        versionFrame.versionsBehindIcon.text:SetAtlas("common-icon-checkmark")

        LUP.LiquidUI:AddTooltip(
            versionFrame,
            "RCLC version is up to date."
        )
    end

    if not frame.PositionVersionFrames then
        function frame.PositionVersionFrames(_, width)
            local firstVersionFrameX = nameFrameWidth + versionFramePaddingLeft
            local versionFramesTotalWidth = width - firstVersionFrameX - versionFramePaddingRight - elementHeight
            local versionFrameSpacing = versionFramesTotalWidth / (#labelTitles - 1)

            for i, vFrame in ipairs(frame.versionFrames) do
                vFrame:SetPoint("LEFT", frame, "LEFT", firstVersionFrameX + (i - 1) * versionFrameSpacing, 0)
            end
        end
    end

    frame.PositionVersionFrames(nil, frame:GetWidth())

    frame:SetScript("OnSizechanged", frame.PositionVersionFrames)
end

function LUP:InitializeOtherChecker()
    scrollFrame = CreateFrame("Frame", nil, LUP.otherCheckWindow, "WowScrollBoxList")
    scrollFrame:SetPoint("TOPLEFT", LUP.otherCheckWindow, "TOPLEFT", 4, -32)
    scrollFrame:SetPoint("BOTTOMRIGHT", LUP.otherCheckWindow, "BOTTOMRIGHT", -24, 4)

    scrollBar = CreateFrame("EventFrame", nil, LUP.otherCheckWindow, "MinimalScrollBar")
    scrollBar:SetPoint("TOP", scrollFrame, "TOPRIGHT", 12, 0)
    scrollBar:SetPoint("BOTTOM", scrollFrame, "BOTTOMRIGHT", 12, 16)

    dataProvider = CreateDataProvider()
    scrollView = CreateScrollBoxListLinearView()
    scrollView:SetDataProvider(dataProvider)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollFrame, scrollBar, scrollView)

    scrollView:SetElementExtent(elementHeight)
    scrollView:SetElementInitializer("Frame", CheckElementInitializer)

    dataProvider:SetSortComparator(
        function(data1, data2)
            local noteOK1 = data1.mrtNoteHash and data1.mrtNoteHash == mrtNoteHash
            local noteOK2 = data2.mrtNoteHash and data2.mrtNoteHash == mrtNoteHash

            local ignoresOK1 = data1.ignores and not next(data1.ignores)
            local ignoresOK2 = data2.ignores and not next(data2.ignores)

            local rclcOK1 = data1.RCLC and data1.RCLC == LUP.highestSeenRCLCVersion
            local rclcOK2 = data2.RCLC and data2.RCLC == LUP.highestSeenRCLCVersion

            if noteOK1 ~= noteOK2 then
                return noteOK2
            elseif ignoresOK1 ~= ignoresOK2 then
                return ignoresOK2
            elseif rclcOK1 ~= rclcOK2 then
                return rclcOK2
            else
                return data1.name < data2.name
            end
        end
    )

    -- Border
    local borderColor = LUP.LiquidUI.settings.BORDER_COLOR
    LUP.LiquidUI:AddBorder(scrollFrame)
    scrollFrame:SetBorderColor(borderColor.r, borderColor.g, borderColor.b)

    LUP.otherChecker:RebuildAllCheckElements()
end