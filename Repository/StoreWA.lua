local _, SAP = ...

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- Checks if we already have this aura installed (by display name)
-- If so, makes sure that the version of the aura we are importing matches its UID
-- This is called both on importing of auras (from SAP.WeakAuras), as well as on updating an aura
-- The goal is to properly update/recognise installed versions of the auras, even if their UID is different
function SAP:MatchInstalledUID(auraData)
    local displayName = auraData and auraData.id
    local installedAuraData = displayName and WeakAuras.GetData(displayName)

    if not installedAuraData then return end

    auraData.uid = installedAuraData.uid
end

-- Table that decides if AuraUpdater auras are relevant for the current patch
-- We don't want to always delete them from the addon completely, because they may become relevant in the future (fated)
-- This also allows for different auras to show on PTR/beta than on live
-- The before/after fields are interface versions, as returned by GetBuildInfo()
-- before is exclusive, after is inclusive
local auraRelevancy = {
    ["SAP - Undermine Liberation"] = {
        before = 110200,
        after = 110100
    },
    ["SAP - Manaforge Omega"] = {
        after = 110200
    }
}

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

-- Takes WeakAura strings from SAP.WeakAuras, decodes them, and saves them to SAPSaved.WeakAuras
-- Only decodes new auras (or new versions of auras)
function SAP:InitializeWeakAurasImporter()
    if not SAPSaved.WeakAuras then SAPSaved.WeakAuras = {} end

    for _, auraData in ipairs(SAP.WeakAuras) do
        local displayName = auraData.displayName

        if IsRelevantWeakAura(displayName) then
            local repositoryWAVersion = auraData.version
            local installedWAVersion = SAPSaved.WeakAuras[displayName] and SAPSaved.WeakAuras[displayName].d and SAPSaved.WeakAuras[displayName].d.version

            if not installedWAVersion or installedWAVersion < repositoryWAVersion then
                local toDecode = auraData.data:match("!WA:2!(.+)")

                if toDecode then
                    local decoded = LibDeflate:DecodeForPrint(toDecode)

                    if decoded then
                        local decompressed = LibDeflate:DecompressDeflate(decoded)

                        if decompressed then
                            local success, data = LibSerialize:Deserialize(decompressed)

                            if success then
                                data.d.version = repositoryWAVersion
                                data.d.url = nil
                                data.d.wagoID = nil

                                if data.c then
                                    for _, childData in pairs(data.c) do
                                        childData.url = nil
                                        childData.wagoID = nil
                                    end
                                end

                                SAPSaved.WeakAuras[displayName] = data
                            else
                                SAP:ErrorPrint(string.format("could not deserialize aura data for [%s]", displayName))
                            end
                        else
                            SAP:ErrorPrint(string.format("could not decompress aura data for [%s]", displayName))
                        end
                    else
                        SAP:ErrorPrint(string.format("could not decode aura data for [%s]", displayName))
                    end
                else
                    SAP:ErrorPrint(string.format("aura data for [%s] does not start with a valid prefix", displayName))
                end
            end
        end
    end

    -- Delete irrelevant auras from SavedVariables
    for displayName in pairs(SAPSaved.WeakAuras) do
        if not IsRelevantWeakAura(displayName) then
            SAPSaved.WeakAuras[displayName] = nil
        end
    end

    -- Match imported aura UIDs to installed aura UIDs
    for _, auraData in pairs(SAPSaved.WeakAuras) do
        SAP:MatchInstalledUID(auraData.d)
    end
end