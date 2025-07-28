local SharedMedia = LibStub("LibSharedMedia-3.0")

SAP_Raid_Updater = {}

local anchorSettings = {}
local updateAnchorFunctions = {}
local applyAnchorFunctions = {}

-- Number of clones that show in preview mode (with options open)
-- Used for correcting aura positions during preview
local previewCounts = {
    bars = 3,
    specialBars = 1,
    lists = 10,
    bigIcons = 1,
    icons = 3,
    texts = 1,
}

local function PositionAuras(settings, newPositions, activeRegions)
    local nextPosition = WeakAuras.IsOptionsOpen() and settings.optionsOffsets and CopyTable(settings.optionsOffsets) or {0, 0}
    local limit = settings.limit or #activeRegions
    local directionX = settings.grow == "RIGHT" and 1 or settings.grow == "LEFT" and -1 or 0
    local directionY = settings.grow == "UP" and 1 or settings.grow == "DOWN" and -1 or 0

    for regionCount, regionData in ipairs(activeRegions) do
        if regionCount > limit then
            newPositions[regionCount] = {0, 0, false}
        else
            local skipPosition = regionData.region.state.skipPosition

            newPositions[regionCount] = nextPosition

            if not skipPosition then
                local width = settings.width or regionData.region.width
                local height = settings.height or regionData.region.height

                nextPosition = {
                    nextPosition[1] + directionX * (width + settings.space),
                    nextPosition[2] + directionY * (height + settings.space)
                }
            end
        end
    end
end

local function ResizeAura(settings, region)
    region:SetRegionWidth(settings.width)
    region:SetRegionHeight(settings.height)
end

local function ApplySubtextSettings(settings, region)
    local subtextCount = 0

    for _, subRegion in ipairs(region.subRegions) do
        if subRegion.type == "subtext" then
            subtextCount = subtextCount + 1

            local subtextSettings = settings.subtexts[subtextCount]

            if not subtextSettings then break end

            subRegion.text:SetFont(subtextSettings.fontPath, subtextSettings.size, subtextSettings.type)
            subRegion.text:SetShadowColor(unpack(subtextSettings.shadowColor))
            subRegion.text:SetShadowOffset(subtextSettings.shadowXOffset, subtextSettings.shadowYOffset)
        end
    end
end

local function ApplyBarTexture(settings, region)
    region.texture = settings.texture
    region.textureInput = settings.textureInput
    region.textureSource = settings.textureSource

    region:UpdateStatusBarTexture()
end

local function ResizeTicks(settings, region)
    for _, subRegion in ipairs(region.subRegions) do
        if subRegion.type == "subtick" then
            subRegion:SetAutomaticLength(false)
            subRegion:SetTickLength(settings.height)
        end
    end
end

local function ResizeSpark(settings, region)
    region:SetSparkHeight(settings.height)
end

-- Generic functions
-- Bars
local function GetBarSettings(groupName, auraName, previewCount)
    local groupData = WeakAuras.GetData(groupName)
    local auraData = WeakAuras.GetData(auraName)

    if not (groupData and auraData) then return end

    local settings = {
        subtexts = {}
    }

    settings.grow = groupData.grow
    settings.limit = groupData.useLimit and groupData.limit or 100
    settings.space = groupData.space

    settings.width = auraData.width
    settings.height = auraData.height

    settings.texture = auraData.texture
    settings.textureInput = auraData.textureInput
    settings.textureSource = auraData.textureSource

    for _, subRegion in ipairs(auraData.subRegions) do
        if subRegion.type == "subtext" then
            table.insert(
                settings.subtexts,
                {
                    fontPath = SharedMedia:Fetch("font", subRegion.text_font),
                    size = subRegion.text_fontSize,
                    type = subRegion.text_fontType,
                    shadowColor = subRegion.text_shadowColor,
                    shadowXOffset = subRegion.text_shadowXOffset,
                    shadowYOffset = subRegion.text_shadowYOffset
                }
            )
        end
    end

    -- Calculate options offsets
    settings.optionsOffsets = {0, 0}

    if settings.grow == "UP" then
        settings.optionsOffsets[2] = -(previewCount - 1) * (settings.height + settings.space)
    end

    return settings
end

