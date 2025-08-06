-- The purpose of this file is to import auras from WeakAuras.lua (i.e. auras "uploaded" to the addon)
-- Importing them entails deserializing/decoding them, and storing them in SavedVariables
-- Auras are only imported if they haven't been imported before, as determined by their version number

local _, LUP = ...

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- Table that decides if AuraUpdater auras are relevant for the current patch
-- We don't want to always delete them from the addon completely, because they may become relevant in the future (e.g. fated)
-- This also allows for different auras to show on PTR/beta than on live
-- The before/after fields are interface versions, as returned by GetBuildInfo()
-- before is exclusive, after is inclusive
local auraRelevancy = {
    ["SAP - Manaforge Omega"] = {
        110200
    }
}

-- Checks if we already have this aura installed (by display name)
-- If so, makes sure that the version of the aura we are importing matches its UID
-- This is called both on importing of auras (from LUP.WeakAuras), as well as on updating an aura
-- The goal is to properly update/recognise installed versions of the auras, even if their UID is different
-- This function exists in the addon namespace because it's repeated just before auras get updated (for safety)
function LUP:MatchInstalledUID(auraData)
    local displayName = auraData and auraData.id
    local installedAuraData = displayName and WeakAuras.GetData(displayName)

    if not installedAuraData then return end

    auraData.uid = installedAuraData.uid
end

-- Returns whether an aura is relevant based on the auraRelevancy table
-- This is done by displayName, so it can be tested before importing the aura from WeakAuras.lua
local function IsRelevantWeakAura(displayName)
    local relevancyTable = auraRelevancy[displayName]

    if not relevancyTable then return true end

    local interfaceVersion = select(4, GetBuildInfo())
    local beforeOK = true
    local afterOK = true

    if relevancyTable.before then
        beforeOK = interfaceVersion < relevancyTable.before
    end

    if relevancyTable.after then
        afterOK = interfaceVersion >= relevancyTable.after
    end

    return beforeOK and afterOK
end

-- Takes an auraInfo table as input, and deserializes the WeakAuras string, then stores the result in SAPUpdaterSaved.WeakAuras
-- auraInfo tables are how auras are stored in WeakAuras.lua. They are structured as such:
-- auraInfo = {
--     displayName = <string>,
--     version = <number>,
--     data = <string>
-- }
-- This function only imports auras that have a version number higher than what we've imported before
-- Similarly, it does not import them if they are deemed irrelevant by IsRelevantAura
local function ImportAura(auraInfo)
    local displayName = auraInfo.displayName

    if not IsRelevantWeakAura(displayName) then return end -- Do not import irrelevant auras

    local version = auraInfo.version
    local importedVersion = SAPUpdaterSaved.WeakAuras[displayName] and SAPUpdaterSaved.WeakAuras[displayName].d and SAPUpdaterSaved.WeakAuras[displayName].d.sapVersion

    if importedVersion and importedVersion >= version then return end -- Do not import auras that we've imported before

    -- Deserialize the WeakAuras string
    local toDecode = auraInfo.data:match("!WA:2!(.+)")

    local decoded = LibDeflate:DecodeForPrint(toDecode)
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    local _, data = LibSerialize:Deserialize(decompressed)

    -- Add a sapVersion field for version checking
    -- This is what AuraUpdater checks against to detect if a newer version is available compared to what is installed
    data.d.sapVersion = version

    -- These fields are set to nil to prevent WeakAuras companion/Wago app from (mistakenly) suggesting there's updates available
    data.d.url = nil
    data.d.wagoID = nil

    if data.c then
        for _, childData in pairs(data.c) do
            childData.url = nil
            childData.wagoID = nil
        end
    end

    SAPUpdaterSaved.WeakAuras[displayName] = data
end

-- Takes WeakAura strings from LUP.WeakAuras, decodes them, and saves them to SAPUpdaterSaved.WeakAuras
-- Only decodes new auras (or new versions of auras)
function LUP:InitializeWeakAurasImporter()
    if not SAPUpdaterSaved.WeakAuras then SAPUpdaterSaved.WeakAuras = {} end

    for _, auraInfo in ipairs(LUP.WeakAuras) do
        ImportAura(auraInfo)
    end

    -- Delete irrelevant auras from SavedVariables
    for displayName in pairs(SAPUpdaterSaved.WeakAuras) do
        if not IsRelevantWeakAura(displayName) then
            SAPUpdaterSaved.WeakAuras[displayName] = nil
        end
    end

    -- Match imported aura UIDs to installed aura UIDs
    for _, auraData in pairs(SAPUpdaterSaved.WeakAuras) do
        LUP:MatchInstalledUID(auraData.d)
    end
end
