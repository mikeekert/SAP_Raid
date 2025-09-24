local _, LUP = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local eventFrame = CreateFrame("Frame")

function LUP:UpdateMinimapIcon()
    if not LUP.LDB then
        LUP.LDB = LDB:NewDataObject(
                "SAP Updater",
                {
                    type = "data source",
                    text = "SAP Updater",
                    icon = [[Interface\Addons\SAP_Raid_Updater\Media\Textures\minimap_logo.tga]],
                    OnClick = function() LUP.window:SetShown(not LUP.window:IsShown()) end
                }
        )

        LDBIcon:Register("SAP Updater", LUP.LDB, SAPUpdaterSaved.minimap)
    end

    -- Update color
    if LUP.upToDate then
        LUP.LDB.icon = [[Interface\Addons\SAP_Raid_Updater\Media\Textures\minimap_logo.tga]]
    else
        LUP.LDB.icon = [[Interface\Addons\SAP_Raid_Updater\Media\Textures\minimap_logo_red.tga]]
    end

    -- Update visibility
    if LUP.upToDate and SAPUpdaterSaved.settings.hideMinimapIcon then
        LDBIcon:Hide("SAP Updater")
    else
        LDBIcon:Show("SAP Updater")
    end
end

local function SetSoundNumChannels()
    if not InCombatLockdown() then
        SetCVar("Sound_NumChannels", 128)
    end
end

local function EnsureSettings()
    if not SAPUpdaterSaved then SAPUpdaterSaved = {} end
    if not SAPUpdaterSaved.minimap then SAPUpdaterSaved.minimap = {} end
    if not SAPUpdaterSaved.settings then SAPUpdaterSaved.settings = {} end
    if not SAPUpdaterSaved.settings.frames then SAPUpdaterSaved.settings.frames = {} end
    if not SAPUpdaterSaved.nicknames then SAPUpdaterSaved.nicknames = {} end
    if SAPUpdaterSaved.settings.readyCheckPopup == nil then SAPUpdaterSaved.settings.readyCheckPopup = true end
    if SAPUpdaterSaved.settings.disableBigWigsAssignments == nil then SAPUpdaterSaved.settings.disableBigWigsAssignments = true end
    if SAPUpdaterSaved.settings.debug == nil then SAPUpdaterSaved.settings.debug = false end
end

local function Initialize()
    EnsureSettings()
    SetSoundNumChannels()

    LUP.LiquidUI:Initialize(SAPUpdaterSaved)
    LUP:InitializeNicknames()
    LUP:InitializeBigWigsDisabler()
    LUP:InitializeWeakAurasImporter()
    LUP:InitializeInterface()
    LUP:InitializeTransmission()
    LUP:InitializeVersions()

    RunNextFrame(function() LUP:UpdateMinimapIcon() end)
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript(
        "OnEvent",
        function(_, event, ...)
            if event == "ADDON_LOADED" then
                local addOnName = ...

                if addOnName == "SAP_Raid_Updater" then
                    Initialize()
                end
            end
        end
)

-- Define your slash commands
SLASH_SAPRESET1 = "/sapreset"
SLASH_SAPSHOW1  = "/su"
SLASH_SAPSHOW2  = "/sap"

-- Register the slash command functions
SlashCmdList["SAPRESET"] = function()
    if LUP then
        LUP:ClearAllSAPUpdaterSaved()
    end
end

SlashCmdList["SAPSHOW"] = function()
    if LUP and LUP.window then
        LUP.window:SetShown(not LUP.window:IsShown())
    end
end

function LUP:ClearAllSAPUpdaterSaved()
    if not SAPUpdaterSaved or not SAPUpdaterSaved.WeakAuras then
        LUP:Print("No SAPUpdaterSaved or WeakAuras data to clear.")
        return
    end

    LUP:Print("Clearing all SAPUpdaterSaved data...")
    for key in pairs(SAPUpdaterSaved.WeakAuras) do
        SAPUpdaterSaved.WeakAuras[key] = nil
    end
end