local function ApplyBarSettings(settings, newPositions, activeRegions)
    if not settings then return end

    PositionAuras(settings, newPositions, activeRegions)

    for _, regionData in ipairs(activeRegions) do
        local region = regionData.region

        if region.regionType == "aurabar" then
            ResizeAura(settings, region)
            ApplyBarTexture(settings, region)
            ApplySubtextSettings(settings, region)
            ResizeTicks(settings, region)
            ResizeSpark(settings, region)
        end
    end
end

-- Icons
local function GetIconSettings(groupName, auraName, previewCount)
    local groupData = WeakAuras.GetData(groupName)
    local auraData = WeakAuras.GetData(auraName)

    if not (groupData and auraData) then return end

    local settings = {
        subtexts = {}
    }

    settings.grow = groupData.grow
    settings.limit = groupData.useLimit and groupData.limit or 100
    settings.space = groupData.space

    settings.width = auraData.width
    settings.height = auraData.height

    for _, subRegion in ipairs(auraData.subRegions) do
        if subRegion.type == "subtext" then
            table.insert(
                settings.subtexts,
                {
                    fontPath = SharedMedia:Fetch("font", subRegion.text_font),
                    size = subRegion.text_fontSize,
                    type = subRegion.text_fontType,
                    shadowColor = subRegion.text_shadowColor,
                    shadowXOffset = subRegion.text_shadowXOffset,
                    shadowYOffset = subRegion.text_shadowYOffset
                }
            )
        end
    end

    -- Calculate options offsets
    settings.optionsOffsets = {0, 0}

    if settings.grow == "UP" then
        settings.optionsOffsets[2] = -settings.height - settings.space
    elseif settings.grow == "RIGHT" then
        settings.optionsOffsets[1] = -(previewCount - 1) * (settings.width + settings.space)
    end

    return settings
end

local function ApplyIconSettings(settings, newPositions, activeRegions)
    if not settings then return end

    PositionAuras(settings, newPositions, activeRegions)

    for _, regionData in ipairs(activeRegions) do
        local region = regionData.region

        if region.regionType == "icon" then
            ResizeAura(settings, region)
            ApplySubtextSettings(settings, region)
        end
    end
end

-- Texts
local function GetTextSettings(groupName, auraName, previewCount)
    local groupData = WeakAuras.GetData(groupName)
    local auraData = WeakAuras.GetData(auraName)

    if not (groupData and auraData) then return end

    local settings = {}

    settings.grow = groupData.grow
    settings.limit = groupData.useLimit and groupData.limit or 100
    settings.space = groupData.space

    settings.fontPath = SharedMedia:Fetch("font", auraData.font)
    settings.height = auraData.fontSize
    settings.fontType = auraData.outline
    
    settings.shadowColor = auraData.shadowColor
    settings.shadowXOffset = auraData.shadowXOffset
    settings.shadowYOffset = auraData.shadowYOffset

    -- Calculate options offsets
    settings.optionsOffsets = {0, 0}

    if settings.grow == "UP" then
        settings.optionsOffsets[2] = -(previewCount - 1) * (settings.height + settings.space)
    end

    return settings
end

local function ApplyTextSettings(settings, newPositions, activeRegions)
    if not settings then return end

    PositionAuras(settings, newPositions, activeRegions)

    -- Apply font settings
    for _, regionData in ipairs(activeRegions) do
        local region = regionData.region

        if region.regionType == "text" then
            region.text:SetFont(settings.fontPath, settings.height, settings.fontType)
            region.text:SetShadowOffset(settings.shadowXOffset, settings.shadowYOffset)
            region.text:SetShadowColor(unpack(settings.shadowColor))

            -- Required to force text positioning when no text replacements are present
            region:SetHeight(settings.height)
            region:SetWidth(region.text:GetWidth())
        end
    end
end

-- Specific functions
-- Bars
updateAnchorFunctions.Bars = function()
    anchorSettings.bars = GetBarSettings(
        "Bars - Anchor",
        "SAP Anchor - Bar 1",
        previewCounts.bars
    )
end

applyAnchorFunctions.Bars = function(newPositions, activeRegions)
    ApplyBarSettings(anchorSettings.bars, newPositions, activeRegions)
end

-- Special Bars
updateAnchorFunctions.SpecialBars = function()
    anchorSettings.specialBars = GetBarSettings(
        "Special Bars - Anchor",
        "SAP Anchor - Special Bar",
        previewCounts.specialBars
    )
end

applyAnchorFunctions.SpecialBars = function(newPositions, activeRegions)
    ApplyBarSettings(anchorSettings.specialBars, newPositions, activeRegions)
end

-- Lists
updateAnchorFunctions.Lists = function()
    anchorSettings.lists = GetBarSettings(
        "Lists - Anchor",
        "SAP Anchor - List",
        previewCounts.lists
    )
end

applyAnchorFunctions.Lists = function(newPositions, activeRegions)
    ApplyBarSettings(anchorSettings.lists, newPositions, activeRegions)
end

-- Big Icons
updateAnchorFunctions.BigIcons = function()
    anchorSettings.bigIcons = GetIconSettings(
        "Icon - High Priority - Anchor",
        "SAP Anchor - Big Icon 1",
        previewCounts.bigIcons
    )
end

applyAnchorFunctions.BigIcons = function(newPositions, activeRegions)
    ApplyIconSettings(anchorSettings.bigIcons, newPositions, activeRegions)
end

-- Icons
updateAnchorFunctions.Icons = function()
    anchorSettings.icons = GetIconSettings(
        "Icon - Low Priority - Anchor",
        "SAP Anchor - Icon 1",
        previewCounts.icons
    )
end

applyAnchorFunctions.Icons = function(newPositions, activeRegions)
    ApplyIconSettings(anchorSettings.icons, newPositions, activeRegions)
end

-- Circles
updateAnchorFunctions.Circles = function()
    local groupData = WeakAuras.GetData("Circles - Anchor")
    local auraData = WeakAuras.GetData("SAP Anchor - Circle 1")

    if not (groupData and auraData) then return end

    local settings = {
        subtexts = {}
    }

    settings.width = auraData.width
    settings.height = auraData.height

    for _, subRegion in ipairs(auraData.subRegions) do
        if subRegion.type == "subtext" then
            table.insert(
                settings.subtexts,
                {
                    fontPath = SharedMedia:Fetch("font", subRegion.text_font),
                    size = subRegion.text_fontSize,
                    type = subRegion.text_fontType,
                    shadowColor = subRegion.text_shadowColor,
                    shadowXOffset = subRegion.text_shadowXOffset,
                    shadowYOffset = subRegion.text_shadowYOffset
                }
            )
        end
    end

    anchorSettings.circles = settings
end

applyAnchorFunctions.Circles = function(newPositions, activeRegions)
    local settings = anchorSettings.circles

    if not settings then return end

    for regionCount, regionData in ipairs(activeRegions) do
        local region = regionData.region

        -- Circles are fairly unique in that they should always appear on the character, so they are not positioned "dynamically"
        -- This is the reason that we don't use PositionAuras() for circles
        newPositions[regionCount] = {0, 0}

        ResizeAura(settings, region)
        ApplySubtextSettings(settings, region)
    end
end

-- Texts
updateAnchorFunctions.Texts = function()
    anchorSettings.texts = GetTextSettings(
        "Texts - Anchor",
        "SAP Anchor - Text",
        previewCounts.texts
    )
end

applyAnchorFunctions.Texts = function(newPositions, activeRegions)
    ApplyTextSettings(anchorSettings.texts, newPositions, activeRegions)
end

-- Assignments
updateAnchorFunctions.Assignments = function()
    anchorSettings.assignments = GetTextSettings(
            "Annoying Text",
            "Annoying Text - Anchor",
        previewCounts.assignments
    )
end

applyAnchorFunctions.Assignments = function(newPositions, activeRegions)
    ApplyTextSettings(anchorSettings.assignments, newPositions, activeRegions)
end

function SAP_Raid_Updater:UpdateAnchorSettings(anchorType)
    if not updateAnchorFunctions[anchorType] then return end
    updateAnchorFunctions[anchorType]()
end

function SAP_Raid_Updater:ApplyAnchorSettings(anchorType, newPositions, activeRegions)
    if not applyAnchorFunctions[anchorType] then return end

    applyAnchorFunctions[anchorType](newPositions, activeRegions)
end

-- Update all anchors
for _, updateAnchorFunction in pairs(updateAnchorFunctions) do
    updateAnchorFunction()
end